"""QA only: python tool/verify_fonts.py (requires fontTools). Never edits assets."""
import hashlib
import json
from pathlib import Path

from fontTools.ttLib import TTFont

root = Path(__file__).resolve().parents[1] / "assets" / "fonts"
manifest = json.loads((root / "SOURCES.json").read_text(encoding="utf-8"))
for name, entry in manifest["files"].items():
    assert hashlib.sha256((root / name).read_bytes()).hexdigest() == entry["sha256"], name
primary = TTFont(root / "GoogleSansFlex.ttf").getBestCmap()
fallback = TTFont(root / "NotoSans.ttf").getBestCmap()
# All modern Mongolian Cyrillic letters, monetary signs and display numerals.
required = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯӨҮабвгдеёжзийклмнопрстуфхцчшщъыьэюяөү0123456789−+₮"
assert all(ord(ch) in primary or ord(ch) in fallback for ch in required)
assert all(ord(ch) in primary for ch in "0123456789−+")
assert all(ord(ch) in fallback for ch in required)
print("PASS: official asset hashes, Mongolian Cyrillic (including U+04E8/U+04AE), numerals and MNT signs")
print("Google Sans Flex lacks Cyrillic/MNT; bundled Noto Sans supplies missing glyphs only.")
