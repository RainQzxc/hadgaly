import 'package:hadgaly/features/accounts/data/accounts_repository.dart';
import 'package:hadgaly/features/accounts/domain/ledger.dart';
import 'package:hadgaly/features/onboarding/data/app_database.dart';
import 'package:hadgaly/features/transactions/data/transactions_repository.dart';

/// Synthetic only. A preserved anchor makes current position differ from flow.
Future<
  ({int card, int income, int food, int cart, int currentIncome, int expense})
>
seedStage5(AppDatabase db, DateTime now) async {
  final accounts = AccountsRepository(
    db,
    clock: () => now.toUtc().microsecondsSinceEpoch,
  );
  final repo = TransactionsRepository(db, clock: () => now);
  await db.loadProfile();
  await db.createFirstAccount('Туршилт', 'Хэтэвч', '1000');
  await db.completeOnboarding();
  final card = await accounts.createAccount('Карт', '-500', 's5-card');
  await accounts.selectDefault(card);
  final categories = await db.select(db.categories).get();
  final income = categories.firstWhere((c) => c.kind == 'income').id;
  final expenseCats = categories.where((c) => c.kind == 'expense').toList();
  final food = expenseCats[0].id, cart = expenseCats[1].id;
  Future<int> post(
    EventKind kind,
    int account,
    int category,
    String amount,
    DateTime date,
    String key,
  ) => repo.post(
    kind: kind,
    amount: amount,
    accountId: account,
    categoryId: category,
    date: date,
    requestKey: key,
  );
  final prior = DateTime(now.year, now.month, 0);
  await post(EventKind.income, 1, income, '100', prior, 's5-old-income');
  await post(EventKind.expense, 1, food, '100', prior, 's5-old-expense');
  final currentIncome = await post(
    EventKind.income,
    1,
    income,
    '200',
    now,
    's5-income',
  );
  final expense = await post(EventKind.expense, 1, food, '50', now, 's5-food');
  await post(EventKind.expense, card, cart, '25', now, 's5-cart');
  await accounts.adjustBalance(1, '900', 's5-anchor');
  await repo.archiveCategory(food);
  return (
    card: card,
    income: income,
    food: food,
    cart: cart,
    currentIncome: currentIncome,
    expense: expense,
  );
}
