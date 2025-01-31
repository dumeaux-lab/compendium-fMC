#!/usr/bin/env Rscript
library("optparse")
 
option_list = list(
  make_option(c("-i", "--input"), type="character", default=NULL, 
              help="Input MPA file", metavar="character"),
    make_option(c("-o", "--output"), type="character", default=NULL, 
              help="Output reformatted MPA file", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$input) && is.null(opt$output)){
  print_help(opt_parser)
  stop("Input/Output Files are not given. Exiting", call.=FALSE)
}

f <- file.path(opt$input)
tb <- read.table(f)
tb$V1 <- gsub("k__d__", "k__", tb$V1)
tb$V1 <- gsub("(p__|c__|o__|f__|g__|s__)\\1", "\\1", tb$V1)
tb$V3 <- 1:nrow(tb)
tb$V4 <- rep("", nrow(tb))
tb <- tb [, c(1,3,2,4)]
write.table(tb, file.path(opt$output), col.names = FALSE, quote = FALSE, row.names = FALSE, sep = "\t")
fConn <- file(file.path(opt$output), 'r+')
Lines <- readLines(fConn)
writeLines(c("#mpa_v31_CHOCOPhlAn_201901", Lines), con = fConn)
close(fConn)
