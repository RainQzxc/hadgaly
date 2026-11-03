# Stage 3 financial contract — before implementation

CEO #016, 2026-11-03. Stage 2 explicitly approved at
`816af0e67bb92736ae1c887af9a2f5d2ab45dadc`. Its anchor/audit/range rules remain authoritative.
Scope: manual entry and category management only, not Stage 4 transaction history/edit/delete.

## Exact money, chronology and atomic posting

- Entry amounts are strictly positive whole MNT, 1..999,999,999,999 inclusive. Type supplies sign;
  zero/negative/fractional/exponent/overflow inputs fail explicitly. Opening/anchor negatives remain valid.
- Reuse the existing pure Dart replay unchanged: opening baseline, then effective UTC microsecond,
  then stable positive sequence. Every intermediate account balance must stay within the existing range.
  Adjustment sets its target; it is never ordinary income/expense. Original observed difference is immutable;
  current difference is recalculated when earlier entries are posted or an anchor amount is edited.
- A single SQLite AUTOINCREMENT sequence registry allocates identifiers for **both** new adjustments
  and cash entries. Existing adjustment IDs are inserted into the registry unchanged in v2→v3 migration.
  Future adjustment IDs may have gaps from transactions; existing effective positions/IDs/audits do not change.
  Same-time events sort deterministically by these global IDs. No independent transaction counter collisions.
- Sequence allocation, entry insert and full affected-account replay validation happen in one DB transaction.
  Failure (including any intermediate overflow) rolls everything back. Balances are derived, never cached.
- Per-form random request key + unique constraint + busy guard make retries/double taps idempotent.
  A retry with an identical payload returns the original entry even if its category was archived afterward;
  reuse with different payload is rejected. No partial posting or duplicate transaction.

## Date and note defaults

- The entry screen has a **date** picker, not a time picker. Default is device-local today.
  Only 1970-01-01 through today are supported; future scheduling is outside this release.
- Today posts at save-time UTC. Like current-time anchors, clock rollback clamps effective time to
  the account's latest effective event so a newly entered “now” operation follows that position.
  Actual creation time is preserved separately.
- A selected past date posts at the **end of that local calendar day**, converted to UTC; ties use sequence.
  This gives date-only entries a deterministic position, including DST day boundaries, without guessing
  an unknown historical time. A transaction on a past anchor's same date can therefore follow it;
  an entry on an earlier day precedes it. Today always means a new current-time operation.
- Persist the selected local date key alongside effective/creation time. Current-month income/expense
  figures use that selected calendar date; anchors/openings are excluded. No timezone rewrite on restart.
- Note is optional, trimmed, at most 500 Unicode code points; no NUL/control characters except newline/tab.
  No automatic financial logging or upload.

## Categories

- Separate income/expense categories, fixed transaction type; initial catalog is seeded once atomically.
  User categories have required names and a fixed set of bundled Cupertino icon identifiers.
- Active names are unique per type after trim + Unicode lowercase. No new package for normalization.
- Name/icon can be edited; type cannot. Archive hides a category from new selections, never deletes it
  or its references/entries. Existing transactions remain immutable and join their retained category.
  A renamed category has its current taxonomy name; financial amounts/date/account remain unchanged.
- No transaction edit/delete API/UI in Stage 3. Future Stage 4 work must explicitly extend these rules.

## Numerical / migration acceptance cases

| Case | Expected |
|---|---|
| Opening 1,000; income 200 / expense 300 | Current 1,200 / 700; flow totals only entry kinds |
| Opening 1,000; anchor A=900; later expense 50 | Current 850; original A difference −100 |
| Add 200 income on an earlier day before A | Current still 850; A current difference −300, original −100 |
| Edit A target to 950 in that case | Current 900; effective/sequence unchanged; old/new audit appended |
| A=900; B=800; add earlier expense 40 | B target remains 800; original observations retained |
| Same timestamp: anchor seq1; income seq2; anchor seq3; expense seq4 | Order stable across reopen; later target authoritative |
| Expense from zero opening | Negative balance allowed within range |
| Entry causes pre-anchor or current overflow | Entire insert/allocation rolls back even if later anchor would hide it |
| Same request saved twice / canceled form | One posting / zero postings |
| Category archived after posting | Entry/category reference/amount/balance survive close/reopen |
| v1→v2→v3 and preserved synthetic v2→v3 | Original account/profile/adjustment/audit fields unchanged |

Production migration checks must compare existing real records separately from synthetic fixture evidence.
No uninstall/clear/wipe fallback. Main data is preserved outside Git before the additive upgrade.
Home keeps its approved composition. Existing period figures reflect real entries; the neutral ring does
not fabricate category proportions. Full category-distribution/report UI remains Stage 5.
Stage 3 is complete only after tests + live demo + explicit founder approval; no Stage 4.
