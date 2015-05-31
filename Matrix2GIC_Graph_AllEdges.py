
import sys
from optparse import OptionParser

parser = OptionParser('usage: -f infile.txt -a 0')

parser.add_option("-f", dest="infile",
                  help="input file")
parser.add_option("-a", 
                  dest="alpha", default=0,
                  help="filter edges greater than this value")

(options, args) = parser.parse_args()

infile = open(options.infile).read()

infile_lines = infile.split("\n")
numlines = len(infile_lines) - 1

# Write header
strout = "0" + " " + str(numlines) + "\n"
sys.stdout.write(strout)

alpha = float(options.alpha)


for i in range(0, numlines):
    distances = infile_lines[i].strip().split(" ")
    for j in range(i+1, numlines):
        if (float(distances[j]) <= alpha) or (alpha==0):
            strout = str(i) + " " + str(j) + " "
            if float(distances[j]) == 0:
                strout = strout + "0.000001\n"
            else:
                strout = strout + str(distances[j]) + "\n"
            sys.stdout.write(strout)








