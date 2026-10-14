# Submission pre-check (updated 14 Oct 2026, after Roo's clearance review at 9d7e8d1)

Word counts: `pdftotext | wc -w` on the anonymised main PDF, including references and tables (Roo's counts at 9d7e8d1 ran about 20-30 words higher than this method). For 03 the count covers the integrated build; the separated main file plus exhibit files comes to 8,836 + 823 words.

## Official guidelines

| Paper | Journal | Source | Length | Spacing / format | Abstract | Keywords / JEL | Review / anonymised MS | Other requirements |
|---|---|---|---|---|---|---|---|---|
| 03 | Feminist Economics (rfec20) | feministeconomics.org style guidelines and submit page (the T&F instructions page blocks automated fetch) | Over 10,000 words, including references, endnotes, tables and figures, is "strongly discouraged"; usually no more than 8 exhibits | Double-spaced, including notes and references (12pt applied as Roo asked) | 150 words or fewer | 3-6 keywords; 1-3 JEL codes | Anonymous review; no author details in the manuscript | Tables and figures as separate files, with position and size marked in the text and captions listed separately; American spelling; "percent" in text |
| 05 | Journal of Marriage and Family | NCFR JMF Style Guide | About 35 pages total; references do not count (Roo's stricter target applied: 35 pages in total) | Double-spaced, ragged right, 12pt Times New Roman, 1-inch margins, pages numbered from the title page | Structured (Objective, Background, Method, Results, Conclusion, optional Implications), about 200-225 words, no first person | Keywords; no JEL | Anonymised manuscript; tables and figures embedded for review | Word file needed at revision; editable tables |
| 06 | Journal of Development Studies (fjds20) | T&F instructions as reported by Roo (the T&F page blocks automated fetch; a secondary summary was cross-checked) | Typically 8,000-10,000 words, including references, footnotes and tables | Margins at least 2.5 cm | 200 words or fewer, unstructured | Keywords | **Single-anonymous** (per Roo) | British (-ise) spelling; **single quotation marks**; figures as separate files; LaTeX source as a single zip; data availability statement; AI declaration |
| 07 | Journal of Time Use Research | journals.uj.ac.za/index.php/jtur/about/submissions | 10,000 words or fewer, including references, notes, tables and figures | No spacing rule; APA references; greyscale figures preferred | Checklist says 150 words or fewer (guidelines elsewhere say 250) | 5-6 keywords | Double-blind; separate title page; fully anonymised manuscript, including file metadata | Tables and figures embedded; data availability statement before the references; generative-AI declaration; preprints allowed if disclosed |

## Measured packages and status

| Paper | Commit | Pages | Spacing | Words | Abstract | Fit (1-10) | Status / flags |
|---|---|---|---|---|---|---|---|
| 03 FE | 17ec3d8 | 38 (main, without exhibits) | 12pt, double | 9,534 (was 9,940) | 132 | 8 | Tables 1-4 and Figure 1 as separate files in package/exhibits, with "[Table N about here]" markers; caption list; American spelling |
| 05 JMF | 5b89582 | **35 total** | 12pt, double | 8,771 | 213 | **7** | Word file in Times New Roman 12pt, double-spaced. **Fit below 8**: JMF is mostly US and European family sociology. SSRN preprint (abstract 5677063) disclosed in the cover letter only |
| 06 JDS | da7f394 | 23 | 11pt, 1.5 | 9,637 (was 9,990) | 150 (≤200) | 8 | Figures in package/figures (PDF and 600 dpi PNG); package/latex_source.zip; data availability statement. Spelling already British. **Open:** JDS asks for single quotation marks (the text uses double) |
| 07 JTUR | 8c396b0 | 25 | 11pt, 1.5 | 9,866 | 144 | 9 | AI declaration (Claude, Anthropic) in the anonymised manuscript; 6 keywords |
