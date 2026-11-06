# Stage 4 contract — recorded before implementation

CEO #019 · 2026-11-03 · Approved Stage 3: 89b8245674910028eaf3e1d7c05c00cd2c6aff74.
The six-stage roadmap and Stage 2/3 integer range, baseline and anchor rules are unchanged.

## Storage, revisions and atomicity

- Schema v4 adds ONE append-only entry_revisions table; original cash_entries, ledger_sequences,
  categories, accounts, profiles and adjustment/audit rows remain unchanged. No destructive migration.
- Original cash row is revision 0. Each edit appends a complete new financial snapshot, revision +1.
  A confirmed deletion appends a tombstone snapshot; exclude it from visible history, replay and flow
  totals. No restore UI. Retain original and every revision/category reference for integrity evidence.
- Current entry = highest revision, or original when none exists. A single shared resolver feeds both
  balances and history/Home figures. Never count base + revisions as separate cash events.
- Each snapshot has entry/account/category/type/amount/effective position/date/note/deleted flag,
  revision, changed timestamp and unique request key. Previous snapshot supplies the old values;
  original created time/request identity remain on the base row. No duplicate event IDs are allocated.
- SQLite foreign keys, sequential revision guard, append-only triggers and transaction boundaries.
  Optimistic expectedRevision rejects stale edits/deletes. Same request with identical action/payload
  returns the committed result, even after later changes; mismatched reuse fails. Repeated taps cannot
  post twice. An unchanged edit may record one idempotent revision, without affecting money.
- Append snapshot + replay BOTH old and new accounts atomically. Any intermediate/current overflow,
  missing account/category, stale revision, injected failure rolls back the entire revision. Deletion
  also validates replay: removing an offsetting event must not leave overflow hidden by a later anchor.
- Category type must match. An archived category can be retained ONLY by its existing entry with the
  same type; changing to another category requires an active one. Base/old version references survive.

## Ordering and date edits

- Stable global sequence remains original cash entry ID, including account/type changes. The immutable
  registry kind describes ORIGINAL allocation; current kind comes from resolved entry, never registry.
- Amount/note/category/type/account edits with unchanged selected date preserve exact effective UTC
  microsecond and persisted local date key. Moving accounts preserves the existing historical position.
- Changing selected date uses Stage 3 date-only rule: earlier day = end of local day, today = save time,
  clamped against destination account's latest OTHER event. If an older sequence would precede a later
  event at the same instant, advance by one microsecond. No past/future time picker or future scheduling.
- No identity/reordering changes for anchors. Earlier transaction changes recalculate anchor difference,
  not anchor target or originally observed difference. Existing adjustment edit audit remains unchanged.
- Expense/income type supplies sign; magnitude 1..999,999,999,999 MNT. Opening/target can be negative.
  All arithmetic is exact; every intermediate balance stays in the existing supported range.

## History defaults

- One finance history destination, date descending; same-date events effective-time descending then
  stable sequence descending. Cash grouping/filtering uses its persisted selected date; anchors use
  device-local effective date. Amount signs/type labels distinguish ordinary cash and adjustments.
- Filters combine with AND: account, period, income/expense and Unicode-lowercase note substring.
  Period choices: all, current month, previous month, last seven local calendar days (including today).
  No advanced reports or custom period-navigation infrastructure. No history totals that count anchors.
- Default all accounts/all periods/all kinds; all-kinds includes distinctly labeled adjustments.
  Income/expense filter excludes anchors. A nonblank note query matches cash notes only (anchors have
  no note). Date labels numeric YYYY-MM-DD. No persistence for temporary filters/search required.
- Tapping cash opens the existing one-screen form in edit mode, retaining archived category selection.
  Delete requires one Cupertino confirmation. Anchor row opens existing account adjustment/audit view,
  never an income/expense editor. No adjustment deletion is introduced.

## Numerical acceptance cases

| Operation | Expected |
|---|---|
| Opening 1000; income 200 → edit 300 → delete | 1200 →1300 →1000; active history 1→1→0 |
| A opening1000, B opening−500; move income200 A→B | A1000, B−300; same ID/time, one active entry |
| Opening1000; prior income200; anchor900; later expense50 | Current850; anchor original/current −300 |
| Edit prior income200→100 / delete | Current850; current anchor diff −200/−100; original −300 |
| Move later expense50 before anchor / delete | Current900; before-anchor diff recalculated |
| Income200→expense200 before anchor | Target900 unchanged; current difference +100; flow expense200 |
| Earlier anchor target edit with later anchor800 | Later target800 unchanged; adjustment audit preserved |
| Removing expense1 before income=max would overflow | Deletion rejected atomically, no tombstone |
| Same-time edit/type/account change | Original stable sequence preserved, deterministic across reopen |
| Archived category retained / new archived selection | First allowed, second rejected; history refs retained |
| v3 fixture →v4 | Every original field/record and derived balance/default/onboarding preserved |

Stage 4 is NOT accepted until tests + interactive Android review + explicit founder approval.
