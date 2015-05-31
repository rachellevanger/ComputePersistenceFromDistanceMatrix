
import sys
from optparse import OptionParser




parser = OptionParser('usage: -f infile_dir_prefix -d dim -s 1')

parser.add_option("-f", dest="infile_dir_prefix",
                  help="input file's directory and prefix")
parser.add_option("-d", dest="dim",
                  help="dimension of largest simplex")


(options, args) = parser.parse_args()


# PROCESS OUTPUT_BETTI.TXT

infile = open(options.infile_dir_prefix + '_betti.txt').read()
outfile = open(options.infile_dir_prefix + "_betti_rescaled.txt","w+")

infile_lines = infile.split("\n")

# Process the first line of data (0-simplices) in the file
# Change birth time to zero (must be less than all others)
first_line = infile_lines[1].strip().split(" ", 1)
outfile.write("0 " + first_line[1] + "\n")

for line in infile_lines[2:]:
  output = line.strip().split(" ", 1)
  outfile.write(str(float(output[0]) - 1) + " " + output[1] + "\n")

outfile.close()

# PROCESS OUTPUT_(dim).TXT

for d in range(0,int(options.dim)+1):
  infile = open(options.infile_dir_prefix + '_' + str(d) + '.txt').read()
  outfile = open(options.infile_dir_prefix + '_' + str(d) + '_rescaled.txt',"w+")

  infile_lines = infile.split("\n")

  # For dimension zero, change birth time to 0 from 1 and scale others
  for line in infile_lines:
    if line!="":
      generator = line.strip().split(" ")
      if d==0:
        generator[0] = '1'
      generator[0] = str(float(generator[0]) - 1)
      if generator[1]!='-1':
        generator[1] = str(float(generator[1]) - 1)
      outfile.write(" ".join([x for x in generator]) + "\n")

  outfile.close()


