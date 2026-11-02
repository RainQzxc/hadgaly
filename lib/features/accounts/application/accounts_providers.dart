import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/application/onboarding_controller.dart';
import '../data/accounts_repository.dart';

final accountsRepositoryProvider = Provider<AccountsRepository>(
  (ref) => AccountsRepository(ref.watch(databaseProvider)),
);
final accountsProvider = StreamProvider<AccountsSnapshot>(
  (ref) => ref.watch(accountsRepositoryProvider).watch(),
);

String newRequestKey() {
  final random = Random.secure();
  return List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
