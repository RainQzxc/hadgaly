import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/application/accounts_providers.dart';
import '../../accounts/data/accounts_repository.dart';
import '../data/dashboard_report.dart';
import '../domain/dashboard.dart';

typedef DashboardView = ({
  AccountsSnapshot snapshot,
  DashboardReport report,
  DateTime month,
});

/// One existing aggregation for both presentation routes, not separate pipelines.
final dashboardProvider = Provider.autoDispose<AsyncValue<DashboardView>>((
  ref,
) {
  final month = ref.watch(_reportingDateProvider);
  return ref
      .watch(accountsProvider)
      .whenData(
        (snapshot) => (
          snapshot: snapshot,
          report: dashboardReport(snapshot, month),
          month: month,
        ),
      );
});

// UI clock only: preserve Home's midnight/resume refresh on the report route too.
final _reportingDateProvider = Provider.autoDispose<DateTime>((ref) {
  final now = DateTime.now();
  final timer = Timer(
    DateTime(now.year, now.month, now.day + 1).difference(now),
    ref.invalidateSelf,
  );
  final observer = _ResumeObserver(ref.invalidateSelf);
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() {
    timer.cancel();
    WidgetsBinding.instance.removeObserver(observer);
  });
  return now;
});

class _ResumeObserver extends WidgetsBindingObserver {
  _ResumeObserver(this.refresh);
  final VoidCallback refresh;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }
}
