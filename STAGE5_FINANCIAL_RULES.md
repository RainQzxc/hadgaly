# Stage 5 financial contract — before aggregation implementation

2026-11-04 · CEO #020. Founder explicitly approved Stage 4 in this conversation
at de5ea5d5054b146ae65ad055decc9c2792b0122d. Stage 5 only; no Stage 6.

- Reuse the coherent AccountsSnapshot: latest non-deleted cash snapshots, replayed
  current account balances, default selection and categories (including archived).
  No second revision resolver, cached balances, writes or schema migration.
- All-account scope throughout Home. Current balance is the BigInt sum of current
  replayed account balances, including openings and authoritative anchors.
- Monthly income/expense use existing monthFlows and persisted local entryDate keys:
  [first day, first day of following month). Previous month is the previous calendar
  month, including December/January boundaries. Effective UTC is NOT a reporting date.
- Net cash flow = monthly income minus monthly expense, never current balance.
  Openings, anchors and explanatory adjustment differences never enter monthly flows.
- Category totals use current expense snapshots only in the identical month/scope;
  reconcile exactly to monthly expense. Current taxonomy name/icon/archive status
  applies; historical category references are retained. Sort amount descending then ID.
- Money totals/differences use BigInt, no floating-point money and no aggregate limit
  inherited from the per-entry ±999999999999 balance validation. Each input magnitude
  is validated by the existing domain. Aggregate totals can exceed SQLite int64.
- Comparison difference = current minus previous. Show increase/decrease/unchanged
  neutrally, without treating more spending as success. Percent is abs(diff)/previous,
  rounded half-up to one decimal with integer arithmetic. When previous=0 show no
  percentage; distinguish no activity from newly recorded activity.
- Category percentages use largest-remainder allocation in tenths of a percent,
  ties by category ID: displayed shares sum to exactly 100.0%. Donut geometry alone
  converts those bounded integer shares to double; no monetary sum uses double.
  All positive categories remain in the list, even when share rounds to 0.0%.
- Empty spending uses neutral ring and explanatory text, never invented proportions.
  Month/year are explicit. Refresh at local midnight and resume using existing Home timer.
- Keep approved compact ring/in-ring income/expense, balance emphasis then quick actions
  and history access. Add restrained net/comparison/category/account sections below;
  scroll on small/large-text displays. No new route or account-management duplication.

## Numerical acceptance examples (MNT)

| Scenario | Expected |
|---|---|
| No accounts/entries | Balance0; current/previous flows0; empty breakdown; no percentages |
| Openings1000/−500; current income200 expense50 | Balance650; income200 expense50 net150 |
| Prior-month income100 expense100 | Income +100 (+100.0%); expense −50 (−50.0%) |
| Prior expense0, current50 | Difference+50; previous month no expense; no percent |
| Three expense categories1/1/1 | Total3; shares33.4/33.3/33.3 by ascending ID |
| Expense50→80; move date to prior month; then delete | Current50→80→0→0; prior0→0→80→0 |
| Expense50→income50 | Current expense0 income50; category list empty |
| Archived expense category amount50 | Included50 and marked archived; reference intact |
| Opening1000; earlier income200; anchor900; later expense50 | Balance850; flows200/50/net150 |
| Edit earlier income200→100 | Balance850; income100; original anchor observation unchanged |
| Two accounts each balance=max | Combined1999999999998 exact |
| 10000 income entries of max and matching offsets | Aggregate9999999999990000 exact; no int64/double rounding |
| January2027 current / December2026 previous | Separate calendar keys; no year mixing |

Stage 5 acceptance requires tests, native interactive demo and explicit founder approval.
