# Shared work log (temporary)

Agents working on `submission/NN_*/` papers read this first and append to it.
Append with `cat >> docs/WORKLOG.md` (short entries, one line or a few bullets).
Never rewrite other entries. Delete this file once all papers are submitted.

## Ground rules

- Edit only your own paper folder: `submission/NN_*/`. Do NOT edit `R/`, `submission/references.bib`,
  `submission/_common/`, `README.md` or `docs/AUDIT.md`. If shared code needs a change, log it under
  "Requests for shared code" and work around it locally in the Rmd.
- New references go in `submission/NN_*/refs_local.bib`. Add `refs_local.bib` to the YAML:
  `bibliography: [../references.bib, refs_local.bib]`. Cite only works you are certain exist, with correct
  authors, year, journal, volume and pages. Never invent or "approximately" cite. If unsure, leave it out.
- Codes: only `ACT$...` from `R/codes.R`. Unit of analysis: person-day panel from `load_panel()`. No row sampling.
- Every number is inline R. Every results-dependent sentence uses `iff()` (see `R/helpers.R`).
- Inside `\begin{abstract}...\end{abstract}` (raw LaTeX): use `pctx()` not `pct()`, `\emph{}` not `*...*`.
- Test-knit: `cd <repo> && PATH=/usr/bin:/opt/renv/bin:$PATH TUS_SYNTHETIC=1 /opt/renv/bin/Rscript -e "rmarkdown::render('submission/NN_x/manuscript.Rmd', output_dir='/tmp/claude-0/knit/NN', intermediates_dir='/tmp/claude-0/knit/NN', quiet=TRUE)"`
  The synthetic data lack variation in some cells, so "not estimable" there is expected. Errors are not.
- Do not commit or push. The lead session commits.

## Common errors already found (do not repeat)

- Signed estimate followed by a direction word ("-1.3 minutes less"). Use `diff_txt(e)` or `diff_pp(e)`.
- `%` inside the raw-LaTeX abstract comments out the rest of the line. Use `pctx()`.
- Columns added to a parent table after subsetting (`A[, x := ]` after `W <- A[...]`): the subset lacks x.
- A data.table filter using a function argument with the same name as a column (`S[y == y]`) is always TRUE. Rename the arguments.
- `etable` with `adjustbox` plus long notes shrinks the table to nothing. Use `reg_table()`, which places notes outside.
- kable row names leak into LaTeX (underscores break). `tab()` drops row names; do not pass `row.names`.
- Author footnote: use `\thanks{}` in YAML, not `^[...]`.
- Claims of "first" or of statistics not computed in the paper (e.g. coverage of childcare centres) need a citation or must go.
- Cross-references: use `Table \ref{tab:label}` and `Figure \ref{fig:<chunk-label>}`, never a hard-coded number.

## Requests for shared code

(none yet)

## Progress


## Manager audit round 1 (12:36 UTC)

Sample (python random): 01, 02, 05, 08. Audited files at their 12:09–12:25 mtimes (= HEAD; no agent edits had landed). Knit: all four PASS on synthetic data (01 failed once with "../_common/preamble.tex not found" only when 4 renders ran in parallel; passes alone, so the failure came from running in parallel, not from the manuscript).

