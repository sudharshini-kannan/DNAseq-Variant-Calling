 # DNA-seq Variant Calling Workflow

## Overview

This repository contains a reproducible DNA sequencing (DNA-seq) variant calling workflow using standard NGS command-line tools and the GATK framework.

The workflow demonstrates the major stages of DNA-seq variant analysis, including:

- Quality control
- Read preprocessing
- Reference genome preparation
- Read alignment
- SAM/BAM processing
- BAM validation
- Variant calling
- SNP and INDEL filtering
- Variant quality assessment
- VCF processing
- Variant statistics
- Variant-level data extraction

The primary biological analysis was performed using the human NA12878 dataset, with variant calling restricted to chromosome 11 to make the analysis computationally feasible while retaining a realistic human variant-calling workflow.

---

# Workflow

```text
FASTQ
  |
  v
Quality Control
  |
  v
Read Preprocessing
  |
  v
Reference Genome
  |
  v
Read Alignment
  |
  v
SAM/BAM Processing
  |
  v
BAM Validation
  |
  v
GATK HaplotypeCaller
  |
  v
gVCF
  |
  v
Variant Calling
  |
  v
SNP / INDEL Filtering
  |
  v
Final Filtered VCF
  |
  v
Variant Statistics

Datasets

Multiple datasets were used in this project because different stages of an NGS workflow have different computational and analytical requirements.

The datasets were not combined. Each dataset was used independently for a specific purpose.

1. NA12878 Human Dataset
Purpose

NA12878 was selected as the primary dataset for human DNA-seq variant calling.

NA12878 is a well-characterized human reference sample that has been extensively used in genomic research and variant-calling benchmarking.

The dataset was used to demonstrate:

Human BAM inspection
BAM validation
Reference compatibility checking
GATK HaplotypeCaller
gVCF generation
Variant calling
SNP filtering
INDEL filtering
VCF quality assessment
Genotype analysis
Why NA12878?

NA12878 is particularly suitable for a variant-calling project because it is a widely studied human sample with extensive public genomic resources and benchmark datasets.

Using a well-characterized sample also makes the workflow easier to compare with established variant-calling methodologies.

2. Why Was Only Chromosome 11 Used?

A complete human genome contains approximately 3 billion bases.

Whole-genome alignment and variant calling require substantial:

CPU resources
RAM
Disk storage
Processing time

Therefore, chromosome 11 was selected as a representative human genomic region.

This allowed the complete variant-calling workflow to be executed from BAM validation through final variant filtering without requiring whole-genome computational resources.

The analysis should therefore be interpreted as a chromosome-specific variant-calling analysis, not a whole-genome callset.

3. E. coli Dataset

The E. coli dataset was used independently for demonstrating the read-alignment and BAM-processing components of the workflow.

E. coli has a much smaller genome than the human genome, making it computationally efficient for testing and validating alignment-related commands.

It was used for:

Reference genome preparation
Read alignment
SAM generation
BAM conversion
BAM sorting
BAM indexing
Alignment inspection
Why use a different organism?

The purpose of this dataset was computational efficiency.

A bacterial genome is several orders of magnitude smaller than the human genome. Therefore, alignment and BAM-processing operations can be tested rapidly without the computational cost associated with a complete human genome.

The E. coli dataset was kept separate from the human NA12878 analysis and was not used to generate the final human variant callset.

4. Additional Sequencing Dataset

An additional paired-end sequencing dataset was used for evaluating FASTQ quality-control and preprocessing procedures.

This dataset was processed independently using tools such as:

FastQC
fastp

The purpose was to evaluate sequencing read quality and demonstrate preprocessing operations before alignment.

The resulting files are not part of the final NA12878 variant-calling results.

Dataset Selection Strategy

The datasets were selected according to the requirements of each analytical stage.

Dataset	Main purpose
NA12878	Human DNA-seq variant calling
E. coli	Efficient alignment and BAM-processing analysis
Paired-end sequencing dataset	FASTQ quality control and preprocessing

This approach allows individual components of the NGS workflow to be evaluated independently while keeping the final biological analysis focused on the human NA12878 dataset.

Software

The workflow uses:

Linux / Ubuntu
Bash
FastQC
fastp
BWA
SAMtools
GATK
BCFtools
Conda

Main GATK version used:

GATK 4.6.2.0
Reference Genome

The human analysis used the hg38/GRCh38 reference:

Homo_sapiens_assembly38.fasta

Associated index files include:

Homo_sapiens_assembly38.fasta.fai
Homo_sapiens_assembly38.dict

The FASTA index was generated using:

samtools faidx Homo_sapiens_assembly38.fasta

The reference dictionary was generated for compatibility with GATK tools.

Chromosome 11 was verified to have a length of:

135,086,622 bp

 Step 1 — Quality Control

FASTQ sequencing reads were evaluated using FastQC.

Example:

fastqc \
    sample_R1.fastq.gz \
    sample_R2.fastq.gz \
    -o results/fastqc

FastQC provides quality information such as:

Per-base sequence quality
Per-sequence quality
GC content
Sequence duplication
Adapter contamination
Overrepresented sequences
Step 2 — Read Preprocessing

Paired-end sequencing reads were processed using fastp.

Typical processing includes:

Adapter removal
Quality filtering
Low-quality read removal
Generation of quality-control reports

Example:

fastp \
    -i sample_R1.fastq.gz \
    -I sample_R2.fastq.gz \
    -o sample_R1.trimmed.fastq.gz \
    -O sample_R2.trimmed.fastq.gz \
    -h results/fastp.html \
    -j results/fastp.json
Step 3 — Read Alignment

For datasets where FASTQ reads were available, reads were aligned against the appropriate reference genome.

For example, BWA-MEM can be used for paired-end alignment:

bwa mem \
    reference.fa \
    sample_R1.fastq.gz \
    sample_R2.fastq.gz \
    > sample.sam

SAM was converted to BAM:

samtools view -b sample.sam > sample.bam

The BAM file was sorted:

samtools sort \
    sample.bam \
    -o sample.sorted.bam

The sorted BAM was indexed:

samtools index sample.sorted.bam
Step 4 — BAM Validation

The NA12878 BAM file was validated using GATK:

gatk ValidateSamFile \
    -I data/NA12878.bam \
    --MODE SUMMARY

The validation result was:

No errors found

This confirmed that the BAM passed the structural validation performed by GATK.

Step 5 — BAM Inspection

The BAM file was inspected using SAMtools.

Chromosome-level alignment statistics were obtained using:

samtools idxstats data/NA12878.bam

For chromosome 11:

chr11    135086622    101003

Therefore, 101,003 reads were mapped to chromosome 11.

The BAM header was also checked to confirm reference compatibility:

samtools view -H data/NA12878.bam

The chromosome 11 entry matched:

SN:chr11
LN:135086622
Step 6 — Variant Calling with GATK

GATK HaplotypeCaller was used to identify candidate variants.

The analysis was restricted to chromosome 11.

The conceptual command was:

gatk HaplotypeCaller \
    -R reference/Homo_sapiens_assembly38.fasta \
    -I data/NA12878.bam \
    -L chr11 \
    -O results/NA12878_chr11.g.vcf.gz \
    -ERC GVCF

The output was a genomic VCF:

NA12878_chr11.g.vcf.gz

The gVCF contains genotype likelihood information used during variant calling.

Step 7 — Variant Call Generation

The gVCF was processed to generate a standard VCF containing variant records.

The resulting file was:

NA12878_chr11.vcf.gz

The initial variant set contained:

3,232 variant records

Variant composition:

SNPs      1,487
INDELs    1,746
MNPs          0
Others        0
Step 8 — SNP Filtering

SNPs were evaluated using hard-filtering criteria based on variant-quality annotations.

Variants failing the defined SNP filtering criteria were assigned:

SNP_HARD_FILTER

The initial SNP filtering removed:

28 SNP records
Step 9 — INDEL Filtering

INDELs were evaluated separately from SNPs.

This is important because SNPs and INDELs have different error characteristics and therefore require different quality thresholds.

Variants failing the INDEL filtering criteria were assigned:

INDEL_HARD_FILTER

The final filtering stage identified:

229 INDEL records

that failed the filtering criteria.

Step 10 — Final Filtered VCF

The final output was:

results/NA12878_chr11.final_filtered.vcf.gz

Filter status:

PASS               2,975
SNP_HARD_FILTER       28
INDEL_HARD_FILTER    229

Therefore:

Total records       3,232
PASS records        2,975
Filtered records      257
Step 11 — PASS Variant Analysis

PASS variants were extracted using BCFtools:

bcftools view \
    -f PASS \
    -H \
    results/NA12878_chr11.final_filtered.vcf.gz \
    | wc -l

Result:

2975

PASS SNPs:

bcftools view \
    -f PASS \
    -v snps \
    results/NA12878_chr11.final_filtered.vcf.gz \
    | wc -l

Result:

1459

PASS INDELs:

bcftools view \
    -f PASS \
    -v indels \
    results/NA12878_chr11.final_filtered.vcf.gz \
    | wc -l

Result:

1517

Because VCF records can contain multiple alternate alleles, SNP/INDEL record counts should be interpreted as VCF record classifications rather than simply adding them to obtain the total number of alternate alleles.

Step 12 — Variant Statistics

BCFtools was used to calculate variant statistics:

bcftools stats \
    results/NA12878_chr11.final_filtered.vcf.gz \
    > results/NA12878_chr11.final.stats.txt

Important results included:

Total variant records       3,232
SNP records                 1,487
INDEL records               1,746
Multiallelic sites             26

The transition/transversion ratio was:

Ti/Tv = 2.67

For PASS variants:

Ti/Tv = 2.73

The Ti/Tv ratio is a commonly used summary metric for evaluating SNP callsets.

Step 13 — Genotype Analysis

Genotype information was extracted using BCFtools:

bcftools query \
    -f '[%GT\n]' \
    results/NA12878_chr11.final_filtered.vcf.gz \
    | sort | uniq -c

Observed genotype representations included:

0/1
0|1
1/1
1/2
1|1
1|2

Examples:

0/1  → heterozygous
1/1  → homozygous alternate

The | notation represents phased genotype information, while / represents an unphased genotype.

Step 14 — Depth and Genotype Quality

Read depth and genotype quality were extracted using:

bcftools query \
    -f '%CHROM\t%POS\t[%DP]\n' \
    results/NA12878_chr11.final_filtered.vcf.gz

and:

bcftools query \
    -f '%CHROM\t%POS\t[%GQ]\n' \
    results/NA12878_chr11.final_filtered.vcf.gz

These values provide information about:

Sequencing depth supporting a variant
Confidence in the assigned genotype
Step 15 — Final Variant Table

A tab-separated variant table was generated using:

bcftools query \
    -f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\t%FILTER\t[%GT]\t[%DP]\t[%GQ]\n' \
    results/NA12878_chr11.final_filtered.vcf.gz \
    > results/NA12878_chr11.final_variants.tsv

The table contains:

CHROM
POS
REF
ALT
QUAL
FILTER
GT
DP
GQ

Example:

chr11  1007831  T  C  106.64  PASS  0/1  15  99

Interpretation:

Chromosome       chr11
Position         1007831
Reference allele T
Alternate allele C
Quality          106.64
Filter           PASS
Genotype         0/1
Depth            15
Genotype quality 99
Final Results
Metric	Result
Total variant records	3,232
SNP records	1,487
INDEL records	1,746
Multiallelic sites	26
PASS records	2,975
SNP hard-filtered	28
INDEL hard-filtered	229
PASS SNP records	1,459
PASS INDEL records	1,517
Initial Ti/Tv	2.67
PASS Ti/Tv	2.73
Repository Structure
DNAseq-Variant-Calling/
│
├── README.md
├── .gitignore
│
├── data/
│   └── README.md
│
├── reference/
│   └── README.md
│
├── results/
│   ├── NA12878_chr11.final.stats.txt
│   └── NA12878_chr11.final_variants.tsv
│
└── scripts/
    └── variant_calling_chr11.sh
Large Files

Large genomic files are intentionally excluded from this repository.

Examples include:

FASTQ files
BAM files
BAM index files
Human reference FASTA
FASTA index files
GATK reference dictionary
gVCF files
Compressed VCF files
VCF index files

The human reference genome is approximately 3.1 GB and is therefore not stored in the Git repository.

The .gitignore file prevents these large files from being accidentally committed.

Reproducibility

The main variant-calling commands are documented in:

scripts/variant_calling_chr11.sh

Final analysis outputs are provided in:

results/NA12878_chr11.final.stats.txt
results/NA12878_chr11.final_variants.tsv

These files allow the final variant set and its quality statistics to be inspected without storing the large binary sequencing files in the repository.

Limitations

This analysis was restricted to chromosome 11 rather than the complete human genome.

Therefore, the results represent a chromosome-specific variant callset.

The workflow demonstrates the complete analytical process, but the reported variant counts should not be interpreted as the total number of variants present across the NA12878 genome.

A whole-genome analysis would require substantially greater computational resources and processing time.

Future Extensions

The workflow can be extended to include:

Whole-genome variant calling
Base Quality Score Recalibration (BQSR)
Variant annotation
Functional consequence prediction
Comparison with benchmark truth sets
Precision and recall analysis
Variant visualization using IGV
SnpEff or VEP annotation
Multi-sample joint genotyping
Automated workflow implementation using Nextflow or Snakemake
Conclusion

This project demonstrates a complete DNA-seq variant-calling workflow using GATK, SAMtools, and BCFtools.

NA12878 was used for the primary human variant analysis, while additional datasets were used independently for computationally efficient evaluation of specific workflow components.

The final chromosome 11 analysis generated 3,232 variant records, including SNPs and INDELs, followed by quality-based filtering and detailed variant-level assessment.

The workflow provides a reproducible framework for processing sequencing data from alignment through variant identification, filtering, and quality evaluation.

Author
Sudharshini Kannan
