import 'package:flutter/cupertino.dart';

import '../../../core/presentation/hadgaly_ui.dart';
import '../../accounts/data/accounts_repository.dart';
import '../../onboarding/data/app_database.dart';
import '../../transactions/domain/entry_rules.dart';
import '../domain/dashboard.dart';

const _chartColors = [
  midnight,
  teal,
  expense,
  Color(0xFF7186A2),
  Color(0xFF967B98),
  Color(0xFFB29C70),
];
Color categoryColor(int id) =>
    _chartColors[(id + 1).abs() % _chartColors.length];

class ExpenseRing extends CustomPainter {
  ExpenseRing(this.shares);
  final List<CategoryShare> shares;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(5);
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(rect.width / 2)),
      );
    final brush = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = line;
    canvas.drawPath(path, brush);
    final metric = path.computeMetrics().single;
    var start = 0;
    for (final share in shares) {
      canvas.drawPath(
        metric.extractPath(
          metric.length * start / 1000,
          metric.length * (start + share.tenths) / 1000,
        ),
        brush..color = categoryColor(share.id),
      );
      start += share.tenths;
    }
  }

  @override
  bool shouldRepaint(ExpenseRing oldDelegate) => oldDelegate.shares != shares;
}

class DashboardDetails extends StatelessWidget {
  const DashboardDetails({
    super.key,
    required this.report,
    required this.categories,
    required this.month,
  });
  final DashboardReport report;
  final List<Category> categories;
  final DateTime month;
  @override
  Widget build(BuildContext context) {
    final byId = {for (final c in categories) c.id: c};
    final previous = DateTime(month.year, month.month - 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Text('Энэ сарын орлого − зарлага', style: captionStyle),
        const SizedBox(height: 4),
        Text(
          'Цэвэр: ${signedMoney(report.net)}',
          key: const Key('monthlyNet'),
          style: sectionStyle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 24),
        const Text('Зарлагын задаргаа', style: sectionStyle),
        const SizedBox(height: 8),
        if (report.categories.isEmpty)
          const Text('Энэ сард зарлага бүртгэгдээгүй.', style: captionStyle)
        else
          for (final share in report.categories)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 12),
                    child: ExcludeSemantics(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: categoryColor(share.id),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: DashboardValueRow(
                      leading: Text(
                        '${byId[share.id]?.name ?? 'Ангилал'}${byId[share.id]?.archived == true ? ' · архив' : ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: ink,
                        ),
                      ),
                      value: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: formatFlow(share.amount),
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                                color: ink,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' · ${percentLabel(BigInt.from(share.tenths))}',
                              style: captionStyle,
                            ),
                          ],
                        ),
                        key: Key('categoryShare-${share.id}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 24),
        const Text('Сарын харьцуулалт', style: sectionStyle),
        Text(
          '${previous.year}.${previous.month.toString().padLeft(2, '0')} → ${month.year}.${month.month.toString().padLeft(2, '0')} · энэ сар одоогоор',
          style: captionStyle,
        ),
        const SizedBox(height: 8),
        _Comparison(label: 'Орлого', value: report.income),
        _Comparison(label: 'Зарлага', value: report.expense),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({required this.label, required this.value});
  final String label;
  final MonthComparison value;
  @override
  Widget build(BuildContext context) {
    final diff = value.difference;
    final percent = value.percentTenths;
    final direction = diff == BigInt.zero
        ? 'Өөрчлөлтгүй'
        : diff.isNegative
        ? 'Буурсан'
        : 'Өссөн';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: line, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardValueRow(
            leading: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: ink,
                fontWeight: FontWeight.w500,
              ),
            ),
            value: Text(
              formatFlow(value.current),
              key: Key('comparison-current-$label'),
              style: const TextStyle(
                fontSize: 20,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('Өмнөх: ${formatFlow(value.previous)}', style: captionStyle),
          Text(
            '$direction · ${signedMoney(diff)}${percent == null ? '' : ' (${diff.isNegative
                      ? '−'
                      : diff > BigInt.zero
                      ? '+'
                      : ''}${percentLabel(percent)})'}',
            key: Key('comparison-$label'),
            style: captionStyle,
          ),
        ],
      ),
    );
  }
}

/// One alignment rule for amounts and names; scale/width can expand vertically.
class DashboardValueRow extends StatelessWidget {
  const DashboardValueRow({
    super.key,
    required this.leading,
    required this.value,
  });
  final Widget leading, value;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      if (bounds.maxWidth < 340 ||
          MediaQuery.textScalerOf(context).scale(16) > 21) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [leading, const SizedBox(height: 4), value],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: leading),
          const SizedBox(width: 16),
          Flexible(
            child: Align(alignment: Alignment.centerRight, child: value),
          ),
        ],
      );
    },
  );
}

class AccountSummary extends StatelessWidget {
  const AccountSummary({super.key, required this.snapshot});
  final AccountsSnapshot snapshot;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final view in snapshot.accounts)
        Container(
          key: Key('overview-account-${view.account.id}'),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: line)),
          ),
          child: DashboardValueRow(
            leading: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  view.account.name,
                  style: const TextStyle(fontSize: 16, height: 1.4, color: ink),
                ),
                if (view.account.id == snapshot.defaultId)
                  Text(
                    'Үндсэн данс',
                    key: Key('overview-default-${view.account.id}'),
                    style: captionStyle.copyWith(
                      color: incomeInk,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            value: Text(
              signedMoney(BigInt.from(view.balance)).replaceFirst('+', ''),
              key: Key('overview-balance-${view.account.id}'),
              style: sectionStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
    ],
  );
}