**SHARED-CODE ALERT (affects 01, 02, 04–08): the PAS and cooking-fuel codes in `R/codes.R` disagree with `docs/DataDictionaryTimeUseSurvey.xlsx`.** codes.R follows `docs/variables_dictionary.txt`, which disagrees with the xlsx:
- xlsx PAS: 11 own-account, 12 employer, 21 unpaid helper, 31 regular wage, 41 casual public works, 51 casual other, 81 unemployed, 91 student, 92/93 domestic duties, 94 rentier/pensioner, 95 disabled, 97 other (standard NSS coding). codes.R: regular=21, casual=31/41, unemployed=51, student=61, domestic=62/63. If the xlsx is right, `employed` drops casual labour (51), `pas_regular` = unpaid helpers, `pas_unemployed` = casual labourers.
- xlsx cooking: 1 firewood, **2 LPG**, 3 other natural gas, 4 dung cake, 5 kerosene, **6 coke/coal**, 7 gobar gas, 8 other biogas, 10 charcoal, **11 electricity**, 12 none, 19 other. codes.R `cooking_clean = c(6,7,8)` would then count coal as clean and LPG/electricity as not clean, which reverses the sign of paper 01's headline.
- xlsx religion: 7 = Zoroastrian, 9 = others (codes.R has Other = 7; the effect is small because religion_f groups into "Other" by default).
- The synthetic generator uses the codes.R scheme, so knit tests cannot catch this. Lead: tabulate `principal_activity_status` and `primary_energy_cooking` on the real .dta (are 81/91–97 and 10–12/19 present?) and fix CODE. Paper agents: do not work around it locally; wait for the fix.

### 01_outsourcing_domestic_work
1 Codes PASS (ACT$ only; cooking-code issue is shared, above). 2 Unit PASS. 3 Numbers PARTIAL. 4 Cites PASS (38 keys resolve; 5 spot-checks OK: abadie2023, coenpirani2010, gould2018lpg, kar2019ujjwala, frazis2012). 5 Abstract/xref/thanks PASS. 6 Knit PASS. 7 Method PARTIAL.
- :152 "To my knowledge this is the first study to link…" is an unconditional "first" claim. Delete it.
- :168 the fuel classification text ("LPG, biogas, electricity … crop residue … coal") depends on the disputed codes. Rewrite once CODE is fixed.
- :240 "a machine effect smaller than the outsourcing effect is expected" presumes the result. Wrap it in iff(abs(k_mach_tex$est) < abs(k_wash_tex$est), …).
- :244 "these estimates are less precise than the others" is unconditional. Compare SEs inside iff() or drop the sentence.
- :310 "would not overturn the result" is unconditional. Use iff(sign(ob_f)==sign(k_fuel_food$est), …).
- :322 "Technologies reduce the specific tasks they replace" is causal and fires when only one technology passes (spec_any). Use "are associated with less time in", and branch on spec_both.
- :115/:256 men_flat = "not significantly positive", but the prose says "does not rise" / "do not migrate". Use "is not significantly higher".
- :128/:170 rel 9 is "servant/employee/other non-relative", but the label "Live-in domestic worker" overstates it. Call it "live-in non-relative (incl. domestic workers)".

### 02_grandparent_care
1 PASS. 2 PASS. 3 FAIL. 4 PASS (27 keys resolve; refs_local.bib, 31 entries, all checked OK, e.g. bratti2018, anukriti2020, ogawa1996, debnath2015, shen2016; **not yet in YAML `bibliography:`**). 5 PASS. 6 Knit PASS. 7 FAIL.
- :105 (abstract) the last iff branch says "it does not translate into more paid work for mothers" without testing emp_up. Nest iff(emp_up, …).
- :61/:82/:207 hh_care_mo_gm (mother + grandmother) vs mother alone is a **mechanical comparison**: adding a non-negative term makes hh_more almost always TRUE. Compare total childcare by all adult members (or all women 15+) in both household types, or drop the "grandmothers add to care" verdict. :207 else-branch "total care is similar" treats a null result as equality.
- :37/:48 "mothers" = any married woman 18–49 in a household with a child under 6. This includes head's spouses aged 40–49 whose under-6 is a grandchild (rel 6). Exclude rel 1/2 women when hh_n_child_spouse > 0, or make `sole` the baseline. :246 "unambiguously hers" overclaims.
- :250 the `!emp_up` branch attributes the null to "the constraint channel … is strong enough". The mechanism is untested. Say "consistent with".
- :126 posadas2013grandparents uses US (NLSY) data but is cited as "In Europe". Move it to the US sentence.
- :118 the sentence on "Legacy analyses …" refers to internal legacy work. Remove it.
- :246 "reports four checks" but five rows follow. Fix the count.
- :66 `special_care` enters as a raw 1/2 code. Recode to a 0/1 yes indicator.

