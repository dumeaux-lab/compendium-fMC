#!/usr/bin/env Rscript
library("optparse")
 
option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL, 
              help="Bracken report directory location", metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL, 
              help="Matrices output directory location", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$input) && is.null(opt$output)){
  print_help(opt_parser)
  stop("Input/Output directories are not given. Exiting", call.=FALSE)
}

suppressMessages(library(here, quietly = TRUE, warn.conflicts = FALSE))
suppressMessages(library(ggplot2, quietly = TRUE, warn.conflicts = FALSE))
suppressMessages(library(rafalib, quietly = TRUE, warn.conflicts = FALSE))
suppressMessages(library(vegan, quietly = TRUE, warn.conflicts = FALSE))
suppressMessages(library(reshape2, quietly = TRUE, warn.conflicts = FALSE))
suppressMessages(library(RColorBrewer, quietly = TRUE, warn.conflicts = FALSE))
suppressMessages(library(cmapR, quietly = TRUE, warn.conflicts = FALSE))

suppressMessages(library(zCompositions, quietly = TRUE, warn.conflicts = FALSE))

#suppressMessages(library(ggpubr, quietly = TRUE, warn.conflicts = FALSE))
suppressMessages(library(vegan, quietly = TRUE, warn.conflicts = FALSE))
suppressMessages(library(rhdf5, quietly = TRUE, warn.conflicts = FALSE))

options(stringsAsFactors = F)

source("/home/UWO/dsing243/microbiome/bin/process_classification_gctx.R")


tax.array.file <- "/data/lab_vm/campervans/db/metagenomics/humgut/krakendb_gtdbhumgut/taxonomy_array.tsv"
humgut <- "/data/lab_vm/campervans/db/metagenomics/humgut/HumGut.tsv"
humgut.array <- read.table(humgut, sep='\t', quote='', header=T, comment.char = '', colClasses = 'character')

tax.array <- read.table(tax.array.file, sep='\t', quote='', header=F, comment.char = '', colClasses = 'character')
colnames(tax.array) <- c('id', 'taxid', 'root', 'kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species', 'subspecies')[1:ncol(tax.array)]

dup.ids <- tax.array$id[duplicated(tax.array$id)]
dup.inds <- which(tax.array$id %in% dup.ids)

tax.array[tax.array$id %in% dup.ids, "id"] <-
    paste(tax.array[tax.array$id %in% dup.ids, "id"], ' (', tax.array[tax.array$id %in% dup.ids, "taxid"], ')', sep='')

tax.array$id <- ifelse(tax.array$id=="root (1)", "root", tax.array$id)

classification.folder <- opt$input

f.ext <- 'bracken_species.kreport$'
flist <- list.files(classification.folder, pattern = f.ext, full.names = TRUE)
short.flist <- list.files(classification.folder, pattern = f.ext)
names(flist) <- unlist(lapply(strsplit(short.flist, "_"), "[", 1))


test.df <- kraken_file_to_df(flist[1])
uhgg <- all(paste0('R', 1:7) %in% test.df$tax.level)
segata <- !uhgg & sum(sum(test.df$tax.level=='G')) == 0

message(paste('Loading data from ', length(flist), ' kraken/bracken results.', sep=''))
df.list <- lapply(flist, function(x) kraken_file_to_df(x))
merge.mat <- merge_kraken_df_list(df.list)

all <- read.csv("/data/lab_vm/refined/GMrepo/metagenome_healthy_adults/clean_metadata_may10.csv")
sample.metadata <- all[all$run_id %in% colnames(merge.mat),]
sample.metadata$id <- sample.metadata$run_id


kgct <- make_gct_from_kraken(merge.mat, sample.metadata, tax.array)

remove.chordata <- TRUE
if(remove.chordata){
    kgct <- subset_gct(kgct, rid=kgct@rid[kgct@rdesc$phylum != "Chordata"])
}

if (segata){
    filter.levels <- c('species')
    kgct.filtered.list <- list(species=subset_gct(kgct, rid=kgct@rid[kgct@rid != 'root']))
} else {
    filter.levels <-  c('kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species')
    kgct.filtered.list <- lapply(filter.levels, function(level) {
        subset_kgct_to_level(kgct, level)
        })
    names(kgct.filtered.list) <- filter.levels
}

unclassified.rownames <- c('unclassified', 'classified at a higher level')
kgct.filtered.classified.list <- lapply(kgct.filtered.list, function(x) subset_gct(x, rid=x@rid[!(x@rid %in% unclassified.rownames)]))

min.frac <- 0.001
kgct.filtered.percentage.list <- lapply(kgct.filtered.list, function(x) normalize_kgct(x, min.frac=min.frac))
kgct.filtered.classified.percentage.list <- lapply(kgct.filtered.classified.list, function(x) normalize_kgct(x, min.frac=min.frac))


mat.name <- 'bracken'
use.bracken.report <- TRUE

result.dir <- opt$output

outfolder.matrices.taxonomy <- file.path(result.dir, 'taxonomy_matrices')
outfolder.matrices.taxonomy.classified <- file.path(result.dir, 'taxonomy_matrices_classified_only')
outfolder.gctx.taxonomy <- file.path(result.dir, 'taxonomy_gctx')
outfolder.gctx.taxonomy.classified <- file.path(result.dir, 'taxonomy_gctx_classified_only')
outfolder.plots <- file.path(result.dir, 'plots')
outfolder.matrices.bray <- file.path(result.dir, 'braycurtis_matrices')


