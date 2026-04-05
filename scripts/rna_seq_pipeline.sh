# RNA-Seq Pipeline Script
##### for running bash
#!/bin/bash
set -e #####(stop pipeline if fail in bash )

# RNA-Seq Pipeline Script

# Step 1: Quality Control (FastQC)
fastqc SRR1795105_1.fastq.gz SRR1795105_2.fastq.gz

# Step 2: Adapter Trimming & Quality Filtering (fastp)
fastp \
  -i SRR1795105_1.fastq.gz \
  -I SRR1795105_2.fastq.gz \
  -o SRR1795105_1.trimmed.fastq \
  -O SRR1795105_2.trimmed.fastq \
  --detect_adapter_for_pe \
  --thread 4 \
  --html SRR1795105_fastp.html \
  --json SRR1795105_fastp.json

# Step 3: HISAT2 Indexing (mm10 Genome)
hisat2-build \
  GCF_000001635.26_GRCm38.p6_genomic.fna \
  mm10_refseq

# Step 4: Alignment (HISAT2)
hisat2 -p 4 --dta \
  -x /mnt/d/rawdata/refgenome/mm10/mm10_refseq \
  -1 SRR1795105_1.trimmed.fastq \
  -2 SRR1795105_2.trimmed.fastq \
  -S Control1.sam

# Step 5: SAM → Sorted BAM Conversion
samtools view -@ 4 -bS Control1.sam | samtools sort -@ 4 -o Control1.sorted.bam

# Step 6: BAM Indexing
samtools index Control1.sorted.bam

# Step 7: Remove SAM (to save space)
rm Control1.sam

# Step 8: Gene Counting (featureCounts)
featureCounts \
  -a genes.gtf \
  -o gene_counts.txt \
  Control1.sorted.bam Control2.sorted.bam Control3.sorted.bam Control4.sorted.bam \
  Q175-1.sorted.bam Q175-2.sorted.bam Q175-3.sorted.bam Q175-4.sorted.bam
