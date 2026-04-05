# RNA-Seq-Variant-Calling-Huntingtons
End-to-end RNA-Seq analysis and variant calling pipeline for Huntington’s disease mouse model (Q175), including differential expression and pathway enrichment analysis.
### RNA-Seq Variant Calling in Huntington’s Disease (Mouse Model)

### Project Overview
This project presents an end-to-end RNA-Seq analysis and variant calling pipeline performed on a Huntington’s disease (HD) mouse model (Q175).

The objective of this study was to:
- Analyze transcriptomic changes using RNA-Seq data
- Identify differentially expressed genes (DEGs)
- Perform variant calling from RNA-Seq aligned BAM files
- Understand biological pathways affected in disease condition

---

## Biological Background
Huntington’s disease is a progressive neurodegenerative disorder caused by CAG repeat expansion in the HTT gene, leading to neuronal degeneration, especially in the striatum.

RNA-Seq helps in:
- Studying gene expression changes
- Detecting transcript-level variants
- Understanding disease-associated pathways

---

## Workflow Overview

RNA-Seq Pipeline:
FASTQ → FastQC → fastp → HISAT2 → SAMtools → featureCounts → DESeq2

Variant Calling Pipeline:
BAM → bcftools → Filtering → Functional Analysis → Pathway Enrichment

---
## Tools Used

| Step | Tool |
|------|------|
| Quality Control | FastQC |
| Trimming | fastp |
| Alignment | HISAT2 |
| BAM Processing | SAMtools |
| Counting | featureCounts |
| Differential Expression | DESeq2 |
| Variant Calling | bcftools |

---

## 🧬 RNA-Seq Pipeline (Commands Used)

### 1. Quality Control
### bash
fastqc SRR1795105_1.fastq.gz SRR1795105_2.fastq.gz

### 2. Trimming
fastp \
-i SRR1795105_1.fastq.gz \
-I SRR1795105_2.fastq.gz \
-o SRR1795105_1.trimmed.fastq \
-O SRR1795105_2.trimmed.fastq \
--detect_adapter_for_pe \
--thread 8 \
--html SRR1795105_fastp.html \
--json SRR1795105_fastp.json

### 3. Reference Indexing
hisat2-build \
GCF_000001635.26_GRCm38.p6_genomic.fna \
mm10_refseq

### 4. Alignment
hisat2 -p 4 --dta \
-x /mnt/d/rawdata/refgenome/mm10/mm10_refseq \
-1 SRR1795105_1.trimmed.fastq \
-2 SRR1795105_2.trimmed.fastq \
-S Control1.sam

### 5. SAM to BAM + Sorting
samtools view -@ 4 -bS Control1.sam | \
samtools sort -@ 4 -o Control1.sorted.bam

### 6. Indexing
samtools index Control1.sorted.bam

### 7. Gene Counting
featureCounts \
-a genes.gtf \
-o gene_counts.txt \
Control1.sorted.bam Control2.sorted.bam Control3.sorted.bam Control4.sorted.bam \
Q175-1.sorted.bam Q175-2.sorted.bam Q175-3.sorted.bam Q175-4.sorted.bam

### Variant Calling Pipeline
# Variant Calling
bcftools mpileup -f reference.fa *.bam | \
bcftools call -mv -Ov -o variants.vcf

# Variant Filtering
bcftools filter -i 'QUAL>30 && DP>10' variants.vcf -o filtered_variants.vcf