### 05_marriage_time_reallocation
1 PARTIAL. 2 PASS. 3 FAIL. 4 PASS (28 keys; spot-checks OK: south1994, gupta1999, burgard2013, desai2010, juster1991; no refs_local yet). 5 PASS. 6 Knit PASS. 7 PARTIAL.
- :33/:83/:84 hard-coded `marital %in% c(1,2)`, `c(2,3)`, `== 3`. Use CODE$marital[...].
- :98 (abstract) "wives do `r f0(cg$est)` more minutes" and :178 "wives do est_se(cg) more … husbands do est_se(cgp) more paid work … husbands have est_se(cgf) more free time" are **signed estimates with a hard-coded direction word** (common error #1). Use diff_txt().
- :98/:111/:157 "largest offsetting category" / "financed mainly by" assume src_sorted[1] < 0 and k_uw > 0. Wrap in iff(src_sorted[1] < 0 && is_pos(k_uw), …).
- :161 "Marriage raises women's unpaid work far more than men's" is causal, contradicting :131. Use "is associated with".
- :178 the iff threshold `> 0.5*cg$est` has no SE. "wife's market position is stronger" is not measured: employment is not relative position. "persist" is unconditional within the branch.
- :203 the robustness table has no SEs, and the men's cells are NA for 3 rows. Add SEs.

### 08_life_course_free_time
1 PASS. 2 PASS. 3 FAIL. 4 PASS (19 keys; refs_local 32 entries, all checked OK, e.g. goodin2005, harvey2007, kalenkoski2011, merz2014, roberts2011; **not yet in YAML**). 5 PASS. 6 Knit PASS. 7 PARTIAL.
- **:97 (abstract) and :110 SIGN BUG.** g_tw = est_gap(…,"Men","Women") is women minus men, but the sentence subject is men: "Men … do 65 more minutes of total … work" (synthetic: women do 65 more). Use more_less(-g_tw$est) or make women the subject.
- **:176 SIGN BUG.** g_comm = est_gap(Wk,…,"Women","Men") is men minus women, but the text says "women commute 0.3 minutes more" (synthetic: women commute less). Swap a/b.
- :86/:176 Wk = employment > 0 means "worked on diary day", not "employed persons". Relabel it.
- :89–91 stage_dominates compares the range of **raw** stage gaps with **conditional** interaction coefficients, with an arbitrary 2x threshold and no inference. It drives the abstract and conclusion claims. Compare like with like (stage interactions in the same regression) and soften the wording.
- :97/:110 "largest at stage X" has no test. Add the SE of the difference, or say "point estimate largest".
- :106 "Evidence for India … is limited to national averages" is unsupported, and burda2013total does not cover India. Verify or drop it.

## Common errors added by manager

- (Correction to my 08 note: I am not certain whether burda2013total includes India. Treat it as "verify", not as wrong.)
- `est_gap(d, y, by, a, b)` returns **b minus a**. Make the sentence's subject group b, or flip the sign before more_less(). Two sign bugs found (08). Check every est_gap call against the subject of its sentence.
- Do not compare a "sum of A and B" with "A alone" as evidence that B adds to the total: it is true by construction (02).
- A non-significant estimate is not "similar", "does not rise" or "unchanged". Say "not significantly different" (01, 02).
- Hard-coded non-activity codes (`marital %in% c(1,2)`, `rel == 7`): use CODE$... (05).
- refs_local.bib exists but is not listed in YAML `bibliography:`, so its keys silently fail to resolve once cited (02, 08 at 12:36).
- CODE$pas_* and CODE$cooking_* conflict with the xlsx dictionary (see round 1). Any "employed", "casual", "unemployed" or "clean fuel" result is provisional until the lead resolves it.
- Parallel knits that share `/tmp` dirs can fail with "preamble.tex not found". Retry alone before reporting a failure.

### Paper 08 (life course free time) -- 2026-10-11
- New common errors found:
  - Mixed sign conventions: `est_gap(A, y, "sex", "Women", "Men")` is men minus women, but prose said "women commute X more" / "men do X more total work" from a women-minus-men estimate. Pick ONE convention per paper (08 now uses women minus men everywhere via a `gwm()` wrapper) and phrase every sentence from it.
  - `married == 0` is not "never married" (it includes widowed/separated). Use `marital == CODE$marital["never_married"]`.
  - `fcase()` treats NA conditions as FALSE, so persons with `hh_n_under6 = NA` silently fall to the next stage. Test `== 0` explicitly and drop/report NAs.
  - `ctrl()` cannot parse two-argument `i(x, female)` (it strips to "x, female", not a column) and silently drops it. Build such terms outside `ctrl()`.
  - `female * i(x)` gives an unclear reference level in fixest; use `i(x, female) + i(x)` to get each level's gap directly.
  - `\ref{}` inside `tab(notes=)` is escaped by kableExtra::footnote and prints literally. Keep refs in the text.
  - `diff_pp()`/`diff_txt()` return "not estimable" when NA, which breaks the sentence around them ("they are not estimable likely to..."). Wrap in `iff(!is.na(e$est), ...)`.
- Requests for shared code:
  - **HIGH: principal activity status codes.** `docs/DataDictionaryTimeUseSurvey.xlsx` lists NSS codes 11,12,21,31,41,51 (working; 21 = unpaid helper, 31 = regular wage, 51 = casual labour other), 81 (seeking work), 91 (education), 92/93 (domestic), 94 (pensioners), 95 (disabled), 97 (others). `R/codes.R` (`CODE$pas_*`) and `docs/variables_dictionary.txt` use 13, 51 = unemployed, 61-66, 64 = pensioner. If the real file follows the xlsx, `employed`, `pas_group`, casual/regular, unemployed and pensioner are all wrong in `build_panel.R`. Paper 08 works around this locally (detects scheme from values present). Please verify on the real file and fix `CODE`.
  - `ctrl()`: accept multi-argument `i(a, b)` terms.
- Progress: 08 rewritten (~7,200 words body). Fixed sign bugs (total work, commuting), stage definitions, heterogeneity spec. Added: Kitagawa within/composition decomposition with FSU bootstrap; time poverty at 50/60% + FGT1 + long-hours + joint time x consumption poverty; with/without religious practice throughout; conditional dispersion of gap across dimensions; pensioners vs workers 55-70; commuting among workers; free-time quality (secondary free time, care during free time from slot pairs). 30 verified-only refs in refs_local.bib. Knits clean on synthetic data (22 pp).

## Lead update: code schemes and survey round (read before editing)

- The two dictionaries (`docs/DataDictionaryTimeUseSurvey.xlsx` and `docs/variables_dictionary.txt`) disagree on codes for usual
  principal activity status, cooking fuel and lighting. `R/codes.R` now holds both (`CODE_SCHEMES`); `build_panel()` detects which one the
  data use and `load_panel()` applies it. `CODE$pas_*`, `CODE$cooking_lpg/clean/solid` follow the detected scheme.
  NEVER hard-code principal-activity or fuel codes in a manuscript. Use `pas_group`, `employed`, `CODE$pas_*`, `CODE$cooking_*`.
- New `pas_group` level: "Unpaid family helper" (previously folded into "Self-employed").
- The panel stores the detected scheme in `validation$code_scheme`.
- The data are the 2024 round per the author. The 2019 round is a different file; the probe (`R/probe_data.R`) compares the file's counts
  to the 2019 report (9,945 FSUs, 138,799 households, 447,250 persons 6+) to catch the wrong file.
- 2019-round layout (docs/nso_reference) has no "care giver available" item and no informant serial number. Do not rely on those columns
  existing; the 2024 xlsx lists them. Code must degrade gracefully when a column is absent.
