
import sys
from optparse import OptionParser


parser = OptionParser('usage: -D directory -d dimension -p perseus')

parser.add_option("-D", dest="directory",
				  help="Directory containing file_list.txt.")
parser.add_option("-d", dest="dim", 
                  help="Max dimension")
parser.add_option("-p", dest="perseus",
				  help="Perseus app name")


(options, args) = parser.parse_args()

directory = options.directory
file_list = open(directory + "/file_list.txt").read()

files = file_list.split("\n")

# Write header
strout = "FILE DELTA ALPHA " # Contents from file_list.txt
strout += "RIPS_DIM0 RIPS_DIM1 RIPS_DIM2 " # Rips complex stats
strout += "GIC_DIM0 GIC_DIM1 GIC_DIM2 " # Graph Induced Complex stats
strout += "RED_DIM0 RED_DIM1 RED_DIM2 " # % Reduction stats
#strout += "GIC_MEM GIC_TIME PERSEUS_MEM PERSEUS_TIME " # Memory/Time stats
strout += "\n"

sys.stdout.write(strout)

for f in files:
	if f=="":
		break

	# Contents from file_list.txt
	strout = f + " "
	f = f.split(" ")
	filename = f[3]

	# Write complex stats
	complex_stats = ["rips_out_stat.txt", "graph_out_stat.txt"]

	cpx_calc = []

	for i in range(0,2):
		cpx_out_stat = open(directory + "/OUTPUT/" + filename + "/" + complex_stats[i]).read()
		cpx_stats = cpx_out_stat.split("\n")

		for d in range(0,len(cpx_stats) - 2):
			dStat = cpx_stats[d].split(" ")
			strout += dStat[3] + " "
			if i==0:
				cpx_calc.append([dStat[3],0])
			else:
				cpx_calc[d][1]=dStat[3]

		# Space fill for dimensions not generated, up to max dimension
		strout += "0 " * (int(options.dim) - (len(cpx_stats) - 2))

	# Write reduction stats
	for d in range(0,int(options.dim)+1):
		strout += str("{0:.2f}".format((1 - (float(cpx_calc[d][1])/int(cpx_calc[d][0]))))) + " "

	# # Write Memory/Time stats
	# mem_usage = open(directory + "OUTPUT/" + "mem_usage.txt").read()
	# mem_usage = mem_usage.split("\n")

	# fileindex=0
	# for i in range(0,len(mem_usage)+1):
	# 	if mem_usage[i].strip() == (filename + "/"):
	# 		fileindex=i
	# 		break

	# i=1
	# while mem_usage[fileindex + i] != "":
	# 	mem_info = mem_usage[fileindex + i].split(" ")
	# 	if mem_info[0] in ["GIComplex", options.perseus]:
	# 		strout += str("{0:.2f}".format(float(mem_info[1])/1000)) + " " + mem_info[2] + " "
	# 	i+=1

	sys.stdout.write(strout + "\n")


