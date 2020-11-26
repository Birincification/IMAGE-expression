#!/usr/local/bin/Rscript

library(argparse)
library(ballgown)
#library(biomaRt)

parser <- ArgumentParser()

parser$add_argument('--base.dir')
parser$add_argument('--p.data')
parser$add_argument('--condition.pairs')
parser$add_argument('--out.dir')
#parser$add_argument('--mart_dataset', default="hsapiens_gene_ensembl")
#parser$add_argument('--mart_version', default=75)
#parser$add_argument('--mart_grch', required=FALSE)
parser$add_argument('--tx2gene', required=TRUE)



args <- parser$parse_args(commandArgs(trailingOnly=T))


print(args)
p.data <- read.csv(args$p.data, sep="\t")

cond.pairs <- read.csv(args$condition.pairs, sep="\t", header=F)
print(cond.pairs)


load(args$tx2gene)

###print("loading mart...")
###print(sprintf("datatset: %s", args$mart_dataset))
###print(sprintf("version: %s", args$mart_version))
###if(!is.null(args$mart_grch))
###{
###    print(sprintf("GRCh: %s", args$mart_grch))
###    mart <- biomaRt::useEnsembl(biomart="ensembl", GRCh=as.numeric(args$mart_grch), version=as.numeric(args$mart_version), dataset=args$mart_dataset)
###} else
###{
###    mart <- biomaRt::useEnsembl(biomart="ensembl", version=as.numeric(args$mart_version), dataset=args$mart_dataset)
###}

#t2g <- biomaRt::getBM(attributes = c("ensembl_transcript_id", "ensembl_gene_id"), mart = mart)
#t2g <- dplyr::rename(t2g, target_id = ensembl_transcript_id,
#  ens_gene = ensembl_gene_id)


apply(cond.pairs, 1, function(conds)
      {
          c1 <- conds[1]
          c2 <- conds[2]
          p.data.loc <- subset(p.data, condition == c1 | condition == c2)
          p.data.loc$condition <- factor(p.data.loc$condition)

          #pattern = paste0(paste0(p.data.loc$sample, collapse="|"))
          pattern = paste0("^", p.data.loc$sample, "$", collapse="|")

          #print(pattern)
          #print(p.data.loc)

          print(args$base.dir)
          print(pattern)
          print(p.data.loc)
          print(grep(pattern, list.files(args$base.dir)))
          print(list.files(args$base.dir))

          #print("0==========")
          #print(args$base.dir)
          #print(p.data.loc)
          #print(pattern)
          #print(list.files(args$base.dir))

          rownames(p.data.loc) <- p.data.loc$sample
          p.data.loc <- p.data.loc[list.files(args$base.dir), ]
          #print("-------------------")
          #print(list.files(args$base.dir))
          #print(p.data.loc)

            
          bg <- ballgown(dataDir = args$base.dir,
                    samplePattern = pattern,
                    pData = p.data.loc)
          print(bg)

          results_transcripts <- stattest(bg,
                                feature="transcript",
                                covariate="condition",
                                getFC=TRUE, meas="FPKM")

          results_genes <- stattest(bg,
                                feature="gene",
                                covariate="condition",
                                getFC=TRUE, meas="FPKM")

          results_transcripts$TRANSCRIPT.ID <- ballgown::transcriptNames(bg)
          results_transcripts$GENE.ID <- ballgown::geneIDs(bg)

          results_transcripts <- results_transcripts[, c("GENE.ID", "TRANSCRIPT.ID", "fc", "pval", "qval")]

          print(head(results_transcripts))
          results_genes <- results_genes[, c("id", "fc", "pval", "qval")]

          colnames(results_transcripts) <- c("GENE.ID", "TRANSCRIPT.ID", "log2FC", "RAW.PVAL", "ADJ.PVAL")
          colnames(results_genes) <- c("GENE.ID", "log2FC", "RAW.PVAL", "ADJ.PVAL")

          results_transcripts <- subset(results_transcripts, is.finite(RAW.PVAL))
          results_genes <- subset(results_genes, is.finite(RAW.PVAL))

          #o.file <- file.path(args$out.dir, paste0(c1, ".vs.", c2))
          o.file <- file.path(args$out.dir, "ballgown.out")
          o.file2 <- file.path(args$out.dir, "ballgown_transcripts.out")

          write.table(results_genes, o.file, sep="\t", quote=F, row.names=F)
          write.table(results_transcripts, o.file2, sep="\t", quote=F, row.names=F)

          return(0)
          #print(p.data.loc)
          #sample.ids <- 
          #print(c1)
          #print(c2)
      })
