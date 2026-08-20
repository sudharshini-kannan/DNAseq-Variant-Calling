# DNA-seq Variant Calling Workflow

## Overview

This repository contains an end-to-end DNA sequencing (DNA-seq) variant calling workflow developed as part of an NGS/Bioinformatics internship.

The workflow demonstrates how raw sequencing data can be processed through quality control, alignment, BAM processing, variant calling, variant filtering, and final variant interpretation.

The primary human dataset used for variant calling is NA12878, a well-characterized human reference sample. Variant calling was performed on chromosome 11 to reduce computational requirements while demonstrating the complete GATK-based workflow.

---

# Project Objectives

The main objectives of this project were:

- Understand the complete DNA-seq variant calling workflow.
- Perform sequencing data quality control.
- Understand read alignment to a reference genome.
- Generate and process BAM files.
- Perform variant calling using GATK.
- Generate genomic VCF (gVCF) output.
- Convert gVCF to variant calls.
- Apply SNP and INDEL hard filtering.
- Evaluate the quality of called variants.
- Generate summary statistics.
- Extract variant-level information for downstream analysis.
- Document a reproducible command-line workflow.

---

# Overall Workflow

The workflow can be summarized as:

Raw FASTQ
   |
   v
Quality Control
   |
   v
Read Preprocessing
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
SNP/INDEL Filtering
   |
   v
Final Filtered VCF
   |
   v
Variant Statistics
   |
   v
Final Variant Table

---

# Dataset Strategy

Different datasets were used during the internship because each dataset served a different computational and teaching purpose.

## 1. NA12878 Human Dataset

### Purpose

The NA12878 dataset was used as the primary dataset for the human DNA-seq variant-calling workflow.

NA12878 is a well-characterized human reference sample that is widely used in benchmarking and evaluating variant-calling methods.

For this project, sequencing data containing reads mapped to chromosome 11 were used.

### Why chromosome 11?

A complete human genome contains billions of bases and requires substantial computational resources for alignment and variant calling.

The internship environment had limited time and computational resources. Therefore, chromosome 11 was selected as a representative region.

This allowed the complete workflow to be demonstrated without requiring the computational time and storage associated with whole-genome processing.

### NA12878 processing

The NA12878 BAM file was inspected and validated.

The BAM file contained:

- Reference contig: chr11
- chr11 length: 135,086,622 bp
- Mapped reads on chr11: 101,003

The BAM header was checked to ensure that chromosome 11 matched the human reference genome.

---

# 2. E. coli Dataset

## Purpose

The E. coli dataset was used primarily for alignment/testing and workflow demonstration.

The E. coli genome is much smaller than the human genome.

This makes it useful for:

- Testing alignment commands
- Demonstrating reference indexing
- Understanding BAM generation
- Testing SAMtools commands
- Demonstrating sorting and BAM indexing
- Learning the alignment portion of the workflow efficiently

### Why not use E. coli for human variant calling?

E. coli is a bacterial organism and therefore does not represent the human genome.

The biological objective of the project was human variant calling using NA12878.

Therefore, E. coli was not used for the final human variant-calling results.

It was used as a computationally efficient dataset for demonstrating and testing alignment-related steps.

---

# 3. Teaching Dataset

A small teaching dataset was also used during the internship for demonstrating sequencing quality-control and preprocessing concepts.

The teaching dataset was useful for:

- FastQC
- fastp
- Quality assessment
- Read preprocessing
- Understanding FASTQ files
- Demonstrating basic NGS preprocessing

The teaching dataset was intentionally kept separate from the final NA12878 variant-calling analysis.

---

# Why Were Multiple Datasets Used?

Using different datasets allowed the workflow to be demonstrated efficiently while maintaining biological relevance.

| Dataset | Purpose |
|---------|---------|
| NA12878 | Main human variant-calling analysis |
| E. coli | Fast alignment and BAM-processing demonstration |
| Teaching dataset | QC and preprocessing demonstration |

The important point is that these datasets were **not mixed together**.

Each dataset was used for the stage where it was most appropriate.

The final biological variant-calling results presented in this repository are from **NA12878 chromosome 11**.

---

# Software and Tools

The workflow used the following tools:

- Linux / Ubuntu WSL
- Bash
- FastQC
- fastp
- BWA
- SAMtools
- GATK
- BCFtools
- Conda

Main software versions used during the analysis included:

- GATK 4.6.2.0
- SAMtools
- BCFtools
- Java

---

# Reference Genome

The human reference genome used for the NA12878 analysis was:

`Homo_sapiens_assembly38.fasta`

This corresponds to the Broad Institute hg38/GRCh38 reference resource.

The following reference files were generated/used:

```text
Homo_sapiens_assembly38.fasta
Homo_sapiens_assembly38.fasta.fai
Homo_sapiens_assembly38.dict
