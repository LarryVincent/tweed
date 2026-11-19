# =============================================================================
# Tweed: house style for R output: colors, ggplot theme, and tables
# -----------------------------------------------------------------------------
# Source this file in a report's setup chunk:
#
#   source(here::here("R/tweed.R"))
#
# It reads _brand.yml so plots and tables use the same palette as the page.
# Running it also sets the default ggplot theme and tinytable options.
#
# Requires: ggplot2, tinytable, yaml, here, stringr, dplyr
# Recommended: hrbrthemes (the plot theme falls back to theme_minimal without it)
# =============================================================================

library(ggplot2)
library(tinytable)

# `%||%` is built into R 4.4+; define it for older versions.
if (!exists("%||%", baseenv())) `%||%` <- function(x, y) if (is.null(x)) y else x


# -----------------------------------------------------------------------------
# Colors
# -----------------------------------------------------------------------------
# One source of truth: the palette in _brand.yml. Add or change a color there,
# and the page (SCSS) and the plots (R) both pick it up.

lv_brand <- yaml::read_yaml(here::here("_brand.yml"))

lv_palette <- unlist(lv_brand$color$palette, use.names = TRUE)

# brand_color("pink") returns "#F62477". Accepts a vector of names and stops
# on a name that isn't in the palette, so a typo can't silently draw black.
brand_color <- function(name) {
  unknown <- setdiff(name, names(lv_palette))
  if (length(unknown) > 0) {
    stop("Unknown brand color: ", paste(unknown, collapse = ", "))
  }
  unname(lv_palette[name])
}


# -----------------------------------------------------------------------------
# ggplot theme
# -----------------------------------------------------------------------------
# hrbrthemes::theme_ipsum with Aktiv Grotesk, extra space above the panel, and
# a larger title. Conventions used with it in the reports:
#   - no explanatory subtitles; the figure caption carries the explanation
#   - annotations in bold small caps (fontface = "bold", uppercase text)
#   - colors from brand_color(); no pie charts
#
# Aktiv Grotesk is an Adobe font: it must be installed on the machine that
# renders the report. Pass base_family = "sans" to use the system font.

theme_lv <- function(base_family = "Aktiv Grotesk", ...) {
  base <- if (requireNamespace("hrbrthemes", quietly = TRUE)) {
    hrbrthemes::theme_ipsum(base_family = base_family, ...)
  } else {
    warning("hrbrthemes is not installed; using theme_minimal() instead.")
    theme_minimal(base_family = base_family, ...)
  }

  base +
    theme(
      plot.margin = margin(18, 0, 12, 0, unit = "pt"),
      plot.title = element_text(size = 16, margin = margin(b = 18, unit = "pt"))
    )
}

theme_set(theme_lv())


# -----------------------------------------------------------------------------
# Tables
# -----------------------------------------------------------------------------
# Tables sit flush with the left edge of the text column instead of centered.
# These options apply to every tinytable in the report; the monospace face
# and font size come from lv-theme.scss (section 6).

options(
  tinytable_html_class = "tinytable tinytable-sm flush-left mb-4",
  tinytable_html_css_rule = paste(
    tinytable:::get_css(),
    "
    .container:has(table.flush-left) {
      padding-inline: 0 !important;
      margin-left: 0 !important;
      max-width: none !important;
      width: 100% !important;
    }

    table.flush-left {
      margin-left: 0 !important;
      margin-right: auto !important;
    }

    table.flush-left th:first-child,
    table.flush-left td:first-child {
      padding-left: 0 !important;
    }
    "
  )
)

# The house table: hairline rules between rows, a heavier rule under the last
# row, bold column headers, and the first column left-aligned with the rest
# right-aligned (override with `align`, e.g. "llrr").
#
#   lv_table(df, width = 0.8, caption = NULL, notes = "Source: ...")
#
# In a Quarto float, put the caption in the chunk (#| tbl-cap) and leave
# `caption` NULL.
lv_table <- function(df, width, caption = NULL, notes = NULL, align = NULL) {
  n <- nrow(df)
  align <- align %||% stringr::str_c("l", strrep("r", ncol(df) - 1))

  df |>
    tt(width = width, caption = caption, notes = notes) |>
    theme_html(
      class = "tinytable tinytable-sm flush-left ms-0 me-auto mb-4",
      j = 1,
      css = "padding-left: 0 !important;"
    ) |>
    style_tt(i = 1:n, line = "b", line_width = 0.05, line_color = "#D9D9D9") |>
    style_tt(i = n, line = "b", line_width = 0.15, line_color = "#111111") |>
    style_tt(i = "colnames", line = "b", line_width = 0.05, line_color = "#111111") |>
    style_tt(i = "colnames", bold = TRUE) |>
    style_tt(i = 0:n, align = align) |>
    style_tt(i = "notes", align = "l")
}


# -----------------------------------------------------------------------------
# Number and date formatting
# -----------------------------------------------------------------------------

# APA-style p-values: "< .001", ".042", and an em dash for missing.
apa_p <- function(x) {
  dplyr::case_when(
    is.na(x) ~ "—",
    x < .001 ~ "< .001",
    TRUE ~ sub("^0", "", sprintf("%.3f", x))
  )
}

# "November 19, 2026"
fmt_date <- function(d) format(d, "%B %d, %Y")
