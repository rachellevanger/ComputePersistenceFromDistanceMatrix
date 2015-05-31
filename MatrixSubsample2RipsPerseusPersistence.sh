
# Rename argument variables
INPUT_DIR=$1
DIM=$2
USEDELTA=$3
DELTA=$4

# Set environment variables
source config.sh

# Functions for colored output
colorEcho () {

	TEXT=$1
	LEVEL=$2

	NC='\033[0m'

	if [ $LEVEL == 1 ]; then
		red='\033[31m'
		echo -e "${red}${TEXT}${NC}"
	elif [ $LEVEL == 2 ]; then
		yellow='\033[33m'
		echo -e "${yellow}${TEXT}${NC}"
	elif [ $LEVEL == 3 ]; then
		cyan='\033[36m'
		echo -e "${cyan}${TEXT}${NC}"
	else
		echo $TEXT
	fi

}

if [ ! -d $INPUT_DIR/OUTPUT ]; then
	cd $INPUT_DIR
	mkdir OUTPUT
fi

# Parse $INPUT_DIR$INPUT_FILE_LIST for list of files to process
cat $INPUT_DIR/file_list.txt | while read LINE
do


	LINE_TEXT=( $LINE )

	OUTPUT_DIR=$INPUT_DIR/OUTPUT/${LINE_TEXT[0]}
	INPUT_FILE="${LINE_TEXT[0]}.txt"

	if [ $USEDELTA == 1 ]; then
		DELTA=${LINE_TEXT[1]}
	fi
	ALPHA=${LINE_TEXT[2]}

	echo ""
	colorEcho "Processing ${LINE_TEXT[0]}${NC}" 1

	if [ ! -d $OUTPUT_DIR ]; then
		mkdir $OUTPUT_DIR
	fi

	cd $OUTPUT_DIR

	# Turn distance matrix into weighted graph to feed into GIC code for subsampling
	if [ ! -e $OUTPUT_DIR/weighted_graph.txt ]; then
		colorEcho "Building weighted graph..." 2
		cd $SCRIPTS_DIR
		$PY $SCRIPTS_DIR/Matrix2GIC_Graph_AllEdges.py -f $INPUT_DIR/$INPUT_FILE -a $ALPHA > $OUTPUT_DIR/weighted_graph.txt
	else
		colorEcho "Weighted graph exists." 3
	fi

	# Build the subsample
	if [ ! -e $OUTPUT_DIR/graph_subsample.txt ]; then
		colorEcho "Building subsample..." 2
		cd $OUTPUT_DIR
		$GICOMPLEX/GIComplex --type 1 -I $OUTPUT_DIR/weighted_graph.txt -O $OUTPUT_DIR/graph --delta $DELTA --dim $DIM -r 1
	else
		colorEcho "Subsample exists." 3
	fi

	# Convert the subsample into a distance matrix
	if [ ! -e $OUTPUT_DIR/graph_subsample_matrix.txt ]; then
		colorEcho "Building distance matrix from subsample..." 2
		cd $SCRIPTS_DIR
		$PY $SCRIPTS_DIR/GenerateSubsampledMatrix.py -m $INPUT_DIR/$INPUT_FILE -s $OUTPUT_DIR/graph_subsample.txt > $OUTPUT_DIR/graph_subsample_matrix.txt
	else
		colorEcho "Distance matrix for subsample exists." 3
	fi

	# Build the weighted graph from the subsampled distance matrix
	if [ ! -e $OUTPUT_DIR/weighted_graph_subsample.txt ]; then
		colorEcho "Building weighted graph from subsampled matrix..." 2
		cd $SCRIPTS_DIR
		$PY $SCRIPTS_DIR/Matrix2GIC_Graph_AllEdges.py -f $OUTPUT_DIR/graph_subsample_matrix.txt -a $ALPHA > $OUTPUT_DIR/weighted_graph_subsample.txt
	else
		colorEcho "Weighted graph for subsampled matrix exists." 3
	fi

	# Build the Rips Complex from the subsampled matrix
	if [ ! -e $OUTPUT_DIR/rips_out_complex.txt ]; then
		colorEcho "Building rips complex filtration..." 2
		cd $OUTPUT_DIR
		$GICOMPLEX/GIComplex --type 1 -I $OUTPUT_DIR/weighted_graph_subsample.txt -O $OUTPUT_DIR/graph_out --delta 0 --dim $DIM -R 1
	else
		colorEcho "Subsample exists." 3
	fi

	## Write Perseus input file for computing persistent homology
	# Create new list of simplices, all with alpha birth time
	if [ ! -e $OUTPUT_DIR/perseus_rips_persist.txt ]; then
		colorEcho "Converting to $PERSEUS input..." 2
		cd $OUTPUT_DIR
		$PY $SCRIPTS_DIR/GICGraph2PerseusFloats_nmfsimtop.py -f $OUTPUT_DIR/rips_out_complex.txt > $OUTPUT_DIR/perseus_rips_persist.txt
	else
		colorEcho "$PERSEUS input exists." 3
	fi

	# Compute Persistent Homology
	if [ ! -e $OUTPUT_DIR/output_betti.txt ]; then
		colorEcho "Running $PERSEUS ..." 2
		cd $OUTPUT_DIR
		$PERSEUS_DIR/$PERSEUS nmfsimtop $OUTPUT_DIR/perseus_rips_persist.txt
	else
		colorEcho "$PERSEUS already run." 3
	fi

	# Rescale persistence
	if [ ! -e $OUTPUT_DIR/output_betti_rescaled.txt ]; then
		colorEcho "Rescalaing $PERSEUS output..." 2
		cd $SCRIPTS_DIR
		$PY $SCRIPTS_DIR/RescalePerseusOutputShiftOne.py -f $OUTPUT_DIR/output -d $DIM
	else
		colorEcho "$PERSEUS data already rescaled." 3
	fi

done

echo ""
colorEcho "Writing summary..." 1
cd $SCRIPTS_DIR
$PY $SCRIPTS_DIR/WriteOutput.py -D $INPUT_DIR -d $DIM -p $PERSEUS > $INPUT_DIR/summary.txt


