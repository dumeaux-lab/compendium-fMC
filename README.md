# compendium-fMC #

compendium-fMC is a bioinformatics pipeline to process whole genome metagenomic (WGM) profiles of human gut microbiome samples.
It is designed to use the latest genome annotations and minimize false positives, converting raw reads into relative pathway abundances.
The data were further analyzed using deep archetypal model in the deep-fMC_paper.

------------------------
### deep-fMC pipeline has four stages:

1. Data acquisition in online or offline modes. In the online mode, SRA IDs should be provided whereas offline mode requires standard Fastq on the local system.
   
2. Trimming and Filtering with [**FASTP**](https://github.com/OpenGene/fastp) using the following parameters: --trim_poly_x --trim_poly_g -p --length_required 40 --cut_front --cut_tail --cut_mean_quality 25

3. Species Relative Abundance with [**KRAKEN2**](https://ccb.jhu.edu/software/kraken2/) (confidence threshold of 0.15) and [**Bracken**](https://ccb.jhu.edu/software/bracken/). We used the [HumGut database](https://github.com/larssnip/HumGut) following the Genome Taxonomy Database (GTDB) classification scheme61 and the human genome downloaded from NCBI to identify and remove contamination. Improvement of Species Taxonomy using [a custom script from the Bhatt lab](https://github.com/bhattlab/kraken2_classification/blob/master/scripts/improve_taxonomy.py) 
   
5. Pathway Relative Abundance with [**HUMAnN3 v3.7**](https://huttenhower.sph.harvard.edu/humann/) with its associated databases.

------------------------
### System requirements:
* Linux

* Server (Xeon) and Desktop (Intel and AMD Ryzen series) processors

* RAM (minimum 64GB)

------------------------
### Installation:
1. Clone repository ```git clone ```

2. Install the conda environments provided in `envs` folder

3. Initialize the shell. When working with multiplexer or HPC, make sure the shell is properly configured to activate conda environment.


------------------------
### Databases
#### Kraken2

To build Kraken2 database from scratch, use R script in `prepare_databases` folder

#### HUMAnN3
We used [HUMAnN3 v3.7](https://github.com/biobakery/humann/tree/v3p7) and downloaded the folloing databases 

```
humann_databases --download chocophlan full $INSTALL_LOCATION # downloading full_chocophlan.v201901_v31.tar.gz
humann_databases --download uniref uniref90_ec_filtered_diamond $INSTALL_LOCATION # downlaoding uniref90_ec_filtered_201901b_subset.tar.gz
humann_databases --download utility_mapping full $INSTALL_LOCATION # downloading full_mapping_v201901b.tar.gz
```

------------------------
### Running deep-fMC:

1. deep-fMC accepts SRA ids and offline samples for analysis. Its input Parameter are:

      1.1 BASE_DIR: Output directory to save pathway. The Pipeline will also use this directory to process sample and store intermediary files.

      1.2. SAMPLE_LIST: File with list of samples. See sample_lists folder for format
      
      1.3. THREADS: Maximum Threads to use

      1.4. OFF_DATA_LOC: Offline Location of data. The program expects all samples in one folder and names as XX.fq for SE and XX_1.fq and XX_2.fq for PE

3. Prepare the sample list (check out ./sample_lists/PRJNA392180_SE && ./sample_lists/PRJNA298489_MERGED for formatting). 

4. Run pipeline

#### Online mode

```
(/bin/bash -c "cd compendium-fMC && source main.sh && MICROBIOME ./project1/ ./sample_lists/PRJNA392180_SE  online 12")
```

#### Offline mode with paired-end samples (Samples must be named as \*_1.fq, \*_2.fq)

```
(/bin/bash -c "cd ompendium-fMC && source main.sh && MICROBIOME ./project1/ ./sample_lists/PRJNA392180_SE  offline 12 ./offlinesamples/")
```

------------------------
### Output of compendium-fMC:


------------------------
### Citations:

1. *. [Mohamed Meawad, Dalwinder Singh, Alice Deng, Rohan Sonthalia, Evelyn Cai, Vanessa Dumeaux. Deep learning reveals functional archetypes in the adult human gut microbiome that underlie interindividual variability and confound disease signals. Biorxiv 2025](https://doi.org/10.1101/2025.01.29.635381)



