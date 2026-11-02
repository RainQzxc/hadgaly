import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/hadgaly_ui.dart';
import '../application/onboarding_controller.dart';
import '../../home/presentation/home_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    if (state.loading) {
      return const HadgalyPage(title: 'хадгалъя', child: LoadingContent());
    }
    if (state.loadFailed) {
      return HadgalyPage(
        title: 'хадгалъя',
        child: PageContent(children: [InlineError(state.error!)]),
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
      child: HadgalyPage(
        title: 'хадгалъя',
        onBack: state.step == 1 || state.step == 2 ? state.back : null,
        backEnabled: !state.busy,
        trailing: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            '${state.step + 1} / 4',
            semanticsLabel: 'Танилцах ${state.step + 1}-р алхам, нийт 4',
            style: captionStyle,
          ),
        ),
        child: PageContent(
          scrollKey: ValueKey('step-${state.step}'),
          children: [
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  switch (state.step) {
                    0 => CupertinoIcons.hand_raised,
                    1 => CupertinoIcons.heart,
                    2 => CupertinoIcons.creditcard,
                    _ => CupertinoIcons.check_mark,
                  },
                  color: green,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 28),
            _StepBody(key: ValueKey(state.step), state: state),
            if (state.error != null)
              InlineError(state.error!, key: const Key('error')),
            const SizedBox(height: 28),
            HadgalyButton(
              key: const Key('next'),
              onPressed: state.busy
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      state.next();
                    },
              label: state.busy
                  ? 'Хадгалж байна…'
                  : switch (state.step) {
                      0 => 'Болсон',
                      1 => 'Эхэлцгээе',
                      2 => 'Дансаа үүсгэх',
                      _ => 'Нүүр рүү орох',
                    },
            ),
            const SizedBox(height: 24),
            const Text(
              'Таны мэдээлэл зөвхөн энэ төхөөрөмжид хадгалагдана.',
              textAlign: TextAlign.center,
              style: captionStyle,
            ),
          ],
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
        Semantics(header: true, child: Text(title, style: headingStyle)),
        const SizedBox(height: 16),
        Text(switch (state.step) {
          0 => 'Чамайг хэн гэж дуудах вэ?',
          1 => 'Өдөр тутмын мөнгөө энгийнээр тэмдэглэе. Эхлээд мөнгөө хаана хадгалдгаа оруулъя.',
          2 => 'Бэлэн мөнгө, карт эсвэл өөрийн хүссэн нэрийг өгөөрэй.',
          _ => 'Таны “${state.account?.name ?? ''}” данс үндсэн данс боллоо.',
        }),
        const SizedBox(height: 28),
        if (state.step == 0)
          HadgalyField(
            fieldKey: const Key('nickname'),
            controller: name,
            label: 'Дуудах нэр',
            placeholder: 'Нэрээ бичээрэй…',
            enabled: !state.busy,
            onChanged: (v) => state.draft(name: v),
            onSubmitted: (_) => state.next(),
          ),
        if (state.step == 2) ...[
          HadgalyField(
            fieldKey: const Key('accountName'),
            controller: account,
            label: 'Дансны нэр',
            placeholder: 'Жишээ нь: Миний хэтэвч',
            enabled: !state.busy,
            action: TextInputAction.next,
            onChanged: (v) => state.draft(account: v),
          ),
          const SizedBox(height: 20),
          HadgalyField(
            fieldKey: const Key('openingBalance'),
            controller: balance,
            label: 'Эхний үлдэгдэл',
            placeholder: '0',
            money: true,
            enabled: !state.busy,
            onChanged: (v) => state.draft(amount: v),
            onSubmitted: (_) => state.next(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Бүхэл төгрөгөөр оруулна. 0 болон сөрөг үлдэгдэл байж болно.',
            style: captionStyle,
          ),
        ],
      ],
    );
  }
}
