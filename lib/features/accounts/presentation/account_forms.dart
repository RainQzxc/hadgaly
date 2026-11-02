import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/money.dart';
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
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.account == null ? 'Данс нэмэх' : 'Дансны нэр засах'),
      ),
      body: Form(
        key: form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Өөрт ойлгомжтой нэр өгөөрэй.'),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('accountName'),
                    controller: name,
                    enabled: !busy,
                    decoration: const InputDecoration(labelText: 'Дансны нэр'),
                    textInputAction: widget.account == null
                        ? TextInputAction.next
                        : TextInputAction.done,
                    validator: (v) => nameError(v),
                    onFieldSubmitted: (_) {
                      if (widget.account != null) save();
                    },
                  ),
                  if (widget.account == null) ...[
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const Key('openingBalance'),
                      controller: balance,
                      enabled: !busy,
                      decoration: const InputDecoration(
                        labelText: 'Эхний үлдэгдэл',
                        suffixText: '₮',
                        hintText: '0',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                      ),
                      textInputAction: TextInputAction.done,
                      validator: amountError,
                      onFieldSubmitted: (_) => save(),
                    ),
                    const SizedBox(height: 12),
                    const Text('0 болон сөрөг үлдэгдэл байж болно.'),
                  ],
                  if (error != null) ErrorMessage(error!),
                  const SizedBox(height: 28),
                  FilledButton(
                    key: const Key('accountSave'),
                    onPressed: busy ? null : save,
                    child: Text(busy ? 'Хадгалж байна…' : 'Хадгалах'),
                  ),
                ],
              ),
            ),
          ),
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
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.adjustment == null
              ? 'Үлдэгдэл тохируулах'
              : 'Тохируулгын дүн засах',
        ),
      ),
      body: Form(
        key: form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.account.account.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.adjustment == null
                        ? 'Одоо бүртгэлтэй: ${formatMnt(widget.account.balance)}'
                        : 'Хүчинтэй огноо: ${displayTime(widget.adjustment!.record.effectiveAt)}',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.adjustment == null
                        ? 'Яг одоогийн бодит үлдэгдлээ оруулаарай.'
                        : 'Тухайн үеийн зөв үлдэгдлийг оруулаарай. Хүчинтэй огноо хэвээр үлдэнэ.',
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('targetBalance'),
                    controller: amount,
                    enabled: !busy,
                    decoration: const InputDecoration(
                      labelText: 'Бодит үлдэгдэл',
                      suffixText: '₮',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                    ),
                    textInputAction: TextInputAction.done,
                    validator: amountError,
                    onFieldSubmitted: (_) => save(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Энэ тохируулга орлого, зарлагад тооцогдохгүй.'),
                  if (error != null) ErrorMessage(error!),
                  const SizedBox(height: 28),
                  FilledButton(
                    key: const Key('adjustmentSave'),
                    onPressed: busy ? null : save,
                    child: Text(busy ? 'Хадгалж байна…' : 'Хадгалах'),
                  ),
                ],
              ),
            ),
          ),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    ),
  );
}
