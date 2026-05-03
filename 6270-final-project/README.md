# VTPEH 6270 – NORS Foodborne Outbreak Dashboard

This repository contains code and materials for the VTPEH 6270 final project. The project uses National Outbreak Reporting System (NORS) data to examine reported foodborne outbreak patterns in the United States and includes both a written final report and an interactive Shiny App.

---

## Author

Mengzhi Yuan  
VTPEH 6270, Cornell University

---

## Project Description

This repository contains the final report, dataset, and Shiny App files for the VTPEH 6270 final project. The project explores foodborne outbreak burden and patterns using NORS data, with a focus on outbreak counts, illnesses, hospitalizations, deaths, states, etiologies, settings, and yearly trends.

The Shiny App was developed to complement the written report by allowing users to interactively explore the dataset and visualize outbreak patterns across time and outbreak characteristics.

---

## Research Question / Objectives

1. To describe overall patterns in reported foodborne outbreaks using NORS data.
2. To examine how reported outbreaks, illnesses, hospitalizations, and deaths vary across years.
3. To identify the most frequently reported states, etiologies, settings, and outbreak characteristics.
4. To create an interactive dashboard that supports exploratory analysis of foodborne outbreak trends and profiles.

---

## Shiny App

An interactive Shiny App has been developed to visualize and explore reported foodborne outbreak patterns.

🔗 **Live App:** [https://grace912.shinyapps.io/6270-final-project/](https://grace912.shinyapps.io/6270-final-project/)

### App Features

The app includes four interactive tabs:

- **Overview** – Provides a summary of total reported outbreaks, illnesses, hospitalizations, and deaths, along with overall trends and top reported states and etiologies.
- **Trend Explorer** – Allows users to filter by year range, state, and outcome to examine yearly outbreak trends.
- **Outbreak Profile** – Allows users to rank selected outbreak characteristics, such as etiology, state, setting, or other categories, using selected metrics.
- **Data & Methods** – Describes the data source and methods, provides project information, and includes a preview of the dataset.

### Running the App Locally

1. Clone or download this repository.
2. Make sure the following R packages are installed:

```r
install.packages(c(
  "shiny",
  "bslib",
  "bsicons",
  "tidyverse",
  "DT",
  "scales"
))
```

### Shiny App Files

```
shiny_app/
├── app.R
└── NORS_20260501.csv
```

---

## Data Source

Data were obtained from the National Outbreak Reporting System (NORS), which collects outbreak reports submitted to CDC by state, local, and territorial public health agencies.
[https://data.cdc.gov/Foodborne-Waterborne-and-Related-Diseases/NORS/5xkq-dg7x/data_preview](https://data.cdc.gov/Foodborne-Waterborne-and-Related-Diseases/NORS/5xkq-dg7x/data_preview)

---

## Processed Data

The main analysis and Shiny App use the cleaned NORS dataset:

```
data/NORS_20260501.csv
```
The dataset includes outbreak-level records with variables related to outbreak year, month, state, primary mode, etiology, etiology status, setting, illnesses, hospitalizations, deaths, food vehicle, and IFSAC category.

---

## Data Description

The cleaned dataset focuses on reported foodborne outbreak records from the National Outbreak Reporting System (NORS). The variables included in this analysis and Shiny App are described below:

| Variable | Type | Description |
|---|---|---|
| `Year` | Numeric | Year when the outbreak was reported or occurred |
| `Month` | Numeric | Month associated with the outbreak record |
| `State` | Categorical | State where the outbreak was reported |
| `Primary Mode` | Categorical | Primary transmission mode of the outbreak |
| `Etiology` | Categorical | Reported causative agent or pathogen |
| `Etiology Status` | Categorical | Confirmation status of the reported etiology |
| `Setting` | Categorical | Reported outbreak setting |
| `Illnesses` | Numeric | Number of reported illnesses associated with the outbreak |
| `Hospitalizations` | Numeric | Number of reported hospitalizations associated with the outbreak |
| `Deaths` | Numeric | Number of reported deaths associated with the outbreak |
| `Food Vehicle` | Categorical | Reported food vehicle, when available |
| `IFSAC Category` | Categorical | Food categorization used for outbreak classification |

Missing values are retained where appropriate. For numeric summaries, missing values are excluded from totals.

---

## Repository Structure

```
6270-final-project/
├── data/
│   └── NORS_20260501.csv
│
├── shiny_app/
│   ├── app.R
│   └── NORS_20260501.csv
│
├── r_final_report.Rmd.Rmd
├── r_final_report.Rmd.pdf
├── references.bib
└── README.md

```
---

## AI Tool Disclosure

The report utilized ChatGPT to assist in correcting code errors and organizing information. All code was personally executed by the author and subjected to chart analysis.
