U.S Medicaid Drug Spending (2019-2023)
================
Shreya Shankar

This repository analyzes U.S. Medicaid drug spending for 2019–2023 with
a focus on psychiatric medications (antidepressants, antipsychotics,
mood stabilizers, anxiolytics, ADHD agents, hypnotics, and selected SUD
treatments). We attribute spending changes to **price** (average spend
per dose unit) and **volume** (dose units).

------------------------------------------------------------------------

## How to generate the final report

Compile the report:

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

*To remake the report run make clean and then make in the terminal*
