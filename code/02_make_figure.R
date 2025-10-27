# ---- packages ----
library(dplyr)
library(ggplot2)
library(scales)

# ---- I/O ----
dir.create("outputs", showWarnings = FALSE, recursive = TRUE)

# ---- data sources ----
# Prefer using the tidy decomposition data saved earlier (table1_data.rds).
# Fallback: rebuild 2019→2023 decomp directly from cleaned_data if needed.
if (file.exists(file.path("outputs", "table1_data.rds"))) {
  combined_decomp <- readRDS(file.path("outputs", "table1_data.rds"))
  decomp_19_23 <- combined_decomp %>% dplyr::filter(Period == "2019→2023")
} else {
  # Fallback path (keeps this script stand-alone)
  cleaned_data <- readRDS(file.path("outputs", "00_clean_data.rds"))
  
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
        Volume_Contrib = (V1 - V0) * (P0 + P1) / 2
      ) %>%
      filter(Delta_Spend > 0) %>%
      arrange(desc(Delta_Spend)) %>%
      slice_head(n = top_n) %>%
      mutate(
        Period          = paste0(label_from, "→", label_to),
        `ΔSpend ($)`    = Delta_Spend,
        `Price ($)`     = Price_Contrib,
        `Volume ($)`    = Volume_Contrib
      ) %>%
      select(
        Period, Gnrc_Name,
        Spend_from, Spend_to,
        `ΔSpend ($)`, `Price ($)`, `Volume ($)`
      )
  }
  
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
}

# ---- top 5 by ΔSpend for 2019→2023 ----
top5 <- decomp_19_23 %>%
  mutate(Delta = `ΔSpend ($)`) %>%
  arrange(desc(Delta)) %>%
  slice_head(n = 5)

# ---- build waterfall data (wf) ----
wf <- top5 %>%
  transmute(
    Gnrc_Name,
    S0 = Spend_from,
    P  = `Price ($)`,
    V  = `Volume ($)`,
    S1 = Spend_to
  ) %>%
  rowwise() %>%
  do({
    nm <- .$Gnrc_Name; S0 <- .$S0; P <- .$P; V <- .$V; S1 <- .$S1
    data.frame(
      Gnrc_Name = nm,
      Step = factor(
        c("Start (2019)", "Price Effect", "Volume Effect", "End (2023)"),
        levels = c("Start (2019)", "Price Effect", "Volume Effect", "End (2023)")
      ),
      ymin = c(
        0,
        pmin(S0, S0 + P),
        pmin(S0 + P, S0 + P + V),
        0
      ),
      ymax = c(
        S0,
        pmax(S0, S0 + P),
        pmax(S0 + P, S0 + P + V),
        S1
      ),
      Contribution = c(NA, P, V, NA)
    )
  }) %>%
  ungroup() %>%
  mutate(
    Fill = case_when(
      Step %in% c("Start (2019)", "End (2023)") ~ "Total",
      Step == "Price Effect"  & Contribution >= 0 ~ "Price (+)",
      Step == "Price Effect"  & Contribution  < 0 ~ "Price (−)",
      Step == "Volume Effect" & Contribution >= 0 ~ "Volume (+)",
      Step == "Volume Effect" & Contribution  < 0 ~ "Volume (−)"
    )
  )

fill_vals <- c(
  "Total" = "#bdbdbd",
  "Price (+)"  = "#1b9e77",
  "Price (−)"  = "#d95f02",
  "Volume (+)" = "#377eb8",
  "Volume (−)" = "#d95f02"
)

waterfall_chart <- ggplot(wf, aes(x = Step)) +
  geom_rect(aes(
    xmin = as.numeric(Step) - 0.48,
    xmax = as.numeric(Step) + 0.48,
    ymin = ymin, ymax = ymax, fill = Fill
  ), color = "white", linewidth = 0.2) +
  scale_fill_manual(values = fill_vals, name = NULL) +
  scale_y_continuous(labels = scales::label_dollar()) +
  facet_wrap(~ Gnrc_Name, scales = "free_y", ncol = 2) +
  labs(
    title = "Price vs. Volume Contributions to ΔSpend (2019→2023)",
    subtitle = "Top 5 generics by total spending increase; midpoint allocation",
    x = NULL, y = "Total Spend (USD)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    strip.text = element_text(face = "bold", size = 12),
    axis.text = element_text(size = 12),
    panel.spacing = unit(1, "lines"),
    plot.margin = margin(10, 20, 10, 20)
  ) +
  coord_cartesian(clip = "off")

# ---- save outputs for Rmd ----
saveRDS(waterfall_chart, file.path("outputs", "figure1.rds"))      # for direct rendering
saveRDS(wf,              file.path("outputs", "figure1_data.rds")) # underlying chart data
ggsave(
  filename = file.path("outputs", "figure1.png"),
  plot = waterfall_chart, width = 14, height = 10, units = "in", dpi = 320, bg = "white"
)

# keep object visible if sourced() interactively
invisible(waterfall_chart)
