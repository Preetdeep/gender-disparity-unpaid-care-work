# GResearcher fixes - India TUS 2019 (NSO, Jan-Dec 2019; TimeUse106PER.dta)

Data check: Weight == MULT/100 (verified); one diary day per person; major-activity minutes sum to ~1440 per person.

## Code fixes (all five papers)
1. Removed slice_sample(prop = 0.1) on activity rows (kept ~10% of each person's diary) and the Weight/0.1 rescale. Full sample (450,408 persons).
2. Person ID = FSU_Serial_No + Sample_HH_No + Person_Serial_No (was Gender + Age).
3. SEs clustered at first-stage unit (FSU); HC1 replaced in shopping paper.
4. Survey year corrected to 2019.
5. childcare_vs_eldercare: childcare = division 41, adult care = 42 (were 31/32); aggregated per person.
6. son_preference_care: childcare = 41; composition on distinct persons, own unmarried children (rel 5) <18; parents = head/spouse.
7. Knit bugs: weekend (Highest_Education dropped), son preference (| State after aggregation), marriage (unescaped %), shopping (FSU id lost).
8. Abstracts rewritten to match new estimates. Data path via env var TUS_DTA. No data files committed.

## Old vs new headline estimates
| Paper | Old | New (full data) | Conclusion |
|---|---|---|---|
| Marriage care penalty | Women +2.1 pp, men +0.7 pp | Women +40.4 pp (5.1%->45.5%), men +22.5 pp; Female x Married 17.9 pp raw, 13.8 pp with controls+state FE | Survives, ~10x larger |
| Weekend effect | Women 4.7->4.8%, men 1.5->1.6%; +0.04 min | Women 31.7->32.0%, men 16.1->16.2%; F 44.8->45.8 min, M 13.0->13.8; Female x Weekend ~0 (married minutes -1.4**) | Survives (gap does not widen) |
| Son preference | Mothers +0.3 min with sons | Mothers: only sons 68.7 vs only daughters 79.1 min; Sons x Female -12.9 vs Daughters x Female -4.0 | No son preference; leans to daughters; child age/number confounding |
| Childcare vs eldercare | Gap 3.5 pp childcare, 0.9 pp adult (wrong codes) | Childcare 30.9% vs 15.3% (15.5 pp; 43.4 vs 12.3 min); adult 0.67% vs 0.26% | Old invalid; new childcare gap ~4x |
| Shopping | qualitative | Shopping 42.4% vs 2.4%; 29.7 vs 1.1 min; Female +20.9 min with controls | Survives |

## Still to do
Body-text hard-coded statements (e.g. "2-3 seconds" in weekend) need a line-by-line pass; restrict never-married baseline to 18+; child-age controls in son preference.
