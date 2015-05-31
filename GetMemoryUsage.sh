
# NEED TO UPDATE THIS SO IT'S ACTUALLY USEFUL.


# Set environment variables
source config.sh

cd $INPUT_DIR

memFile="mem_usage.txt"
echo "" > $memFile


prevFolder=none

prevProcessName="Python"
prevProcessTime=0
maxProcessMem=0
maxProcessCPU=0

processKilled=0


# Get last modified folder
curFolder=$(ls -t -d */ | head -n +1)

# If different than previous folder then write new folder name to file
if [ "$curFolder" != "$prevFolder" ]; then
	echo "" >> $memFile
	echo $curFolder >> $memFile
	prevFolder=$curFolder
fi

while [ 1==1 ]
do

	# Managed Processes
	# Command for laptop
	#curProcessInfo=( $(ps -c -A -O "rss %cpu" | grep -i -e Python -e GIComplex -e $PERSEUS) )
	# Command for compute server
	curProcessInfo=( $(ps c -u rll81 -O "rss %cpu" | grep -i -e Python -e GIComplex -e $PERSEUS) )

	# Make sure a managed process came back
	if [ $curProcessInfo ]; then

		# Get Current Process Info
		curProcessID=${curProcessInfo[0]}
		curProcessName=${curProcessInfo[6]}
		curProcessCPU=${curProcessInfo[2]}
		curProcessCPU=${curProcessCPU/.*}
		curProcessMem=${curProcessInfo[1]}
		curProcessMem=${curProcessMem/.*}
		curProcessTime=${curProcessInfo[5]}

		# Compensate for killed process
		if [[ ! ( $processKilled == 1  &&  "$curProcessName" == "$prevProcessName" ) ]]; then

			if [ $processKilled == 1 ]; then

				processKilled=0			

				# Reset tracked usages
				maxProcessCPU=0
				maxProcessMem=0

			fi

			# Keep track of maximum memory usage
			if [ $maxProcessMem -lt $curProcessMem ] && [ "$curProcessName" == "$prevProcessName" ]; then
				maxProcessMem=$curProcessMem
			fi

			# Keep track of maximum CPU usage
			if [ $maxProcessCPU -lt $curProcessCPU ] && [ "$curProcessName" == "$prevProcessName" ]; then
				maxProcessCPU=$curProcessCPU
			fi

			# Terminate when CPU falls for GIComplex and perseus
			if [ $curProcessCPU -lt 40 ] && [ $maxProcessCPU -gt 90 ] &&  [ "$curProcessName" == "$prevProcessName" ] && [ "$curProcessName" != "Python" ]
			then
				echo $curProcessName $maxProcessMem $prevProcessTime "(KILLED)" >> $memFile
				echo Killing $curProcessName \(pid=$curProcessID\)
				kill $curProcessID
				processKilled=1
			fi

			# When current managed process changes then write out results of previous run to file
			if [ "$curProcessName" != "$prevProcessName" ]; then
				echo $prevProcessName $maxProcessMem $prevProcessTime >> $memFile

				# Reset tracked usages
				maxProcessCPU=0
				maxProcessMem=0

			fi

		fi

		# Get last modified folder
		curFolder=$(ls -t -d */ | head -n +1)

		# If different than previous folder then write new folder name to file
		if [ "$curFolder" != "$prevFolder" ]; then
			echo "" >> $memFile
			echo $curFolder >> $memFile
			prevFolder=$curFolder
		fi

		prevProcessName=$curProcessName
		prevProcessTime=$curProcessTime

	fi

	sleep 1

	prevFolder=$curFolder

done









