import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/hadgaly_ui.dart';
import 'dashboard_details.dart';
import 'dashboard_provider.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => HadgalyPage(
    title: 'Санхүүгийн тайлан',
    child: ref
        .watch(dashboardProvider)
        .when(
          loading: () => const LoadingContent(),
          error: (_, _) => const PageContent(
            children: [InlineError('Тайланг нээж чадсангүй. Дахин нээгээрэй.')],
          ),
          data: (view) => SingleChildScrollView(
            key: const Key('reportScroll'),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${view.month.year} оны ${view.month.month}-р сар · бүх данс',
                      style: captionStyle,
                    ),
                    DashboardDetails(
                      report: view.report,
                      categories: view.snapshot.categories,
                      month: view.month,
                    ),
                    const Text('Дансны тойм', style: sectionStyle),
                    const SizedBox(height: 8),
                    AccountSummary(snapshot: view.snapshot),
                  ],
                ),
              ),
            ),
          ),
        ),
  );
}
