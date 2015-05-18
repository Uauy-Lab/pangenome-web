# README 

This database and information system is designed to integrate resources from the wheat community. The initial targets are to integrate:

* Genetic maps
* Genome assemblies
* SNP Markers
* Syntenic genes
* Gene anottation
* PolyMarker

## Architecture

The general components in the system are stacked as follow:
![](doc/Arch.png)
Note: The BAM files may be scrollable.


## Database


![](doc/Database.png)


## Use case
This are the initial use cases
![](doc/UseCase.png)



## Setting up

Once the database is setup via ```rake db:migrate``` there are rake tasks to add teh data. If you want to clear the database, to clear the data during development: ```rake db:drop db:create db:migrate```

### Adding the list of markers
In order to add the markers, a table with a marker per row, with all the names for the marker and a column with the sequence is used as input. The only column not treated as a name is the column with the header "Sequence", which contains the sequence for the SNP within brackets, with the IUAPC ambiguity code representing the different alleles in the SNP. 
Example:

```
Affymetrix_Code,Bristol_Affy_Code,Bristol_SNP_Code,Bristol_Contig_Code,Sequence
AX-94381124,BA00222391,No BS code,GJKKTUG01CGTKM_219,CTGTAGATGTGCACCTTGATGGTATCCTCGGCGATGAGCTCGAAGACGCA[R]ACNTCGAACTTCTCCAGATTGTTGCCGATCGAGAACTGGCTCCAGCCTCT
AX-94381126,BA00232763,No BS code,FZU8VVO01APRT5_148,ACAACCCGTGGTGGAAATAAGCGACGCAAGCTCCGGCAGCAATGCTCACT[Y]GNGTGATATGTTAAGCCTCCTGCCCAGTCCTAAGAACGCTGCTATAAGAC
AX-94381127,BA00233916,No BS code,contig77177_250,GCGTCCCCGGCCGCCACAACGGCCATCGCGGTCGGCGACCGGCTCCCCGA[M]NCGACGCTCTCCTACTTCGACGCCCCCGACGGCGAGCTGAAGACGGTGAC
AX-94381128,BA00235611,No BS code,GJKKTUG02JAI6G_371,TCGGTACTTCTTAAGACCAGTCTAGATGTTGCATATGAACATGAATCAAT[Y]GGGGTNACGCACATCATCAACAGATGATGTCACAATAAGAGTGGAGAGAG
AX-94381129,BA00239105,No BS code,contig78690_277,CCCCCAGTGAAAGGGAGCAGCCATTGACAGGCAAGGGCGAAGGAAGCAGC[R]ACGGNGCAGAACAAGACAGAGAGCAGGGGGCATGGGGGAGAAGGCTGCGG
AX-94381131,BA00249777,No BS code,contig82171_572,ACGGCCTCGTCAACTTCGACGAGTTCGTCAGGATGATGATGCTCTCCGAC[K]CCGACNNNNNNNNNNNNNNNNNTTGAGAGTCTGTCCGAGATAGATATATA
AX-94381137,BA00325640,No BS code,contig94834_761,AGTCGCTCATCGACAACGGCATCCACGTCAAGCTCTACCTCGACTGATCC[Y]TTTTCNNNNNNNNGCTGTGGTATGTCTGTTGCCGCTCTGCTTTCGACACC
AX-94381138,BA00327658,No BS code,contig94085_155,GGTGCCCTTGCTCCCCATCCTCCTCCTCCTCGCGCTGCTCTCGCCGGCCG[Y]CCGNGGCTCGGAGTCGCCGCAGTACGCGACGGTGCACGCGGAGTCGGACT
AX-94381140,BA00343181,No BS code,F0Z7V0F01DPY86_337,ATATTTGCTGTTTTCTTCAGTCTACCAGGCCGCTATGAAGCATTGTGGAA[R]GNGGTTGATGGTGTCAAGCAGCTTTGGAAGAACAGGAAGGAGCTCAAGGT
```

To load the markers in hte previous file, the following task is used:

```bash
rake marker:load_marker_from_820k_csv[820k_markers,data/head_affy.csv]
```
The first argument is the name of the marker set and the second the path with the csv. By default, the main name of the marker is the column ```Bristol_Affy_Code```, but if it is missing, it defaults to the first name.  



### Adding a genetic map 


```bash
rake "genetic_map:add[:name,:filename,:description,:species]"
```

 * ```:name``` The name of the genetic map
 * ```:filename``` A tab separated column, with four columns ID[string], Chromosome[string], position cM[float], order[int] 

Example:

```csv
Ra_c23068_380 1A 0 1
BobWhite_c48447_529 1A 33.01 2
BS00062658_51 1A 37.14 3
BS00026003_51 1A 38.46 4
BS00071289_51 1A 42.4 5
Excalibur_c9509_1180 1A 42.4 6
GENE-0412_338 1A 42.4 7
IAAV3919 1A 42.4 8
Kukri_c18951_853 1A 42.4 9
RAC875_c42700_264 1A 42.4 10
```

* ```:description``` A short description of the genetic map, may include a doi
* ```:species``` The name of the species. It is optional. Defaults to ```Hexaploid Wheat```


### Adding the marker alignment to scaffolds

To load the positions of the markers, PSL alignments from Blat can be used. Only continous alignments are recorded. 

```marker:load_blat_position ``` 
c