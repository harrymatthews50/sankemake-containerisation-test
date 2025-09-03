# this workflow can run fine with the command
docker run -w /workspace -v $PWD:/workspace  snakemake/snakemake:latest snakemake --cores 1 --sdm conda

# I then try to containerize the workflow
docker run -w /workspace -v $PWD:/workspace  snakemake/snakemake:latest snakemake --cores 1 --sdm conda --containerize > Dockerfile

# and end up with the following Dockerfile
```
FROM condaforge/miniforge3:latest
LABEL io.github.snakemake.containerized="true"
LABEL io.github.snakemake.conda_env_hash="6ac920d714ad0f6b67f2c8c13ac52ae6366360b48927a8a9d2892282b19fde71"

# Step 2: Retrieve conda environments

# Conda environment:
#   source: https://github.com/snakemake/snakemake-wrappers/raw/v6.0.0/bio/fastqc/environment.yaml
#   prefix: /conda-envs/fd1d6cdb3d8f52f0cf7524c1b190d1f7
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - fastqc =0.12.1
#     - snakemake-wrapper-utils =0.7.2
RUN mkdir -p /conda-envs/fd1d6cdb3d8f52f0cf7524c1b190d1f7
ADD https://github.com/snakemake/snakemake-wrappers/raw/v6.0.0/bio/fastqc/environment.yaml /conda-envs/fd1d6cdb3d8f52f0cf7524c1b190d1f7/environment.yaml

# Conda environment:
#   source: https://github.com/snakemake/snakemake-wrappers/raw/v6.0.0/bio/multiqc/environment.yaml
#   prefix: /conda-envs/604fd9192ec1b4065455fe8b15c086d6
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - multiqc =1.28
#     - snakemake-wrapper-utils =0.7.2
RUN mkdir -p /conda-envs/604fd9192ec1b4065455fe8b15c086d6
ADD https://github.com/snakemake/snakemake-wrappers/raw/v6.0.0/bio/multiqc/environment.yaml /conda-envs/604fd9192ec1b4065455fe8b15c086d6/environment.yaml

# Conda environment:
#   source: workflow/envs/get_genome.yaml
#   prefix: /conda-envs/68fc50fd41aeaa780499c43b4b87783e
#   name: get_genome
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - gzip=1.14
#     - wget=1.21.4
RUN mkdir -p /conda-envs/68fc50fd41aeaa780499c43b4b87783e
COPY workflow/envs/get_genome.yaml /conda-envs/68fc50fd41aeaa780499c43b4b87783e/environment.yaml

# Conda environment:
#   source: workflow/envs/simulate_reads.yaml
#   prefix: /conda-envs/19ffc51f5e6e8f8eabfd705039b94e9f
#   name: simulate_reads
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - dwgsim=1.1.14
RUN mkdir -p /conda-envs/19ffc51f5e6e8f8eabfd705039b94e9f
COPY workflow/envs/simulate_reads.yaml /conda-envs/19ffc51f5e6e8f8eabfd705039b94e9f/environment.yaml

# Conda environment:
#   source: workflow/envs/validate_genome.yaml
#   prefix: /conda-envs/fbaefa4f07b727428a82883e7cdbc88b
#   name: validate_genome
#   channels:
#     - conda-forge
#     - bioconda
#     - nodefaults
#   dependencies:
#     - python=3.12
#     - biopython=1.85
RUN mkdir -p /conda-envs/fbaefa4f07b727428a82883e7cdbc88b
COPY workflow/envs/validate_genome.yaml /conda-envs/fbaefa4f07b727428a82883e7cdbc88b/environment.yaml

# Step 3: Generate conda environments

RUN conda env create --prefix /conda-envs/fd1d6cdb3d8f52f0cf7524c1b190d1f7 --file /conda-envs/fd1d6cdb3d8f52f0cf7524c1b190d1f7/environment.yaml && \
    conda env create --prefix /conda-envs/604fd9192ec1b4065455fe8b15c086d6 --file /conda-envs/604fd9192ec1b4065455fe8b15c086d6/environment.yaml && \
    conda env create --prefix /conda-envs/68fc50fd41aeaa780499c43b4b87783e --file /conda-envs/68fc50fd41aeaa780499c43b4b87783e/environment.yaml && \
    conda env create --prefix /conda-envs/19ffc51f5e6e8f8eabfd705039b94e9f --file /conda-envs/19ffc51f5e6e8f8eabfd705039b94e9f/environment.yaml && \
    conda env create --prefix /conda-envs/fbaefa4f07b727428a82883e7cdbc88b --file /conda-envs/fbaefa4f07b727428a82883e7cdbc88b/environment.yaml && \
    conda clean --all -y
```
Which I then build

```
docker buildx build --platform linux/amd64,linux/arm64 -t harrymatthews50/my_workflow:latest . --push
```
