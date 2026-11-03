import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/application/onboarding_controller.dart';
import '../data/transactions_repository.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => TransactionsRepository(ref.watch(databaseProvider)),
);
final categoriesProvider = StreamProvider(
  (ref) => ref.watch(transactionsRepositoryProvider).watchCategories(),
);
final entriesProvider = StreamProvider(
  (ref) => ref.watch(transactionsRepositoryProvider).watchEntries(),
);
