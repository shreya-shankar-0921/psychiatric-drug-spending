# ---- packages ----
library(dplyr)
library(readr)
library(stringr)

# ---- I/O setup ----
dir.create("clean_data", showWarnings = FALSE, recursive = TRUE)
dir.create("outputs",    showWarnings = FALSE, recursive = TRUE)

# ---- read raw ----
data <- read.csv("raw_data/drugspending_data.csv")

# ---- locate generic name col ----
name_col <- intersect(c("Gnrc_Name", "gnrc_name"), names(data))
if (length(name_col) == 0) stop("Couldn't find a generic-name column (Gnrc_Name / gnrc_name).")
name_col <- name_col[1]

# ---- target psych meds (NAMI list) ----
psych_meds <- c(
  "Acamprosate Calcium","Alprazolam","Amitriptyline HCl","Amitriptyline/Chlordiazepoxide",
  "Amphetamine","Amphetamine Sulfate","Aripiprazole","Aripiprazole Lauroxil",
  "Aripiprazole Lauroxil,Submicr.","Asenapine","Asenapine Maleate","Atomoxetine HCl",
  "Buprenorphine","Buprenorphine HCl","Buprenorphine HCl/Naloxone HCl","Bupropion HBr",
  "Bupropion HCl","Buspirone HCl","Carbamazepine","Cariprazine HCl","Chlordiazepoxide HCl",
  "Chlordiazepoxide/Clidinium Br","Chlorpromazine HCl","Citalopram Hydrobromide",
  "Clomipramine HCl","Clonazepam","Clonidine","Clonidine HCl","Clonidine HCl/PF",
  "Clozapine","Daridorexant HCl","Desipramine HCl","Desvenlafaxine","Desvenlafaxine Succinate",
  "Dexmethylphenidate HCl","Dextroamphetamine","Dextroamphetamine Sulfate",
  "Dextroamphetamine/Amphetamine","Dextromethorphan HBr/Bupropion","Diazepam","Disulfiram",
  "Divalproex Sodium","Doxepin HCl","Duloxetine HCl","Escitalopram Oxalate","Esketamine HCl",
  "Estazolam","Eszopiclone","Fluoxetine HCl","Fluphenazine Decanoate","Fluphenazine HCl",
  "Flurazepam HCl","Fluvoxamine Maleate","Guanfacine HCl","Haloperidol","Haloperidol Decanoate",
  "Haloperidol Lactate","Hydroxyzine HCl","Hydroxyzine Pamoate","Iloperidone","Imipramine HCl",
  "Imipramine Pamoate","Isocarboxazid","Ketamine HCl","Lamotrigine","Lemborexant",
  "Lisdexamfetamine Dimesylate","Lithium Carbonate","Lithium Citrate","Lorazepam",
  "Loxapine Succinate","Lurasidone HCl","Methamphetamine HCl","Methylphenidate",
  "Methylphenidate HCl","Midazolam","Midazolam HCl","Midazolam HCl In 0.9 % NaCl/PF",
  "Midazolam HCl/PF","Milnacipran HCl","Mirtazapine","Naloxone HCl","Naltrexone HCl",
  "Naltrexone HCl/Bupropion HCl","Naltrexone Microspheres","Nortriptyline HCl","Olanzapine",
  "Olanzapine Pamoate","Olanzapine/Fluoxetine HCl","Olanzapine/Samidorphan Malate","Oxazepam",
  "Oxcarbazepine","Paliperidone","Paliperidone Palmitate","Paroxetine HCl","Paroxetine Mesylate",
  "Pentazocine HCl/Naloxone HCl","Perphenazine","Perphenazine/Amitriptyline HCl",
  "Phenelzine Sulfate","Pimavanserin Tartrate","Prazosin HCl","Protriptyline HCl",
  "Quetiapine Fumarate","Ramelteon","Risperidone","Risperidone Microspheres","Selegiline",
  "Selegiline HCl","Sertraline HCl","Suvorexant","Temazepam","Thiothixene","Topiramate",
  "Tranylcypromine Sulfate","Trazodone HCl","Triazolam","Trifluoperazine HCl",
  "Trimipramine Maleate","Valproic Acid","Valproic Acid (As Sodium Salt)","Varenicline Tartrate",
  "Venlafaxine Besylate","Venlafaxine HCl","Vilazodone HCl","Vortioxetine Hydrobromide",
  "Zaleplon","Ziprasidone HCl","Ziprasidone Mesylate","Zolpidem Tartrate"
)

# ---- helpers ----
norm <- function(x) stringr::str_squish(stringr::str_to_lower(x))
psych_norm <- norm(psych_meds)

# ---- extract, clean ----
psych_data_extraction <- data %>%
  mutate(.gn = norm(.data[[name_col]])) %>%
  filter(.gn %in% psych_norm) %>%
  select(-.gn)

if (!"Mftr_Name" %in% names(psych_data_extraction)) {
  stop("Column 'Mftr_Name' not found in the data. Check your input.")
}

cleaned_data <- psych_data_extraction %>%
  filter(!grepl("overall", Mftr_Name, ignore.case = TRUE))

# ---- optional CSVs (keep if you still want them) ----
write.csv(psych_data_extraction, file = file.path("clean_data", "psych_data_extraction.csv"), row.names = FALSE)
write.csv(cleaned_data,          file = file.path("clean_data", "cleaned_data.csv"),          row.names = FALSE)

# ---- save compact R object for Rmd use ----
saveRDS(cleaned_data, file = file.path("outputs", "00_clean_data.rds"))

# keep in the environment if sourced()
invisible(cleaned_data)
