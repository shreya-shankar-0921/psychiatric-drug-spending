U.S Medicaid Drug Spending (2019-2023)
================
Shreya Shankar

This repository analyzes U.S. Medicaid drug spending for 2019–2023 with
a focus on psychiatric medications (antidepressants, antipsychotics,
mood stabilizers, anxiolytics, ADHD agents, hypnotics, and selected SUD
treatments). We attribute spending changes to **price** (average spend
per dose unit) and **volume** (dose units).

------------------------------------------------------------------------

## Quick guide: how to generate the final report

Compile the report:

Run `make install` in the terminal to ensure all the packages are
uploaded and up to date.

Run `make` in the terminal to generate the .html output along with the
figure and table data objects.

------------------------------------------------------------------------

## Contents

- data550_final.Rmd: Final report with the text, table, and figure
- Makefile: Simple build rules for RDS artifacts
- raw_data/:
  - drugspending_data.csv: the raw export of the data from the CMS
    website
- code/
  - 00_build_clean_data.R: Builds outputs/00_clean_data.rds
  - 01_build_table1.R: Builds outputs/table1.rds (the decomposition
    table)
  - 02_build_figure1.R: Builds outputs/figure1.rds (the waterfall chart)
- outputs/
  - The data objects that are created from the code and the analyses
    that are displayed in the final report

------------------------------------------------------------------------

## What’s in the report?

**Introduction**: Scope, data source, and psychiatric drug definition
based on a curated NAMI-aligned generic list.

**Decomposition Table**: A table showing the % change in spending that
would be attributed to changes in price and changes in volume

**Waterfall Chart**: Waterfall charts for the top-moving generics (by Δ
Spend) that visually split increases into price vs. volume components.

By separating price dynamics from utilization shifts, the report helps
identify policy-relevant levers—coverage (formularies, preferred
products), payment (rebates, inflationary caps), and management
(utilization controls)—to target spending growth responsibly while
protecting access.

------------------------------------------------------------------------

## Building and cleaning the report with Make

You can use the Makefile to run the full analysis and build the report
with a single command: `make`

This will:

1.  Run all analysis steps to create the cleaned data, table, and figure
    in `outputs/`.

2.  Render `report.Rmd` and save the compiled report to
    `report/report.html`.

To remove all generated files and start fresh, use: `make clean`

This deletes all files in the `outputs/` and `report/` directories so
the entire pipeline can be rebuilt from scratch.

## R package management (renv)

This project uses `renv` to keep the R package versions consistent with
the `renv.lock` file. To synchronize your local R library with the
project’s lockfile, run:

`make install`

## Docker: Reproducible Report

This project includes a Docker image that can automatically compile the
final report in a fully reproducible environment.

### 1. Docker image and DockerHub link

The pre-built image for this project is available on DockerHub:

- **DockerHub repository:**
  <https://hub.docker.com/r/sshankar0921/final-project-report>  
- **Image name:** `sshankar0921/final-project-report:latest`

You can pull it directly with:

`docker pull sshankar0921/final-project-report:latest`

### 2. Building the Docker image locally (optional)

If you prefer to build the image yourself instead of pulling from
DockerHub, run one of the following from the project root (where the
`Dockerfile` is located):

**On Intel Mac / Linux / Windows**

`docker build -t sshankar0921/final-project-report:latest .`

**On Apple Silicon (M1/M2/M3) Macs**

`docker build --platform=linux/amd64 -t sshankar0921/final-project-report:latest .`

### 3. Running the automated report build with Docker

The container is configured so that, when it runs, it automatically:

1.  Loads the project’s `renv` environment, and

2.  Renders `report.Rmd` into a `report/` folder inside the container.

*We mount a local report/ folder into the container so that the compiled
report is saved on your machine.*

**Mac / Linux**

From the project root:

    mkdir -p report
    docker run --rm \
      -v "$(pwd)/report:/home/rstudio/project/report" \
      sshankar0921/final-project-report:latest

After this finishes, the compiled report will be in the local `report/`
folder.

**Windows (Git Bash)**

From the project root:

    mkdir -p report
    docker run --rm \
      -v "/$(pwd)/report:/home/rstudio/project/report" \
      sshankar0921/final-project-report:latest

### 4. Running the automated report build using the Makefile

A Makefile target is provided so the report can be built with a single
command.

**Mac / Linux**

`make docker_report_mac`

**Windows (Git Bash)**

`make docker_report_win`

These targets:

1.  Create a local `report/` directory if it does not already exist.

2.  Run the Docker container with `report/` mounted to
    `/home/rstudio/project/report`.

3.  Leave the compiled report in the local `report/` folder when the
    container exits.
