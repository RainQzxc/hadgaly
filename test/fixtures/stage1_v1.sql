-- Frozen synthetic schema matching Stage 1 at 42c6df8. No user data.
CREATE TABLE accounts (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 60),
  opening_balance INTEGER NOT NULL CHECK(opening_balance BETWEEN -999999999999 AND 999999999999)
);
CREATE TABLE profiles (
  id INTEGER NOT NULL CHECK(id = 1),
  nickname TEXT NOT NULL DEFAULT '', account_draft TEXT NOT NULL DEFAULT '',
  balance_draft TEXT NOT NULL DEFAULT '', step INTEGER NOT NULL DEFAULT 0,
  completed INTEGER NOT NULL DEFAULT 0 CHECK(completed IN (0,1)),
  default_account_id INTEGER REFERENCES accounts(id), PRIMARY KEY(id)
);
CREATE TRIGGER valid_completed_profile BEFORE UPDATE ON profiles
WHEN (NEW.completed = 1 OR NEW.step >= 3) AND
 (length(trim(NEW.nickname)) = 0 OR NEW.default_account_id IS NULL OR
 NOT EXISTS (SELECT 1 FROM accounts WHERE id = NEW.default_account_id))
BEGIN SELECT RAISE(ABORT, 'Onboarding requires a valid account'); END;
PRAGMA user_version = 1;
