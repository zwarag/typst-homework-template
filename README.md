# Typst Homework Template

## Overview
This repository provides a ready-to-use Typst project for homework, reports, or short papers. It builds on the preview `arkheion` template to deliver polished typography out of the box and demonstrates how to organize metadata, sections, citations, mathematics, figures, tables, and appendices in a single document.

## Requirements
- Typst CLI installed locally (https://typst.app/docs/reference/cli/)
- Internet access the first time you compile so Typst can fetch the `@preview/arkheion:0.1.1` package

## Quick Start
1. Install the Typst CLI if you have not already.
2. Clone or download this repository.
3. Run `typst compile main.typ` from the project directory. Typst will produce `main.pdf` alongside the source files.
4. While editing, you can run `typst watch main.typ --open` to keep a PDF preview in sync.

## Customizing the Template
- Update the document metadata near the top of `main.typ`: change the `title`, `authors`, `abstract`, `keywords`, and `date` entries to match your submission.
- Replace the placeholder text (`#lorem(...)`) with your actual content. The sample sections show how to structure headings, paragraphs, math, and cross-references.
- The bibliography is managed through `bibliography.bib`. Add or edit BibLaTeX entries there and keep `#bibliography("bibliography.bib")` at the end of `main.typ`.
- Swap out `image.png` or add additional figures in the `Figures and Tables` section. Point the `image("image.png", width: 30%)` call at your own assets and adjust sizing as needed.

## Repository Layout
- `main.typ` — primary Typst source file with metadata, content examples, and appendix scaffolding.
- `bibliography.bib` — sample BibLaTeX file referenced by the template.
- `image.png` — placeholder image used in the figure example; replace or extend as required.

## Tips
- Use `#cite(...)` with the keys defined in `bibliography.bib` to reference literature. Typst automatically formats citations using the APA style declared via `#set cite(style: "american-psychological-association")`.
- Cross-reference numbered elements (equations, figures, tables) with the labels defined in angled brackets, e.g., `<equation>`, `<figure>`, and refer to them with `@equation` and `@figure`.
- Appendices are enabled through `arkheion-appendices`; add additional appendix sections after the existing example scaffold.

## License
No license has been specified. Add one if you plan to share or distribute this template.
