#!/bin/bash
#SBATCH --job-name=parallel_star_junctions
#SBATCH --chdir=/RNA-seq_results/fastq/
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00
#SBATCH --mem=36G
#SBATCH --partition=cpu
#SBATCH --array=1-75
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=somemail@domain.com
#SBATCH --output=run_%A_%a.o
#SBATCH --error=run_%A_%a.e

THREADS=${SLURM_CPUS_PER_TASK}
FILES=(ls /RNA-seq_results/fastq/*_1.merged.fastq.gz)    
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
echo ${FILE}
filename=$(basename ${FILE} _1.merged.fastq.gz)
echo $filename

ml purge
ml STAR/2.7.9a-GCC-10.3.0

IDX="/genomes/SARS-CoV-2_STAR_index"
GTF="/genomes/Sars_cov_2.ASM985889v3.101.gtf"

STAR \
--runThreadN ${THREADS} \
--genomeDir $IDX \
--readFilesIn ${filename}_1.merged.fastq.gz ${filename}_2.merged.fastq.gz \
--readFilesCommand zcat \
--outFileNamePrefix bams/${filename}_ \
--outSAMtype BAM Unsorted \
--outFilterType BySJout \
--outFilterMultimapNmax 20 \
--alignSJoverhangMin 8 \
--outSJfilterOverhangMin 12 12 12 12 \
--outSJfilterCountUniqueMin 1 1 1 1 \
--outSJfilterCountTotalMin 1 1 1 1 \
--outSJfilterDistToOtherSJmin 0 0 0 0 \
--outFilterMismatchNmax 999 \
--outFilterMismatchNoverReadLmax 0.04\
--scoreGapNoncan -4 \
--scoreGapATAC -4 \
--chimOutType WithinBAM HardClip \
--chimScoreJunctionNonGTAG 0 \
--alignSJstitchMismatchNmax -1 -1 -1 -1 \
--alignIntronMin 20 \
--alignIntronMax 1000000 \
--alignMatesGapMax 1000000
