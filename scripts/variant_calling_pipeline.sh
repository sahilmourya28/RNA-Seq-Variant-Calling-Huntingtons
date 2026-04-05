# Variant Calling Pipeline (RNA-Seq Based)

# Step 1: Variant Calling
bcftools mpileup --threads 6 \
-f /mnt/d/rawdata/refgenome/mm10/GCF_000001635.26_GRCm38.p6_genomic.fna \
Control1.sorted.bam Control2.sorted.bam Control3.sorted.bam Control4.sorted.bam \
Q175-1.sorted.bam Q175-2.sorted.bam Q175-3.sorted.bam Q175-4.sorted.bam \
| bcftools call -mv -Ov -o variants.vcf

# Step 2: Variant Filtering
bcftools filter -i 'QUAL>30 && DP>10' variants.vcf -o filtered_variants.vcf

# Step 3: SNP and INDEL Separation
bcftools view -v snps filtered_variants.vcf -o snps.vcf
bcftools view -v indels filtered_variants.vcf -o indels.vcf

# Step 4: Genotype Extraction
bcftools query -f '%CHROM\t%POS\t[%GT\t]\n' filtered_variants.vcf > genotypes.txt

# Step 5: Q175 Specific Variant Identification
awk '($3=="0/0" && $4=="0/0" && $5=="0/0" && $6=="0/0" && ($7!="0/0" || $8!="0/0" || $9!="0/0" || $10!="0/0"))' genotypes.txt > q175_specific_variants.txt

# Step 6: Variant Annotation (SnpEff)
java -Xmx6g -jar $CONDA_PREFIX/share/snpeff*/snpEff.jar \
GRCm38.99 filtered_variants.vcf > annotated_variants.vcf

# Step 7: Functional Variant Extraction
grep -Ei "missense_variant|frameshift_variant|stop_gained|splice" annotated_variants.vcf > functional_variants.vcf

# Step 8: Mutated Gene Extraction
grep -v "^#" functional_variants.vcf | cut -f8 | grep ANN | sed 's/.*ANN=//' | cut -d"|" -f4 | sort | uniq > mutated_genes.txt
