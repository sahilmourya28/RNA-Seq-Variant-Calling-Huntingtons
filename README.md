## RNA-Seq Based Variant Calling in Huntington’s Disease (Mouse Model Q175)

### Project Overview
This project presents an end-to-end RNA-Seq analysis and variant calling pipeline performed on a Huntington’s disease (HD) mouse model (Q175) of 6 months.

The objective of this study was to:
- Analyze transcriptomic changes using RNA-Seq data
- Identify differentially expressed genes (DEGs) and pathway enrichment analysis 
- Perform variant calling from RNA-Seq aligned BAM files to find INDELS and SNP AND Functionally mutated genes.
- Understand biological pathways affected in disease condition

---

## Biological Background
Huntington’s disease is a progressive neurodegenerative disorder caused by CAG repeat expansion in the HTT gene, leading to neuronal degeneration, especially in the striatum.

RNA-Seq helps in:
- Studying gene expression changes
- Detecting transcript-level variants
- Understanding disease-associated pathways

---
### Datasets Used : https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=gse65774 (6 months datasets of straitum brain tissue 4 Q20 VS 4 Q175)

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

# RNA-Seq Pipeline Commands (Used in Project)

---

##  1. FastQC (Quality Check)

```bash
fastqc SRR1795105_1.fastq.gz SRR1795105_2.fastq.gz
```

---

##  2. fastp (Adapter Trimming & Filtering)

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

##  3. HISAT2 Indexing (mm10 Genome)

```bash
hisat2-build \
  GCF_000001635.26_GRCm38.p6_genomic.fna \
  mm10_refseq
```

---

##  4. HISAT2 Alignment

```bash
hisat2 -p 4 --dta \
  -x /mnt/d/rawdata/refgenome/mm10/mm10_refseq \
  -1 SRR1795105_1.trimmed.fastq \
  -2 SRR1795105_2.trimmed.fastq \
  -S Control1.sam
```

---

##  5. SAM → Sorted BAM Conversion

```bash
samtools view -@ 4 -bS Control1.sam | samtools sort -@ 4 -o Control1.sorted.bam
```

---

##  6. BAM Indexing

```bash
samtools index Control1.sorted.bam
```

---

##  7. Remove SAM (to save space)

```bash
rm Control1.sam
```

---

##  8. Gene Counting (featureCounts)

```bash
featureCounts \
  -a genes.gtf \
  -o gene_counts.txt \
  Control1.sorted.bam Control2.sorted.bam Control3.sorted.bam Control4.sorted.bam \
  Q175-1.sorted.bam Q175-2.sorted.bam Q175-3.sorted.bam Q175-4.sorted.bam
```


# Variant Calling Pipeline (RNA-Seq Based)

This pipeline performs variant discovery from RNA-Seq aligned BAM files followed by filtering, functional annotation, and pathway analysis.

---

##  Working Directory

```bash
/mnt/d/rawdata/variant_calling
```

---

##  Input Files

* Sorted BAM files:

```
Control1.sorted.bam
Control2.sorted.bam
Control3.sorted.bam
Control4.sorted.bam
Q175-1.sorted.bam
Q175-2.sorted.bam
Q175-3.sorted.bam
Q175-4.sorted.bam
```

* Reference genome:

```
/mnt/d/rawdata/refgenome/mm10/GCF_000001635.26_GRCm38.p6_genomic.fna
```

---

## Variant Calling

```bash
bcftools mpileup --threads 6 \
-f /mnt/d/rawdata/refgenome/mm10/GCF_000001635.26_GRCm38.p6_genomic.fna \
Control1.sorted.bam Control2.sorted.bam Control3.sorted.bam Control4.sorted.bam \
Q175-1.sorted.bam Q175-2.sorted.bam Q175-3.sorted.bam Q175-4.sorted.bam \
| bcftools call -mv -Ov -o variants.vcf
```

---

## Variant Filtering

```bash
bcftools filter -i 'QUAL>30 && DP>10' variants.vcf -o filtered_variants.vcf
```

---

## SNP and INDEL Separation

```bash
bcftools view -v snps filtered_variants.vcf -o snps.vcf
bcftools view -v indels filtered_variants.vcf -o indels.vcf
```

---

## Genotype Extraction

```bash
bcftools query -f '%CHROM\t%POS\t[%GT\t]\n' filtered_variants.vcf > genotypes.txt
```

---

## Q175 Specific Variant Identification

```bash
awk '($3=="0/0" && $4=="0/0" && $5=="0/0" && $6=="0/0" && ($7!="0/0" || $8!="0/0" || $9!="0/0" || $10!="0/0"))' genotypes.txt > q175_specific_variants.txt
```

---

## Variant Annotation (SnpEff)

```bash
java -Xmx6g -jar $CONDA_PREFIX/share/snpeff*/snpEff.jar \
GRCm38.99 filtered_variants.vcf > annotated_variants.vcf
```

---

# Functional Variant Extraction

```bash
grep -Ei "missense_variant|frameshift_variant|stop_gained|splice" annotated_variants.vcf > functional_variants.vcf
```

---

## Mutated Gene Extraction

```bash
grep -v "^#" functional_variants.vcf | cut -f8 | grep ANN | sed 's/.*ANN=//' | cut -d"|" -f4 | sort | uniq > mutated_genes.txt
```

---

## Pathway Enrichment Analysis

* Tool used: Enrichr
* Input:

```
mutated_genes.txt
```

* Databases:

```
KEGG
Reactome
WikiPathways
```

---

# Final Outputs

```
variants.vcf
filtered_variants.vcf
snps.vcf
indels.vcf
genotypes.txt
q175_specific_variants.txt
annotated_variants.vcf
functional_variants.vcf
mutated_genes.txt
```

