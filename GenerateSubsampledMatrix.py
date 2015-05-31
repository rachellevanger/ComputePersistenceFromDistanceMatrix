


import sys
from optparse import OptionParser


parser = OptionParser('usage: -m original_matrix.txt -s subsampled_vertices.txt')

parser.add_option("-m", dest="matrix",
                  help="input file for original matrix")
parser.add_option("-s", 
                  dest="subsample", 
                  help="list of subsampled vertices.")


(options, args) = parser.parse_args()


subsample = open(options.subsample).read()
subsample_lines = subsample.split("\n")

matrixfile = open(options.matrix).read()
matrix_rows = matrixfile.split("\n")

matrix = []

for row in matrix_rows:
    if row != "":
        matrix.append(row.split(" "))

indices = [int(idx) for idx in subsample_lines[1:] if idx != ""]

outmatrix = [[y[1] for y in enumerate(row) if y[0] in indices] for row in [x[1] for x in enumerate(matrix) if x[0] in indices]]

for row in outmatrix:
    sys.stdout.write(" ".join(row) + "\n")

