# GeneSyntenyDB

This will show you how to set up a workflow that allows gene synteny analysis on genomes stored at NCBI.
The protocol is divided into four major parts:
1) Database creation
2) Taxonomic annotation
3) Functional annotation
4) Gene synteny

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
## Taxonomic annotation

## Functional annotation

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
