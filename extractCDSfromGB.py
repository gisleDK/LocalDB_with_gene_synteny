#!/usr/bin/env python
# Written for biopython under python 3.8.5
# V0.01 Written by Gisle Vestergaard (gislevestergaard@gmail.com)
# This script will read a genbank file and extract CDS with a unique identifier
import argparse
from Bio import SeqIO

parser = argparse.ArgumentParser(description='extract CDS from concatenated genbank file and add id.')
parser.add_argument('-i','--input', help='Input concatenated genbank file', required=True)
parser.add_argument('-n','--number', help='Input unique id starting value', default=0, type=int)
args = parser.parse_args()

f_open = open(args.input, "r")
uniqid = args.number

for genome in SeqIO.parse(f_open, "genbank"):
	for gene in genome.features:
		if gene.type == 'CDS'and 'translation' in gene.qualifiers:
			uniqid +=1
			CDS=gene
			id = ''.join(gene.qualifiers['protein_id'])
			print(">",("_".join((genome.id,id,str(f"{uniqid:09d}")))), sep ='')
			print(''.join(gene.qualifiers['translation']))
f_open.close()
