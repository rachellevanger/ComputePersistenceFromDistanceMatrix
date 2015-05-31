# Rename argument variables
INPUT_DIR=$1
HOM=$2

# Set environment variables
source config.sh

cd $INPUT_DIR

mkdir OUTPUT/H${HOM}DATA

# Parse file_list.txt for list of files to process
cat $INPUT_DIR/file_list.txt| while read LINE
do

        LINE_TEXT=( $LINE )

        FILE=${LINE_TEXT[0]}

        # Reach into the file's directory and copy the H(n) data
        # into a new persistence directory, rename it
        cp $INPUT_DIR/OUTPUT/$FILE/output_${HOM}_rescaled.txt $INPUT_DIR/OUTPUT/H${HOM}DATA/${FILE}_H${HOM}.txt

done

