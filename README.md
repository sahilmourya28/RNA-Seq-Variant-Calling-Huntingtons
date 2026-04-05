## RNA-Seq Based Variant Calling in Huntington’s Disease (Mouse Model Q175)

### Project Overview
This project presents an end-to-end RNA-Seq analysis and variant calling pipeline performed on a Huntington’s disease (HD) mouse model (Q175) of 6 months.

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
Pathway Enrichment → GO, KEGG analysis, Cnet analysis using R 

Variant Calling Pipeline:
BAM → bcftools → Filtering → Functional Analysis → Pathway Enrichment(using dbs)

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

Perfect bhai 👍
Main tujhe **FINAL CLEAN COMMANDS (exact jo tumne use kiye)** de raha hoon — directly **README.md me daal sakta hai**.

---

# 🧬 RNA-Seq Pipeline Commands (Used in Project)

---

## 🔹 1. FastQC (Quality Check)

```bash
fastqc SRR1795105_1.fastq.gz SRR1795105_2.fastq.gz
```

---

## 🔹 2. fastp (Adapter Trimming & Filtering)

```bash
fastp \
  -i SRR1795105_1.fastq.gz \
  -I SRR1795105_2.fastq.gz \
  -o SRR1795105_1.trimmed.fastq \
  -O SRR1795105_2.trimmed.fastq \
  --detect_adapter_for_pe \
  --thread 4 \
  --html SRR1795105_fastp.html \
  --json SRR1795105_fastp.json
```

---

## 🔹 3. HISAT2 Indexing (mm10 Genome)

```bash
hisat2-build \
  GCF_000001635.26_GRCm38.p6_genomic.fna \
  mm10_refseq
```

---

## 🔹 4. HISAT2 Alignment

```bash
hisat2 -p 4 --dta \
  -x /mnt/d/rawdata/refgenome/mm10/mm10_refseq \
  -1 SRR1795105_1.trimmed.fastq \
  -2 SRR1795105_2.trimmed.fastq \
  -S Control1.sam
```

---

## 🔹 5. SAM → Sorted BAM Conversion

```bash
samtools view -@ 4 -bS Control1.sam | samtools sort -@ 4 -o Control1.sorted.bam
```

---

## 🔹 6. BAM Indexing

```bash
samtools index Control1.sorted.bam
```

---

## 🔹 7. Remove SAM (to save space)

```bash
rm Control1.sam
```

---

## 🔹 8. Gene Counting (featureCounts)

```bash
featureCounts \
  -a genes.gtf \
  -o gene_counts.txt \
  Control1.sorted.bam Control2.sorted.bam Control3.sorted.bam Control4.sorted.bam \
  Q175-1.sorted.bam Q175-2.sorted.bam Q175-3.sorted.bam Q175-4.sorted.bam
```

...

### Variant Calling Pipeline
### Variant Calling
'''bash 
bcftools mpileup -f reference.fa *.bam | \
bcftools call -mv -Ov -o variants.vcf
'''

### Variant Filtering
'''bash
bcftools filter -i 'QUAL>30 && DP>10' variants.vcf -o filtered_variants.vcf
'''

### Key Results
Total variants: 10882
SNPs: 10642
Indels: 240
Functional variants: 364
Mutated genes: 289
