import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/app_database.dart';
import '../../../core/domain/money.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => unawaited(db.close()));
  return db;
});

final onboardingProvider = ChangeNotifierProvider<OnboardingController>(
  (ref) => OnboardingController(ref.watch(databaseProvider)),
);

class OnboardingController extends ChangeNotifier {
  OnboardingController(this.db) {
    ready = _load();
  }
  final AppDatabase db;
  late final Future<void> ready;
  Future<void> _pending = Future.value();
  Future<void> get flushDrafts => _pending;
  bool loading = true, busy = false, disposed = false;
  bool loadFailed = false;
  String nickname = '', accountName = '', balance = '';
  String? error;
  int step = 0;
  Account? account;

  void _notify() {
    if (!disposed) notifyListeners();
  }

  Future<void> _load() async {
    try {
      final profile = await db.loadProfile();
      nickname = profile.nickname;
      accountName = profile.accountDraft;
      balance = profile.balanceDraft;
      step = profile.step;
      account = await db.defaultAccount(profile);
      if (step < 0 ||
          step > 4 ||
          (step >= 3 && account == null) ||
          profile.completed != (step == 4)) {
        throw StateError('Invalid saved onboarding state');
      }
    } catch (_) {
      loadFailed = true;
      error = 'Хадгалсан мэдээллийг нээж чадсангүй. Аппаа дахин нээгээрэй.';
    }
    loading = false;
    _notify();
  }

  void draft({String? name, String? account, String? amount}) {
    if (busy || loading || loadFailed || step >= 3) return;
    nickname = name ?? nickname;
    accountName = account ?? accountName;
    balance = amount ?? balance;
    final n = nickname, a = accountName, b = balance, s = step;
    // Ordered writes: an older keystroke cannot overwrite a newer checkpoint.
    _pending = _pending.then((_) => db.saveDraft(n, a, b, s)).catchError((
      Object _,
    ) {
      error = 'Оруулсан мэдээлэл хадгалагдсангүй. Дахин оролдоорой.';
      _notify();
    });
  }

  Future<void> next() async {
    if (busy || loading || loadFailed) return;
    busy = true;
    error = null;
    _notify();
    try {
      await _pending;
      if (step == 0) {
        nickname = validateName(nickname);
        await db.saveDraft(nickname, accountName, balance, 1);
      } else if (step == 1) {
        await db.saveDraft(nickname, accountName, balance, 2);
      } else if (step == 2) {
        await db.createFirstAccount(nickname, accountName, balance);
        account = await db.defaultAccount(await db.loadProfile());
      } else if (step == 3) {
        await db.completeOnboarding();
      } else {
        return;
      }
      step++;
    } on FormatException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Хадгалж чадсангүй. Дахин оролдоорой. Таны данс давхар үүсэхгүй.';
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> back() async {
    if (busy || loading || step <= 0 || step >= 3) return;
    busy = true;
    _notify();
    try {
      await _pending;
      await db.saveDraft(nickname, accountName, balance, step - 1);
      step--;
      error = null;
    } catch (_) {
      error = 'Буцаж чадсангүй. Дахин оролдоорой.';
    } finally {
      busy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
