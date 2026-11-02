# Stage 2 financial contract — recorded before implementation

2026-11-02. Founder explicitly accepted Stage 1 and authorized Stage 2 only.
The latest authorization supersedes older unresolved adjustment mechanics in the handoff.
This document applies the supplied rules with the minimal engineering defaults below.

## Ordering and amounts

- Integer MNT only; existing inclusive input/balance range ±999,999,999,999 is retained.
  Intermediate balances must remain in this range. BigInt is used while validating arithmetic,
  then converted to int; totals use BigInt. Explanatory differences may reach ±1,999,999,999,998.
- Opening balance is the initial baseline, before every event. Stage 1 has no opening timestamp;
  migration preserves this baseline exactly rather than inventing a historical date.
- Each account replays its events ordered by `(effectiveAtUtcMicroseconds, stableSequence)`.
  Sequences are positive and unique; ties must never depend on query order or edit timestamp.
- Stage 2 stores adjustments only; their autoincrement primary key supplies the stable sequence.
  Transaction scenarios are **pure domain fixtures**, with explicit unique sequences. Stage 3 must
  allocate comparable unique event ordering when transaction persistence is authorized; no
  transaction tables, transaction editing API or entry UI are introduced now.
- New adjustments have no date input. Capture device UTC now at atomic save, and clamp effective
  time to the account's latest adjustment time if the device clock moved backward. The new sequence
  then follows that anchor at the same effective time. Keep actual creation time separately.
  This prevents a newly requested current balance being inserted before an existing anchor.
- Display timestamps in device local time, including date and seconds; stored microseconds and
  sequence remain authoritative. Editing never changes either effective time or stable sequence.

## Replay and original observation

1. Start at the account opening balance. Sort a copy of events, rejecting duplicate sequences.
2. Income adds its strictly positive integer amount; expense subtracts it.
3. For an adjustment, record `recalculatedDifference = target - balanceBefore`, then set
   `balanceAfter = target`. Never add the original difference to the current replay balance.
4. Continue through later events. Every later adjustment sets its own target again.
5. Income/expense totals include only those event kinds. Opening and adjustments are excluded;
   net cash flow is income minus expense, never the account balance.

When creating an adjustment, persist immutable original target and observed balance before it.
`originalObservedDifference = originalTarget - originalBalanceBefore` is permanently reconstructible.
An edit changes the current target only; current replay recalculates the explanatory difference.
The UI labels the original observation and current recalculated difference separately.
Backdated fixture add/edit/delete changes replay before anchors, without rewriting original evidence.

## Edits, audit and atomicity

- Adjustment deletion is not offered. Database triggers prevent deleting adjustments/audit rows,
  modifying original observation/effective ordering, or changing existing audit entries.
- Every actual amount edit appends old target, new target and device UTC edit time in the same
  transaction as updating the target/revision. Audit row id orders edits sharing a timestamp.
- Optimistic revision checking rejects stale edits instead of silently overwriting a newer amount.
  Saving the unchanged amount is a no-op, without a fictitious audit edit.
- Each create/edit form owns a random request key, reused on retries. Unique constraints and a
  transactional request lookup make repeated saves idempotent. Reusing a key for a different
  account/payload is an error. Busy guards prevent repeated taps while a write is in progress.
- Account creation, renaming, default selection, adjustment creation and edits are atomic.
  Read coherent snapshots in a database transaction; streams refresh Home and My Accounts.
  Do not cache a mutable financial balance in the account row.
- Migration v1→v2 only adds nullable account creation keys and new adjustment/audit tables/indexes;
  existing account ids/names/openings, default id, nickname and onboarding drafts remain intact.
  No destructive reset or tool reinstallation.

## Numerical acceptance cases (MNT)

| Fixture / action | Expected result |
|---|---|
| Opening 1,000; no events | Balance 1,000; income/expense/net 0 |
| Opening 0 / −500 | Balance 0 / −500 |
| Opening 1,000; income 200; anchor A=900 | Before A=1,200; original/current difference −300; balance 900 |
| Add backdated income 100 before A | Before A=1,300; current difference −400; original −300; balance 900 |
| Edit that extra income 100→50 | Before A=1,250; current difference −350; original −300; balance 900 |
| Delete the extra income | Before A=1,200; current difference −300; balance 900 |
| Add expense 50 after A | Current balance 850; A remains 900 |
| Edit post-A expense 50→70 / delete it | Current balance 830 / 900 |
| Opening 1,000; A=900; expense 50; B=800; income 70 | Current 870; A difference −100; B difference −50 |
| Edit A 900→950 in that chain | Current still 870; B target 800; B recalculated difference −100, original −50; audit 900→950 |
| Then edit B 800→750 | Current 820; audit B 800→750; both effective positions unchanged |
| Same instant: income 200 seq1; A=900 seq2; expense 50 seq3; B=800 seq4 | Opening 1,000 → 1,200 → 900 → 850 → 800, regardless input list order |
| Adjustments mixed with income 200, expense 50 | Income 200, expense 50, net 150; adjustments excluded |
| Target −max after opening +max | Target valid; difference −1,999,999,999,998 exact |
| Income fixture would exceed +max | Explicit range error, no wrapped/truncated balance |
| Inject failure during audit insertion | Target/revision/audit all roll back |
| Same request submitted twice | One account/adjustment/audit edit only |
| v1 completed or partial profile upgraded; close/reopen | Original data unchanged; adjustments/default edits remain durable |

Stage 2 acceptance still requires tests, interactive Android demo and explicit founder approval.
