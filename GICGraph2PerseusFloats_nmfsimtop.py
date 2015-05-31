
import sys
from optparse import OptionParser




parser = OptionParser('usage: -f infile.txt')

parser.add_option("-f", dest="infile",
                  help="input file")

(options, args) = parser.parse_args()

infile = open(options.infile).read()

infile_lines = infile.split("\n")

(numDims, numCoords) = [int(x) for x in infile_lines[0].strip().split(" ")]
numDims = 1

# Build header
strout = str(numDims) + "\n"

# Write header
sys.stdout.write(strout)
strout = ''

# Isolate the coordinate values
coords = []
for item in infile_lines[1:(numCoords+1)]:

  # Write 0-dimensional simplices: birth time=0
  sys.stdout.write("0 " + item.strip() + ' 1\n')

  # Convert into vectors (useful when dimension > 1)
  strvector = (item.strip().split(" "))

  if strvector[0] != "":
    fltvector = [float(x) for x in strvector]
    coords.append(fltvector)

strout = ''
# Go through simplices
for item in infile_lines[(numCoords + 1):]:
  strvector = (item.strip().split(" "))

  if strvector[0] != "": # Data exists
    # Write dimension of simplex
    strout = str(int(strvector[0]) - 1) + " "
    for coordNum in strvector[1:-1]:
      strout += " ".join([str(int(x)) for x in coords[int(coordNum)]]) + " "

    strout += str(float(strvector[-1]) + 1) + " \n"
    sys.stdout.write(strout)




