#!/usr/local/bin/Rscript
library(argparse)
library(sleuth)

parser <- ArgumentParser()

parser$add_argument('--base.dir', required=TRUE)
parser$add_argument('--p.data', required=TRUE)
parser$add_argument('--condition.pairs', required=TRUE)
parser$add_argument('--out.dir', required=TRUE)
parser$add_argument('--tx2gene', required=TRUE)
parser$add_argument('--num.cores', default=1, type="integer")


args <- parser$parse_args(commandArgs(trailingOnly=T))


p.data <- read.csv(args$p.data, sep="\t")

cond.pairs <- read.csv(args$condition.pairs, sep="\t", header=F)


load(args$tx2gene)

tx2gene$target_id <- rownames(tx2gene)
tx2gene <- dplyr::rename(tx2gene, ens_gene=gene_id)
tx2gene <- tx2gene[, c("target_id", "ens_gene")]

apply(cond.pairs, 1, function(conds)
      {
          c1 <- conds[1]
          c2 <- conds[2]
          p.data.loc <- subset(p.data, condition == c1 | condition == c2)

          num.cores <- min(args$num.cores, nrow(p.data.loc))
          options(mc.cores=num.cores)
          print(sprintf("num.cores: %d", num.cores))

          p.data.loc$path <- file.path(args$base.dir, p.data.loc$sample)


          print("reading gene data...")
          so_gene <- sleuth_prep(p.data.loc, extra_bootstrap_summary = TRUE,target_mapping=tx2gene,
                            gene_mode=T, aggregation_column='ens_gene',
                            num_cores=num.cores,
                            transformation_function=function(x) log2(x + 0.5))
          print("finished reading gene data...")

          print("finished reading data...")

          so_gene <- sleuth_fit(so_gene, ~condition, 'full')
          so_gene <- sleuth_fit(so_gene, ~1, 'reduced')
          so_gene <- sleuth_lrt(so_gene, 'reduced', 'full')

          sleuth_table_gene <- sleuth_results(so_gene, 'reduced:full', 'lrt', show_all = FALSE)#,
                                         #pval_aggregate=TRUE)
          #wt.table <- sleuth_results(so_gene, 'condition', 'wt', show_all=F,
          #                             pval_aggregate=F)

          o.file <- file.path(args$out.dir, "sleuth.out")
          print(o.file)

          sleuth_table_gene <- sleuth_table_gene[, c("target_id", "test_stat", "pval", "qval")]
          colnames(sleuth_table_gene) <- c("GENE.ID", "log2FC", "RAW.PVAL", "ADJ.PVAL")

          #wt.table <- wt.table[c("target_id", "b", "pval", "qval")]
          #colnames(wt.table) <- c("GENE.ID", "log2FC", "RAW.PVAL", "ADJ.PVAL")
          write.table(sleuth_table_gene, o.file, sep="\t", quote=F, row.names=F)
          #write.table(wt.table, file.path(args$out.dir, "sleuthWald.out"), sep="\t", quote=F, row.names=F)


          #############################

          #so_gene <- sleuth_prep(p.data.loc, extra_bootstrap_summary = TRUE,
          #                  target_mapping=t2g,
          #                  transformation_function=function(x) log2(x + 0.5)
          #                  )
          so_gene <- sleuth_prep(p.data.loc, extra_bootstrap_summary = TRUE,
                            target_mapping=tx2gene,
                            transformation_function=function(x) log2(x + 0.5)
                            )

          so_gene <- sleuth_fit(so_gene, ~condition, 'full')
          so_gene <- sleuth_fit(so_gene, ~1, 'reduced')
          so_gene <- sleuth_lrt(so_gene, 'reduced', 'full')
          #so_gene <- sleuth_wt(so_gene, which_beta='condition', which_model='full')


          sleuth_table_gene <- sleuth_results(so_gene, 'reduced:full', 'lrt', show_all = F,
                                         pval_aggregate=FALSE)

          #wt.table <- sleuth_results(so_gene, 'condition', 'wt', show_all=F,
          #                             pval_aggregate=F)

          sleuth_table_gene <- sleuth_table_gene[, c("ens_gene", "target_id", "test_stat", "pval", "qval")]
          sleuth_table_gene <- subset(sleuth_table_gene, is.finite(qval))
          colnames(sleuth_table_gene) <- c("GENE.ID", "TRANSCRIPT.ID", "log2FC", "RAW.PVAL", "ADJ.PVAL")

          #wt.table <- wt.table[c("ens_gene", "target_id", "b", "pval", "qval")]
          #colnames(wt.table) <- c("GENE.ID", "TRANSCRIPT.ID", "log2FC", "RAW.PVAL", "ADJ.PVAL")

          o.file2 <- file.path(args$out.dir, "sleuth_transcripts.out")
          write.table(sleuth_table_gene, o.file2, sep="\t", quote=F, row.names=F)
          #write.table(wt.table, file.path(args$out.dir, "sleuthWald_transcripts.out"), sep="\t", quote=F, row.names=F)


          print("------")


          return(0)
      })
