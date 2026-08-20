#!/bin/bash

# ============================================================
# DNA-seq Variant Calling Pipeline - NA12878 chr11
# Tools: GATK, SAMtools, BCFtools
# ============================================================

set -euo pipefail

PROJECT=~/NGS-internship/DNAseq_Variant_Calling
REFERENCE=${PROJECT}/reference/Homo_sapiens_assembly38.fasta
BAM=${PROJECT}/data/NA12878.bam
RESULTS=${PROJECT}/results

mkdir -p "${RESULTS}"

# ------------------------------------------------------------
# 1. Validate BAM
# ------------------------------------------------------------

gatk ValidateSamFile \
    -I "${BAM}" \
    --MODE SUMMARY

# ------------------------------------------------------------
# 2. Generate BAM index if required
# ------------------------------------------------------------

samtools index "${BAM}"

# ------------------------------------------------------------
# 3. GATK HaplotypeCaller - chr11
# ------------------------------------------------------------

gatk HaplotypeCaller \
    -R "${REFERENCE}" \
    -I "${BAM}" \
    -L chr11 \
    -O "${RESULTS}/NA12878_chr11.g.vcf.gz" \
    -ERC GVCF

# ------------------------------------------------------------
# 4. Genotype GVCF
# ------------------------------------------------------------

gatk GenotypeGVCFs \
    -R "${REFERENCE}" \
    -V "${RESULTS}/NA12878_chr11.g.vcf.gz" \
    -O "${RESULTS}/NA12878_chr11.vcf.gz"

# ------------------------------------------------------------
# 5. SNP hard filtering
# ------------------------------------------------------------

gatk VariantFiltration \
    -R "${REFERENCE}" \
    -V "${RESULTS}/NA12878_chr11.vcf.gz" \
    --filter-name "SNP_HARD_FILTER" \
    --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
    -O "${RESULTS}/NA12878_chr11.filtered.vcf.gz"

# ------------------------------------------------------------
# 6. INDEL hard filtering
# ------------------------------------------------------------

gatk VariantFiltration \
    -R "${REFERENCE}" \
    -V "${RESULTS}/NA12878_chr11.filtered.vcf.gz" \
    --filter-name "INDEL_HARD_FILTER" \
    --filter-expression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" \
    -O "${RESULTS}/NA12878_chr11.final_filtered.vcf.gz"

# ------------------------------------------------------------
# 7. Index final VCF
# ------------------------------------------------------------

bcftools index \
    "${RESULTS}/NA12878_chr11.final_filtered.vcf.gz"

# ------------------------------------------------------------
# 8. Extract PASS variants
# ------------------------------------------------------------

bcftools view \
    -f PASS \
    "${RESULTS}/NA12878_chr11.final_filtered.vcf.gz" \
    -Oz \
    -o "${RESULTS}/NA12878_chr11.PASS.vcf.gz"

bcftools index "${RESULTS}/NA12878_chr11.PASS.vcf.gz"

# ------------------------------------------------------------
# 9. Variant statistics
# ------------------------------------------------------------

bcftools stats \
    "${RESULTS}/NA12878_chr11.final_filtered.vcf.gz" \
    > "${RESULTS}/NA12878_chr11.final.stats.txt"

# ------------------------------------------------------------
# 10. Export variant table
# ------------------------------------------------------------

bcftools query \
    -f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\t%FILTER\t[%GT]\t[%DP]\t[%GQ]\n' \
    "${RESULTS}/NA12878_chr11.final_filtered.vcf.gz" \
    > "${RESULTS}/NA12878_chr11.final_variants.tsv"

echo "=============================================="
echo "NA12878 chr11 variant calling completed"
echo "=============================================="
echo "Final VCF:"
echo "${RESULTS}/NA12878_chr11.final_filtered.vcf.gz"
echo
echo "PASS variants:"
bcftools view -H -f PASS \
    "${RESULTS}/NA12878_chr11.final_filtered.vcf.gz" | wc -l
