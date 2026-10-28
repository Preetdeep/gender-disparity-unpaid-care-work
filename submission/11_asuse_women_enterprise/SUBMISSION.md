# Paper 11: Women's enterprise ownership in India, 2015-16 to 2023-24

Status (28 Oct 2026): submitted to Small Business Economics via Springer Nature SNAPP on 28 Oct 2026, submission ID 8084ceea-5a58-494b-841a-01154c5e590a (v1.0), status Technical check. Subscription model, no fees, no preprint. Final files in package/.

## Question and novelty
Where did the rise in women's ownership of unincorporated non-agricultural enterprises come from, and what do these enterprises earn relative to women's outside option?
1. Count decomposition of the rise in female-proprietor enterprises by cell (activity x home/outside x mainly-on-contract x rural/urban) plus within/between shift-share of the female share.
2. Profile of the growth margin (female OAEs at home).
3. Returns (monthly GVA per worker, per hour) benchmarked against PLFS 2023-24 women's casual wage and self-employment earnings.
Closest work (all checked on Crossref): Bose 2023 SBE 60(1) (2015-16, manufacturing only, productivity penalty of home-based women-owned firms); Kesar 2024 Dev & Change (2015-16 subcontracting); Mohanan & Kar 2025 RAS (ASUSE manufacturing, job work); Shuvam & Mohanty 2023 GBR (necessity vs opportunity). None does the 2015-16 to 2023-24 decomposition across all three sectors by home x contract, or the outside-option benchmark.

## Target journal
Small Business Economics (Springer). ABDC 2025 JQL rating **A** (ISSN 0921-898X, FoR 3507; /workspace/abdc/jql2025.xlsx). No submission or page fee; open access optional (not to be chosen). Not on the used list. Limits: 8,000 words including references; abstract 150-250 words; 4-6 keywords; Plain English Summary <= 150 words; JEL codes; double-anonymous via SNAPP. Fallbacks: Work, Employment and Society (A), International Small Business Journal (A).

## Data (outside the repo; never commit)
- `~/GResearcher_runs/data_raw/asuse2324/` ASUSE 2023-24, microdata.gov.in catalog 238: all 16 level files `asuse_2324_esu_l01.txt` ... `l16.txt` (needed: l02, l03, l08, l09).
- `~/GResearcher_runs/data_raw/nss73/` NSS 73rd round Sch 2.34, catalog 139: Blocks 2, 7, 8 for both semi-rounds (NADA export, .dta/.csv), plus `Data_Layout73234.xls`.
- `~/GResearcher_runs/data_raw/plfs2324/` PLFS 2023-24 (already there).

## Files
- `plfs_benchmark.R`: PLFS 2023-24 outside option. Run on the Mac; validated: women's casual wage by quarter within Rs 2/day rural, about Rs 7 urban; male within Rs 1; self-employed women's 30-day earnings within about 1%.
- `analysis_asuse.R`: reads both enterprise rounds, validates 8 published headline numbers (NSS73 KI report; ASUSE 2023-24 factsheet), builds the harmonised frame and writes `~/GResearcher_runs/data_derived/p11/p11_results.rds`.
- `tests_synthetic.R`: smoke test on random data in the published formats (no real data; writes only to a temp dir). Passed on the Mac (with survey) and the box (without regressions).
- `manuscript.Rmd`, `knit.R`, `build_pdf.sh` (DRAFT=1 watermark), `refs_local.bib`, `apa.csl`, `preamble.inc`, `ANONYMISATION.md`.
- `package/`: manuscript_author.pdf, manuscript_anonymised.pdf (both DRAFT, numbers show "[pending ...]"), title_page.md/.pdf, cover_letter.md/.pdf, keywords.txt.

## To finish
1. Download the unit data above (Doc logs in; captcha), place in data_raw.
2. On the Mac: `Rscript plfs_benchmark.R && Rscript analysis_asuse.R`; check the VAL table (every |pct_diff| should be small; 26.2% ASUSE share may be over proprietary establishments rather than all, check the denominator).
3. Knit on the Mac (`Rscript knit.R && ./build_pdf.sh`), write Discussion and Conclusion from the results, fill the cover-letter findings and word count.
4. Show Doc the drafts; Doc approves; Roo submits; Doc types passwords.