for (f in c(#outfolder.matrices.taxonomy,
            outfolder.matrices.taxonomy.classified,
            #outfolder.gctx.taxonomy,
            outfolder.gctx.taxonomy.classified,
            outfolder.plots, outfolder.matrices.bray)){
    if (!dir.exists(f)){ dir.create(f, recursive = T)}
}



for (tn in filter.levels){
    outf.mat.reads <- file.path(outfolder.matrices.taxonomy, paste(mat.name, tolower(tn), 'reads.txt', sep='_'))
    outf.mat.percentage <- file.path(outfolder.matrices.taxonomy, paste(mat.name, tolower(tn), 'percentage.txt', sep='_'))
    outf.mat.reads.classified <- file.path(outfolder.matrices.taxonomy.classified, paste(mat.name, tolower(tn), 'reads.txt', sep='_'))
    outf.mat.percentage.classified <- file.path(outfolder.matrices.taxonomy.classified, paste(mat.name, tolower(tn), 'percentage.txt', sep='_'))
    # gctx names
    outf.gctx.reads <- file.path(outfolder.gctx.taxonomy, paste(mat.name, tolower(tn), 'reads.gctx', sep='_'))
    outf.gctx.percentage <- file.path(outfolder.gctx.taxonomy, paste(mat.name, tolower(tn), 'percentage.gctx', sep='_'))
    outf.gctx.reads.classified <- file.path(outfolder.gctx.taxonomy.classified, paste(mat.name, tolower(tn), 'reads.gctx', sep='_'))
    outf.gctx.percentage.classified <- file.path(outfolder.gctx.taxonomy.classified, paste(mat.name, tolower(tn), 'percentage.gctx', sep='_'))

    # save matrices
    if (!use.bracken.report){
        write.table(kgct.filtered.list[[tn]]@mat, outf.mat.reads, sep='\t', quote=F, row.names = T, col.names = T)
    }
    write.table(kgct.filtered.classified.list[[tn]]@mat, outf.mat.reads.classified, sep='\t', quote=F, row.names = T, col.names = T)

    mat.percentage <- kgct.filtered.percentage.list[[tn]]@mat
    # order rows by mean abundance across samples
    row.order <- rownames(mat.percentage)[order(rowMeans(mat.percentage), decreasing = T)]
    row.order <- row.order[!(row.order %in% unclassified.rownames)]
    row.order <- c(unclassified.rownames[unclassified.rownames %in% rownames(mat.percentage)], row.order)
    mat.percentage <- mat.percentage[row.order,]
    # classified only matrix
    mat.percentage.classified <- kgct.filtered.classified.percentage.list[[tn]]@mat
    row.order.classified <- order(rowMeans(mat.percentage.classified), decreasing = T)
    mat.percentage.classified <- mat.percentage.classified[row.order.classified,]

    if (!use.bracken.report){
        write.table(mat.percentage, outf.mat.percentage, sep='\t', quote=F, row.names = T, col.names = T)
    }
    write.table(mat.percentage.classified, outf.mat.percentage.classified, sep='\t', quote=F, row.names = T, col.names = T)

    # save gctx 
    # only save with unclassified if not using Bracken
    if (!use.bracken.report){
        suppressMessages(write_gctx(kgct.filtered.list[[tn]], outf.gctx.reads, appenddim = F))
        suppressMessages(write_gctx(kgct.filtered.percentage.list[[tn]], outf.gctx.percentage, appenddim = F))
    }
    suppressMessages(write_gctx(kgct.filtered.classified.list[[tn]], outf.gctx.reads.classified, appenddim = F))
    suppressMessages(write_gctx(kgct.filtered.classified.percentage.list[[tn]], outf.gctx.percentage.classified, appenddim = F))
}



div.methods <- c('shannon', 'simpson')
div.level.method <- lapply(filter.levels, function(x) {
    use.matrix <- kgct.filtered.classified.list[[x]]@mat
    # if not enough valid rows, skip it
    if (nrow(use.matrix) <3){
        dl <- lapply(div.methods, function(x) rep(0, times=ncol(use.matrix)))
    } else {
        dl <- lapply(div.methods, function(y) diversity(use.matrix, index=y, MARGIN = 2))
    }
    names(dl) <- div.methods
    dl
})
names(div.level.method) <- filter.levels

div.df <- as.data.frame(div.level.method)

div.df <- cbind(data.frame(sample=rownames(div.df)), div.df)
div.df <- melt(div.df, id.vars = 'sample')
div.df$tax.level <- sapply(div.df$variable, function(x) strsplit(as.character(x), split="\\.")[[1]][1])
div.df$method <- sapply(div.df$variable, function(x) strsplit(as.character(x), split="\\.")[[1]][2])
div.df <- div.df[,c('sample', 'tax.level','method','value')]

div.df$value <- round(div.df$value, 3)

out.div <- file.path(result.dir, 'diversity.txt')
write.table(div.df, out.div, sep='\t', quote=F, row.names=F, col.names=T)


for (tn in filter.levels){
    bray.dist <- as.matrix(vegdist(t(kgct.filtered.classified.percentage.list[[tn]]@mat)))
    out.bray <- file.path(outfolder.matrices.bray, paste('braycurtis_distance_', tolower(tn), '.txt', sep=''))
    write.table(bray.dist, out.bray, sep='\t', quote=F, row.names = T, col.names = T)
}