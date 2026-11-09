import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

typedef BrowserState = ({String active, String? rollback, bool restored});
const firstDatabase = 'hadgaly-finance-v4';

Future<void> holdFinanceLock() async {
  final granted = Completer<bool>();
  final lifetime = Completer<JSAny?>();
  final request = web.window.navigator.locks.request(
    'hadgaly-finance-owner',
    web.LockOptions(ifAvailable: true),
    ((web.Lock? lock) {
      granted.complete(lock != null);
      return lock == null ? Future<JSAny?>.value().toJS : lifetime.future.toJS;
    }).toJS,
  );
  unawaited(
    request.toDart.then<void>(
      (_) {},
      onError: (Object error) {
        if (!granted.isCompleted) granted.completeError(error);
      },
    ),
  );
  if (!await granted.future) throw const AnotherHadgalyTab();
}

class AnotherHadgalyTab implements Exception {
  const AnotherHadgalyTab();
}

class BrowserStateStore {
  BrowserStateStore._(this._db);
  final web.IDBDatabase _db;

  static Future<BrowserStateStore> open() async {
    final request = web.window.indexedDB.open('hadgaly-web-state', 1);
    request.onupgradeneeded = ((web.Event _) {
      (request.result as web.IDBDatabase).createObjectStore('state');
    }).toJS;
    final result = await _result(request);
    return BrowserStateStore._(result as web.IDBDatabase);
  }

  Future<BrowserState?> read() async {
    final tx = _db.transaction('state'.toJS);
    final result = await _result(tx.objectStore('state').get('database'.toJS));
    if (result == null) return null;
    final json =
        jsonDecode((result as JSString).toDart) as Map<String, dynamic>;
    final active = json['active'] as String;
    final rollback = json['rollback'] as String?;
    final allowed = RegExp(r'^hadgaly-finance-v4(-[a-f0-9]{32})?$');
    if (!allowed.hasMatch(active) ||
        (rollback != null &&
            (!allowed.hasMatch(rollback) || rollback == active))) {
      throw const FormatException('Invalid browser database pointer');
    }
    return (
      active: active,
      rollback: rollback,
      restored: json['restored'] as bool,
    );
  }

  Future<void> write(BrowserState state) {
    final tx = _db.transaction('state'.toJS, 'readwrite');
    final committed = Completer<void>();
    tx.oncomplete = ((web.Event _) => committed.complete()).toJS;
    tx.onabort = ((web.Event _) {
      committed.completeError(
        StateError('Could not commit browser database pointer'),
      );
    }).toJS;
    tx
        .objectStore('state')
        .put(
          jsonEncode({
            'active': state.active,
            'rollback': state.rollback,
            'restored': state.restored,
          }).toJS,
          'database'.toJS,
        );
    return committed.future;
  }
}

Future<JSAny?> _result(web.IDBRequest request) {
  final result = Completer<JSAny?>();
  request.onsuccess = ((web.Event _) => result.complete(request.result)).toJS;
  request.onerror = ((web.Event _) {
    result.completeError(StateError('Browser storage request failed'));
  }).toJS;
  return result.future;
}
