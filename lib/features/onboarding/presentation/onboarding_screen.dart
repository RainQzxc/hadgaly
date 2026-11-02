import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app.dart';
import '../application/onboarding_controller.dart';
import '../../home/presentation/home_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    if (state.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Мэдээлэл нээж байна',
          ),
        ),
      );
    }
    if (state.loadFailed) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(state.error!),
            ),
          ),
        ),
      );
    }
    if (state.step == 4 && state.account != null) {
      return HomeScreen(name: state.nickname);
    }
    return PopScope(
      canPop: !state.busy && (state.step == 0 || state.step == 3),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) state.back();
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              key: ValueKey('step-${state.step}'),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          if (state.step == 1 || state.step == 2)
                            IconButton(
                              onPressed: state.busy ? null : state.back,
                              tooltip: 'Буцах',
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                          const Expanded(
                            child: Text(
                              'хадгалъя',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                color: green,
                              ),
                            ),
                          ),
                          Text(
                            '${state.step + 1} / 4',
                            semanticsLabel:
                                'Танилцах ${state.step + 1}-р алхам, нийт 4',
                          ),
                        ],
                      ),
                      SizedBox(height: constraints.maxHeight > 650 ? 64 : 28),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: mint,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            switch (state.step) {
                              0 => Icons.waving_hand_outlined,
                              1 => Icons.favorite_border_rounded,
                              2 => Icons.account_balance_wallet_outlined,
                              _ => Icons.check_rounded,
                            },
                            color: green,
                            size: 42,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _StepBody(key: ValueKey(state.step), state: state),
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              state.error!,
                              key: const Key('error'),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 28),
                      FilledButton(
                        key: const Key('next'),
                        onPressed: state.busy
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                state.next();
                              },
                        child: Text(
                          state.busy
                              ? 'Хадгалж байна…'
                              : switch (state.step) {
                                  0 => 'Болсон',
                                  1 => 'Эхэлцгээе',
                                  2 => 'Дансаа үүсгэх',
                                  _ => 'Нүүр рүү орох',
                                },
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Таны мэдээлэл зөвхөн энэ төхөөрөмжид хадгалагдана.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: Color(0xFF53655B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepBody extends StatefulWidget {
  const _StepBody({super.key, required this.state});
  final OnboardingController state;
  @override
  State<_StepBody> createState() => _StepBodyState();
}

class _StepBodyState extends State<_StepBody> {
  late final name = TextEditingController(text: widget.state.nickname);
  late final account = TextEditingController(text: widget.state.accountName);
  late final balance = TextEditingController(text: widget.state.balance);
  @override
  void dispose() {
    name.dispose();
    account.dispose();
    balance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final title = switch (state.step) {
      0 => 'Сайн уу? 👋',
      1 => 'Танилцахад таатай байна, ${state.nickname}! 💚',
      2 => 'Эхний дансаа үүсгэе',
      _ => 'Бэлэн боллоо, ${state.nickname}! 🎉',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
        ),
        const SizedBox(height: 16),
        Text(switch (state.step) {
          0 => 'Чамайг хэн гэж дуудах вэ?',
          1 => 'Өдөр тутмын мөнгөө энгийнээр тэмдэглэе. Эхлээд мөнгөө хаана хадгалдгаа оруулъя.',
          2 => 'Бэлэн мөнгө, карт эсвэл өөрийн хүссэн нэрийг өгөөрэй.',
          _ => 'Таны “${state.account?.name ?? ''}” данс үндсэн данс боллоо.',
        }, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 26),
        if (state.step == 0)
          TextField(
            key: const Key('nickname'),
            controller: name,
            enabled: !state.busy,
            decoration: const InputDecoration(
              labelText: 'Дуудах нэр',
              hintText: 'Нэрээ бичээрэй…',
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onChanged: (value) => state.draft(name: value),
            onSubmitted: (_) => state.next(),
          ),
        if (state.step == 2) ...[
          TextField(
            key: const Key('accountName'),
            controller: account,
            enabled: !state.busy,
            decoration: const InputDecoration(
              labelText: 'Дансны нэр',
              hintText: 'Жишээ нь: Миний хэтэвч',
            ),
            textInputAction: TextInputAction.next,
            onChanged: (value) => state.draft(account: value),
          ),
          const SizedBox(height: 20),
          TextField(
            key: const Key('openingBalance'),
            controller: balance,
            enabled: !state.busy,
            decoration: const InputDecoration(
              labelText: 'Эхний үлдэгдэл',
              suffixText: '₮',
              hintText: '0',
            ),
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            textInputAction: TextInputAction.done,
            onChanged: (value) => state.draft(amount: value),
            onSubmitted: (_) => state.next(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Бүхэл төгрөгөөр оруулна. 0 болон сөрөг үлдэгдэл байж болно.',
            style: TextStyle(fontSize: 13, height: 1.6),
          ),
        ],
      ],
    );
  }
}
