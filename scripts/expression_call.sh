#!/bin/bash

outDir=$1
pData=$2
nthreads=$3
indexAppendix=$4

mkdir -p $outDir/diff_exp_outs

( [ -f "$outDir/diff_exp_outs/DESeq.out" ] && echo "[INFO] [DESeq] $outDir/diff_exp_outs/DESeq.out already exists, skipping.."$'\n' ) || ( echo "[INFO] [DESeq] ["`date "+%Y/%m/%d-%H:%M:%S"`"] /home/scripts/de_rseq_new.R $outDir/COUNTS/exprs.txt $outDir/COUNTS/p_data.txt $outDir/COUNTS/f_data.txt DESeq $outDir/diff_exp_outs/DESeq.out" && /home/scripts/de_rseq_new.R $outDir/COUNTS/exprs.txt $outDir/COUNTS/p_data.txt $outDir/COUNTS/f_data.txt DESeq $outDir/diff_exp_outs/DESeq.out && echo "[INFO] [DESeq] ["`date "+%Y/%m/%d-%H:%M:%S"`"] Finished"$'\n' )


( [ -f "$outDir/diff_exp_outs/edgeR.out" ] && echo "[INFO] [edgeR] $outDir/diff_exp_outs/edgeR.out already exists, skipping.."$'\n' ) || ( echo "[INFO] [edgeR] ["`date "+%Y/%m/%d-%H:%M:%S"`"] /home/scripts/de_rseq_new.R $outDir/COUNTS/exprs.txt out/COUNTS/p_data.txt $outDir/COUNTS/f_data.txt edgeR $outDir/diff_exp_outs/edgeR.out" && /home/scripts/de_rseq_new.R $outDir/COUNTS/exprs.txt $outDir/COUNTS/p_data.txt $outDir/COUNTS/f_data.txt edgeR $outDir/diff_exp_outs/edgeR.out && echo "[INFO] [edgeR] ["`date "+%Y/%m/%d-%H:%M:%S"`"] Finished"$'\n' )


( [ -f "$outDir/diff_exp_outs/limma.out" ] && echo "[INFO] [limma] $outDir/diff_exp_outs/limma.out already exists, skipping.."$'\n' ) || ( echo "[INFO] [edgeR] ["`date "+%Y/%m/%d-%H:%M:%S"`"] /home/scripts/de_rseq_new.R $outDir/COUNTS/exprs.txt $outDir/COUNTS/p_data.txt $outDir/COUNTS/f_data.txt limma $outDir/diff_exp_outs/limma.out" && /home/scripts/de_rseq_new.R $outDir/COUNTS/exprs.txt $outDir/COUNTS/p_data.txt $outDir/COUNTS/f_data.txt limma $outDir/diff_exp_outs/limma.out && echo "[INFO] [limma] ["`date "+%Y/%m/%d-%H:%M:%S"`"] Finished"$'\n' )


( [ -f "$outDir/diff_exp_outs/sleuth.out" ] && echo "[INFO] [Sleuth] $outDir/diff_exp_outs/sleuth.out already exists, skipping.."$'\n' ) || ( echo "[INFO] [Sleuth] ["`date "+%Y/%m/%d-%H:%M:%S"`"] /home/scripts/run_sleuth.R --base.dir $outDir/KALLISTO/alignment --p.data $pData --condition.pairs /home/data/cond.pairs --out.dir $outDir/diff_exp_outs --num.cores $nthreads --tx2gene /home/indices/R/$indexAppendix/tx2gene.RData" && /home/scripts/run_sleuth.R --base.dir $outDir/KALLISTO/alignment --p.data $pData --condition.pairs /home/data/cond.pairs --out.dir $outDir/diff_exp_outs --num.cores $nthreads --tx2gene /home/indices/R/$indexAppendix/tx2gene.RData && echo "[INFO] [Sleuth] ["`date "+%Y/%m/%d-%H:%M:%S"`"] Finished"$'\n' )


( [ -f "$outDir/diff_exp_outs/ballgown.out" ] && echo "[INFO] [Ballgown] $outDir/diff_exp_outs/ballgown.out already exists, skipping.."$'\n' ) || ( echo "[INFO] [Ballgown] ["`date "+%Y/%m/%d-%H:%M:%S"`"] /home/scripts/run_ballgown.R --base.dir $outDir/STRINGTIE --p.data $pData --condition.pairs /home/data/cond.pairs --out.dir $outDir/diff_exp_outs --tx2gene /home/indices/R/$indexAppendix/tx2gene.RData" && /home/scripts/run_ballgown.R --base.dir $outDir/STRINGTIE --p.data $pData --condition.pairs /home/data/cond.pairs --out.dir $outDir/diff_exp_outs --tx2gene /home/indices/R/$indexAppendix/tx2gene.RData && echo "[INFO] [Ballgown] ["`date "+%Y/%m/%d-%H:%M:%S"`"] Finished"$'\n' )
