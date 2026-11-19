# Tweed

A Quarto HTML format for long-form analytical reports. It uses an editorial serif, a monospace face for tables, citations and notes in the margin, captions above floats, and an optional full-width cover image. Tweed was built for Laurence Vincent's reports.

## Start a new report

```bash
mkdir my-report && cd my-report
quarto use template LarryVincent/tweed
```

This copies the format and a starter report into the folder. The starter `.qmd` takes the folder's name and doubles as a style guide: each section demonstrates one component. Keep the ones you need and delete the rest. Then render:

```bash
quarto render my-report.qmd
```

## Add Tweed to an existing project

```bash
quarto add LarryVincent/tweed
```

This installs only the format, in `_extensions/tweed/`. Then set `format: tweed-html` in the front matter. For the colors, fonts, and R helpers, also copy `_brand.yml` and `R/tweed.R` from this repo into the project.

## Update

```bash
quarto update extension LarryVincent/tweed
```

## What's in the box

| File | What it does | Edit it? |
|---|---|---|
| `_extensions/tweed/_extension.yml` | Defines `tweed-html`: TOC, section numbers, margin notes and citations, captions on top, APA citations, hidden code | No. Override options in your front matter |
| `_extensions/tweed/tweed.scss` | The house theme: typography, captions, tables, tabsets, cover image, callout components. Every section is commented | Only to change the house style |
| `_extensions/tweed/caption-labels.html` | Wraps "Figure 3:" in `<span class="float-label">` so the label can be styled | No |
| `_extensions/tweed/list-of-floats.html` | Builds a linked List of Figures and Tables from the captions | No |
| `_extensions/tweed/apa.csl` | APA 7 citation style | No |
| `_brand.yml` | Color palette and fonts, shared by the page and the R plots | Yes, per project |
| `R/tweed.R` | `brand_color()`, `theme_tweed()`, `tweed_table()`, `apa_p()`, `fmt_date()`; sets the default ggplot theme and table options. The older names `theme_lv()` and `lv_table()` still work | Rarely |
| `report.scss` | Styles for this report only | Yes |
| `cover-hero.html` | The cover image and its alt text | Yes |
| `footer.html` | Copyright line and links | Yes |
| `images/cover.jpg` | Placeholder cover | Replace it |

## How the styling is layered

```yaml
theme: [flatly, brand, _extensions/tweed/tweed.scss, report.scss]
```

Each layer builds on the one before it:

1. **flatly** is the Bootstrap 5 base.
2. **brand** brings in the colors and fonts from `_brand.yml`.
3. **tweed.scss** adds the house design.
4. **report.scss** adds rules for this report only.

`tweed-html` applies the first three on its own. Setting `theme` in front matter replaces the whole list, which is why the starter restates all four.

## Components

| Component | Markup |
|---|---|
| Data-currency line | `::: {.data-current}` |
| Floated image | `![](img.gif){.tweed-float-right}` or `{.tweed-float-left}` |
| Journal callout | `::: {.callout-note .journal-callout appearance="simple" collapse="true" icon=false}` with a `::: {.journal-text}` body |
| Active experiment box | `::: {.active-experiment}`, with an optional `::: {.active-experiment-status}` |
| Revision note | `::: {.revision}` around a block quote |
| Indented hypotheses | `::: {.hypotheses}` |
| Text-heavy table | add class `compact-design-tbl` |
| List of Figures and Tables | an empty `::: {#list-of-floats}` div |
| Legal summary box | `::: {.legal-summary}` |

## Requirements

- Quarto 1.6 or later.
- For R reports: ggplot2, tinytable, yaml, here, dplyr, and stringr. hrbrthemes is recommended; without it, plots fall back to `theme_minimal()`.
- Fonts: Newsreader and IBM Plex Mono load from Google Fonts automatically. Plot text uses Aktiv Grotesk, an Adobe font, which must be installed on the machine that renders the report. Without it, call `theme_set(theme_tweed(base_family = "sans"))`.

## Roadmap

`R/tweed.R` will eventually become a small R package, so the plot and table specifications can be installed once and updated everywhere.
