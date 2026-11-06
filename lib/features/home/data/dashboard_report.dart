import '../../accounts/data/accounts_repository.dart';
import '../../accounts/domain/ledger.dart';
import '../domain/dashboard.dart';

/// Consumes the existing coherent, resolved ledger snapshot; never queries or writes.
DashboardReport dashboardReport(AccountsSnapshot snapshot, DateTime month) =>
    aggregateDashboard(
      entries: snapshot.entries.map(
        (e) => ReportEntry(
          switch (e.kind) {
            'income' => EventKind.income,
            'expense' => EventKind.expense,
            _ => throw StateError('Unknown cash kind'),
          },
          e.amount,
          e.entryDate,
          e.categoryId,
        ),
      ),
      balances: snapshot.accounts.map((a) => a.balance),
      month: month,
    );
