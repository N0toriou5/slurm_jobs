#! /bin/bash

#####################################################

#SBATCH --job-name=trimpe

#SBATCH --output=/dev/null

#SBATCH --partition=cpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

#SBATCH --time=0-4:0:0

######################################################

# Expects a file submitted as an environmental variable ...
# parallel 'sbatch --export=TASKFILE="{}" <.q>' ::: <>

ml Java/1.7.0_80 Trimmomatic/0.36-Java-1.7.0_80

f=$TASKFILE
f_base="${f##*/}"
f_dir="${f%$f_base}"
f_base="${f_base%_*}"

java -jar $[<VARIABLE_NAME>]/trimmomatic-0.36.jar \
    PE \
    -threads 4 \
    -phred33 \
    "$f" \
    "$f_dir$f_base"_2.fastq.gz \
    "$f_base"_1.trim.fastq.gz \
    /dev/null \
    "$f_base"_2.trim.fastq.gz \
    /dev/null \
    SLIDINGWINDOW:3:20 \
    ILLUMINACLIP:../adapters:2:40:10:2:true \
    MINLEN:27 \
&> "$f_base".trim.log 
