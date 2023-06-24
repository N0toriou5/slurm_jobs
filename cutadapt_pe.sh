#! /bin/bash

#####################################################

#SBATCH --job-name=cutadapt

#SBATCH --output=/dev/null

#SBATCH --partition=cpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem=16G

#SBATCH --time=1-00:00:00

######################################################

# README

# rename this file as .q to be used as queue file
# parallel -kj1 'sbatch --parsable --export=SAMPLENAME={1},SAMPLEGLOB={2},SAMPLEDIR={3} ~/queues/cutadapt_pe.q' ::: S{1..4} :::+ S{23..26} ::: ./reads >> jobs
# parallel -kj1 'sbatch --parsable --export=SAMPLENAME={},SAMPLEGLOB={}_,SAMPLEDIR=reads ~/queues/cutadapt_pe.q' ::: S{1..4} >> jobs
# tail -n+2 SampleAnnot.tsv | cut -f1 | parallel -kj1 'sbatch --parsable --export=SAMPLENAME={},SAMPLEGLOB={}_,SAMPLEDIR=reads ~/queues/cutadapt_pe.q' >> jobs

# exchange '-q 20' for '--nextseq-trim 20' when running NextSeq / NovaSeq data with 2-colour chemistry

# Generic Illumina adapters:
#  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
#  -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \

######################################################

# MODULES

source ~/bin/miniconda3/etc/profile.d/conda.sh
conda activate cutadapt

######################################################

tmp=`pwd -P | sed 's:/working/:/scratch/:;s:$:/reads:'`
mkdir -p $tmp

mkdir -p "trimmed"

R1="${SAMPLENAME}_1"
R1FIFO="${tmp}/${R1}.fifo"
[[ -f ${R1FIFO} ]] && rm ${R1FIFO}
mkfifo ${R1FIFO}

R2="${SAMPLENAME}_2"
R2FIFO="${tmp}/${R2}.fifo"
[[ -f ${R2FIFO} ]] && rm ${R2FIFO}
mkfifo ${R2FIFO}

zcat ${SAMPLEDIR}/*${SAMPLEGLOB}_*R1*.fastq.gz > ${R1FIFO} &
zcat ${SAMPLEDIR}/*${SAMPLEGLOB}_*R2*.fastq.gz > ${R2FIFO} &

cutadapt \
  -j 4 \
  -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
  -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
  -n 1 \
  -m 27 \
  --nextseq-trim 20 \
  --max-n 0 \
  --max-ee 1 \
  -o "trimmed/${R1}.fastq.gz" \
  -p "trimmed/${R2}.fastq.gz" \
  ${R1FIFO} \
  ${R2FIFO} \
> "trimmed/${SAMPLENAME}.cutadapt.log"

rm ${R1FIFO} ${R2FIFO}
