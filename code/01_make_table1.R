# ---- packages ----
library(dplyr)
library(gt)
library(scales)

# ---- I/O ----
dir.create("outputs", showWarnings = FALSE, recursive = TRUE)

# Expect the cleaned object created previously at outputs/00_clean_data.rds
cleaned_data <- readRDS(file.path("outputs", "00_clean_data.rds"))

# ---- function ----
decompose_pv <- function(df, p0, p1, v0, v1, s0, s1, label_from, label_to, top_n = 20) {
  df %>%
    group_by(Gnrc_Name) %>%
    summarise(
      Spend_from = sum(.data[[s0]], na.rm = TRUE),
      Spend_to   = sum(.data[[s1]], na.rm = TRUE),
      V0 = sum(.data[[v0]], na.rm = TRUE),
      V1 = sum(.data[[v1]], na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      P0 = ifelse(V0 > 0, Spend_from / V0, NA_real_),
      P1 = ifelse(V1 > 0, Spend_to   / V1, NA_real_)
    ) %>%
    mutate(
      Delta_Spend    = Spend_to - Spend_from,
      Price_Contrib  = (P1 - P0) * (V0 + V1) / 2,
      Volume_Contrib = (V1 - V0) * (P0 + P1) / 2,
      Price_Share    = ifelse(Delta_Spend == 0, NA_real_, Price_Contrib / Delta_Spend),
      Volume_Share   = ifelse(Delta_Spend == 0, NA_real_, Volume_Contrib / Delta_Spend)
    ) %>%
    filter(Delta_Spend > 0) %>%
    arrange(desc(Delta_Spend)) %>%
    slice_head(n = top_n) %>%
    mutate(
      Period          = paste0(label_from, "→", label_to),
      `ΔSpend ($)`    = Delta_Spend,
      `Price ($)`     = Price_Contrib,
      `Volume ($)`    = Volume_Contrib,
      `% from Price`  = Price_Share,
      `% from Volume` = Volume_Share
    ) %>%
    select(
      Period, Gnrc_Name,
      Spend_from, Spend_to,
      `ΔSpend ($)`, `Price ($)`, `% from Price`, `Volume ($)`, `% from Volume`
    )
}

# ---- builds ----
decomp_19_23 <- decompose_pv(
  cleaned_data,
  p0 = "Avg_Spnd_Per_Dsg_Unt_Wghtd_2019",
  p1 = "Avg_Spnd_Per_Dsg_Unt_Wghtd_2023",
  v0 = "Tot_Dsg_Unts_2019",
  v1 = "Tot_Dsg_Unts_2023",
  s0 = "Tot_Spndng_2019",
  s1 = "Tot_Spndng_2023",
  label_from = "2019", label_to = "2023",
  top_n = 20
)

has_2022 <- all(c("Tot_Spndng_2022","Avg_Spnd_Per_Dsg_Unt_Wghtd_2022","Tot_Dsg_Unts_2022") %in% names(cleaned_data))
decomp_22_23 <- if (has_2022) {
  decompose_pv(
    cleaned_data,
    p0 = "Avg_Spnd_Per_Dsg_Unt_Wghtd_2022",
    p1 = "Avg_Spnd_Per_Dsg_Unt_Wghtd_2023",
    v0 = "Tot_Dsg_Unts_2022",
    v1 = "Tot_Dsg_Unts_2023",
    s0 = "Tot_Spndng_2022",
    s1 = "Tot_Spndng_2023",
    label_from = "2022", label_to = "2023",
    top_n = 20
  )
} else {
  NULL
}

combined_decomp <- if (!is.null(decomp_22_23)) dplyr::bind_rows(decomp_19_23, decomp_22_23) else decomp_19_23

# ---- formatting helpers ----
format_money <- function(x) scales::dollar(x, accuracy = 1)
format_pct   <- function(x) scales::percent(x, accuracy = 0.1)

# ---- build gt table ----
tbl_gt <- combined_decomp %>%
  mutate(
    Spend_from    = format_money(Spend_from),
    Spend_to      = format_money(Spend_to),
    `ΔSpend ($)`  = format_money(`ΔSpend ($)`),
    `Price ($)`   = format_money(`Price ($)`),
    `Volume ($)`  = format_money(`Volume ($)`),
    `% from Price`  = format_pct(`% from Price`),
    `% from Volume` = format_pct(`% from Volume`)
  ) %>%
  gt(rowname_col = "Gnrc_Name", groupname_col = "Period") %>%
  tab_header(
    title = md("**Price vs. Volume Decomposition**"),
    subtitle = md("Top growth drugs by ΔSpend; midpoint allocation of interaction (2019→2023 and 2022→2023)")
  ) %>%
  cols_label(
    Spend_from   = "Spend (From)",
    Spend_to     = "Spend (To)",
    `ΔSpend ($)` = "Δ Spend",
    `Price ($)`  = "Price Contribution",
    `% from Price`  = "% from Price",
    `Volume ($)` = "Volume Contribution",
    `% from Volume` = "% from Volume"
  ) %>%
  tab_spanner(label = "Spend Levels", columns = c(Spend_from, Spend_to)) %>%
  tab_spanner(label = "Decomposition", columns = c(`ΔSpend ($)`, `Price ($)`, `% from Price`, `Volume ($)`, `% from Volume`)) %>%
  fmt_missing(everything(), missing_text = "—") %>%
  tab_options(table.font.size = px(13), data_row.padding = px(4)) %>%
  tab_source_note(md("Notes: ΔSpend = P1×V1 − P0×V0. Price = (P1−P0)×(V0+V1)/2. Volume = (V1−V0)×(P0+P1)/2 (midpoint allocation)."))

# ---- save objects for Rmd ----
saveRDS(tbl_gt,           file.path("outputs", "table1.rds"))       # for direct display
saveRDS(combined_decomp,  file.path("outputs", "table1_data.rds"))  # for charts/QA if needed

# keep object visible if sourced() interactively
invisible(tbl_gt)
