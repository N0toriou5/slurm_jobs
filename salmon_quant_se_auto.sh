#! /bin/bash

#####################################################

#SBATCH --job-name=salmon

#SBATCH --output=/dev/null

#SBATCH --partition=cpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G

#SBATCH --time=1-00:00:00

######################################################

# README

# tail -n+2 SampleAnnot.txt | cut -f1 | parallel -kj1 'sbatch --parsable --export=R1=trimmed/{}_1.fastq.gz,IDX=/resources/Genomes/Homo_sapiens/GRCh38/Index/salmon/GRCh38_cDNA_ncRNA_k25 ~/queues/salmon_quant_se_auto.q' >> jobs
# rename this file as ".q" to schedule it in a queue list

######################################################

# MODULES

module load SAMtools/1.13-GCC-10.2.0 Salmon/1.4.0-gompi-2020b

source ~/bin/miniconda3/etc/profile.d/conda.sh
conda activate base

######################################################

tmp=`pwd -P | sed 's:/working/:/scratch/:'`
mkdir -p salmon $tmp/salmon

f_base="${R1##*/}"
f_dir="${R1%$f_base}"
f_base="${f_base%%.*}"

salmon quant \
  -p 8 \
  -i $IDX \
  -l A \
  -r $R1 \
  --softclip \
  --softclipOverhangs \
  --seqBias \
  --gcBias \
  -o "salmon/${f_base}"
