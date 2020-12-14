# GeneSyntenyDB

This will show you how to set up a workflow that allows gene synteny analysis on genomes stored at NCBI.
The protocol is divided into four major parts: <br/>
1) Database creation <br/>
2) Taxonomic annotation <br/>
3) Functional annotation <br/>
4) Gene synteny <br/>

This is still very much a work in progress, but feel free to submit a [github issue](https://github.com/gisleDK/LocalDB_with_gene_synteny/issues) or contact me at gisves at dtu dot dk

**Table of contents**
- [GeneSyntenyDB](#genesyntenydb)
  * [Database creation](#database-creation)
  * [Taxonomic annotation](#taxonomic-annotation)
  * [Functional annotation](#functional-annotation)
  * [Gene synteny](#gene-synteny)

## Database creation
The database is based on NCBI data and uses their [ftp server](https://ftp.ncbi.nlm.nih.gov/genomes). I use the non-redundant genomes found in refseq, but since the structure is the same, genbank shoould also work. First we need to download the relevant overview file called assembly_summary.txt. In this case we are interested in all archaeal genomes found in refseq:
```
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/archaea/assembly_summary.txt
```
This is a tabulated table of all archaeal genomes and column 12 tells us if the genome is complete. We extract a list of complete genomes using awk:
```
awk -F '\t' '{if($12=="Complete Genome") print $20}' assembly_summary.txt > complete.list
```
Now we can download from NCBI using:
```
for next in $(cat complete.list); do wget -P Complete "$next"/*genomic.gbff.gz; done
```
We unpack and concatenate all files to make one big genbank file:
```
zcat Complete/*.gbff.gz > complete.gbk
```
To extract all CDS and attach a unique identifier that also includes gene order found in Genbank files (features are stored according to position) we use [extractCDSfromGB.py](https://github.com/gisleDK/LocalDB_with_gene_synteny/blob/main/extractCDSfromGB.py)
```
extractCDSfromGB.py -i complete.gbk > archaea.cds.faa
```
The output fasta file contains all actual CDS features of the Genbank file. Each fasta header consists of >ACCESSION NUMBER_PROTEIN ID_UNIQUE ID
### Plasmids database creation
Plasmids are a bit different at NCBI, so it is done with minor modifications. We download all plasmids:
```
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/plasmid/plasmid.*.genomic.gbff.gz
```
Concatenate
```
zcat *.gbff.gz > complete.gbk
```
To extract all CDS and attach a unique identifier that also includes gene order found in Genbank files (features are stored according to position) we use [extractCDSfromGB.py](https://github.com/gisleDK/LocalDB_with_gene_synteny/blob/main/extractCDSfromGB.py)
```
extractCDSfromGB.py -i complete.gbk > archaea.cds.faa
```
The output fasta file contains all actual CDS features of the Genbank file. Each fasta header consists of >ACCESSION NUMBER_PROTEIN ID_UNIQUE ID
## Taxonomic annotation (optional)
This is not necessary for many of the following gene synteny analysis, but included nonetheless.
This can be done several ways. For this workflow I chose [Kaiju](http://kaiju.binf.ku.dk/) because I need sensitivity and speed more than precision. See their webpage for installation instructions and how to setup your Kaiju database.
```
kaiju -t nodes.dmp -f kaiju_db_nr_euk.fmi -i archaea.cds.faa -o archaea.cds.faa.kaiju -z 20 -p -v
```
Adding full taxon path to Kaiju output
```
kaiju-addTaxonNames -i archaea.cds.faa.kaiju -o archaea.cds.faa.kaiju.names -t nodes.dmp -n kaiju_db_nr_euk_names.dmp -p
```

## Functional annotation
For functional annotation we will use the slow but excellent [EggNOG-mapper](https://github.com/eggnogdb/eggnog-mapper). See their webpage for installation instructions and how to setup their database.
```
emapper.py -m diamond --cpu 10 -i archaea.cds.faa -o archaea.eggnog
```
## Gene synteny




Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/gisleDK/LocalDB_with_gene_synteny/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://docs.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.
