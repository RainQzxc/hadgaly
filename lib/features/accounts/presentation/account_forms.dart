import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/money.dart';
import '../../../core/presentation/hadgaly_ui.dart';
import '../application/accounts_providers.dart';
import '../data/accounts_repository.dart';

class AccountFormScreen extends ConsumerStatefulWidget {
  const AccountFormScreen({super.key, this.account});
  final AccountView? account;
  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<AccountFormScreen> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(
    text: widget.account?.account.name ?? '',
  );
  final balance = TextEditingController();
  final requestKey = newRequestKey();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    name.dispose();
    balance.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (busy || !form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final repo = ref.read(accountsRepositoryProvider);
      if (widget.account == null) {
        await repo.createAccount(name.text, balance.text, requestKey);
      } else {
        await repo.renameAccount(widget.account!.account.id, name.text);
      }
      if (mounted) Navigator.pop(context);
    } on FormatException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Хадгалж чадсангүй. Дахин оролдоорой.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: HadgalyPage(
      title: widget.account == null ? 'Данс нэмэх' : 'Нэр засах',
      backEnabled: !busy,
      child: Form(
        key: form,
        child: PageContent(
          children: [
            Text(
              widget.account == null ? 'Шинэ данс' : 'Дансны нэр засах',
              style: headingStyle,
            ),
            const SizedBox(height: 12),
            const Text(
              'Өөрт ойлгомжтой нэр өгөөрэй.',
              style: TextStyle(color: secondaryInk),
            ),
            const SizedBox(height: 28),
            HadgalyField(
              fieldKey: const Key('accountName'),
              controller: name,
              label: 'Дансны нэр',
              enabled: !busy,
              action: widget.account == null
                  ? TextInputAction.next
                  : TextInputAction.done,
              validator: nameError,
              onSubmitted: (_) {
                if (widget.account != null) save();
              },
            ),
            if (widget.account == null) ...[
              const SizedBox(height: 20),
              HadgalyField(
                fieldKey: const Key('openingBalance'),
                controller: balance,
                label: 'Эхний үлдэгдэл',
                placeholder: '0',
                enabled: !busy,
                money: true,
                validator: amountError,
                onSubmitted: (_) => save(),
              ),
              const SizedBox(height: 12),
              const Text(
                '0 болон сөрөг үлдэгдэл байж болно.',
                style: captionStyle,
              ),
            ],
            if (error != null) ErrorMessage(error!),
            const SizedBox(height: 28),
            HadgalyButton(
              key: const Key('accountSave'),
              label: busy ? 'Хадгалж байна…' : 'Хадгалах',
              onPressed: busy ? null : save,
            ),
          ],
        ),
      ),
    ),
  );
}

class BalanceFormScreen extends ConsumerStatefulWidget {
  const BalanceFormScreen({super.key, required this.account, this.adjustment});
  final AccountView account;
  final AdjustmentView? adjustment;
  @override
  ConsumerState<BalanceFormScreen> createState() => _BalanceFormState();
}

class _BalanceFormState extends ConsumerState<BalanceFormScreen> {
  final form = GlobalKey<FormState>();
  late final amount = TextEditingController(
    text: widget.adjustment?.record.target.toString() ?? '',
  );
  final requestKey = newRequestKey();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (busy || !form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final repo = ref.read(accountsRepositoryProvider);
      final adjustment = widget.adjustment;
      if (adjustment == null) {
        await repo.adjustBalance(
          widget.account.account.id,
          amount.text,
          requestKey,
        );
      } else {
        await repo.editAdjustment(
          adjustment.record.id,
          amount.text,
          adjustment.record.revision,
          requestKey,
        );
      }
      if (mounted) Navigator.pop(context);
    } on FormatException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Хадгалж чадсангүй. Дахин оролдоорой.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: HadgalyPage(
      title: widget.adjustment == null ? 'Тохируулах' : 'Дүн засах',
      backEnabled: !busy,
      child: Form(
        key: form,
        child: PageContent(
          children: [
            Text(
              widget.adjustment == null
                  ? 'Үлдэгдэл тохируулах'
                  : 'Тохируулгын дүн засах',
              style: headingStyle,
            ),
            const SizedBox(height: 20),
            Text(widget.account.account.name, style: sectionStyle),
            const SizedBox(height: 8),
            Text(
              widget.adjustment == null
                  ? 'Одоо бүртгэлтэй: ${formatMnt(widget.account.balance)}'
                  : 'Хүчинтэй огноо: ${displayTime(widget.adjustment!.record.effectiveAt)}',
              style: captionStyle,
            ),
            const SizedBox(height: 24),
            Text(
              widget.adjustment == null
                  ? 'Яг одоогийн бодит үлдэгдлээ оруулаарай.'
                  : 'Тухайн үеийн зөв үлдэгдлийг оруулаарай. Хүчинтэй огноо хэвээр үлдэнэ.',
            ),
            const SizedBox(height: 24),
            HadgalyField(
              fieldKey: const Key('targetBalance'),
              controller: amount,
              label: 'Бодит үлдэгдэл',
              money: true,
              enabled: !busy,
              validator: amountError,
              onSubmitted: (_) => save(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Энэ тохируулга орлого, зарлагад тооцогдохгүй.',
              style: captionStyle,
            ),
            if (error != null) ErrorMessage(error!),
            const SizedBox(height: 28),
            HadgalyButton(
              key: const Key('adjustmentSave'),
              label: busy ? 'Хадгалж байна…' : 'Хадгалах',
              onPressed: busy ? null : save,
            ),
          ],
        ),
      ),
    ),
  );
}

String? nameError(String? value) {
  try {
    validateName(value ?? '', label: 'Дансны нэр');
    return null;
  } on FormatException catch (e) {
    return e.message;
  }
}

String? amountError(String? value) {
  try {
    parseMnt(value ?? '');
    return null;
  } on FormatException catch (e) {
    return e.message;
  }
}

String displayTime(int micros) {
  final d = DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true).toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}.${two(d.month)}.${two(d.day)} ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
}

class ErrorMessage extends StatelessWidget {
  const ErrorMessage(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => InlineError(message);
}
