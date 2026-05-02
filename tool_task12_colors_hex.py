#!/usr/bin/env python3
"""Replace raw Colors.* and common exact hex literals with AppColors in features + shared/widgets."""

from __future__ import annotations

import pathlib
import re


ROOT = pathlib.Path(__file__).resolve().parent

def swap_material_colors(blob: str) -> str:
    """Use word boundary so `AppColors.*` is not touched."""
    for pat, repl in [
        (r"\bColors\.white", "AppColors.white"),
        (r"\bColors\.black", "AppColors.black"),
        (r"\bColors\.transparent", "AppColors.transparent"),
        (r"\bColors\.grey\.shade400", "AppColors.materialGrey400"),
        (r"\bColors\.grey\.shade500", "AppColors.materialGrey500"),
        (r"\bColors\.grey\.shade600", "AppColors.materialGrey600"),
        (r"\bColors\.green\.shade600", "AppColors.materialGreen600"),
    ]:
        blob = re.sub(pat, repl, blob)
    return blob

HEX_SUBS: list[tuple[str, str]] = [
    ("const Color(0xFFE5E7EB)", "AppColors.lightBorder"),
    ("Color(0xFFE5E7EB)", "AppColors.lightBorder"),
    ("const Color(0xFFEEF2FF)", "AppColors.notificationUnreadBackground"),
    ("Color(0xFFEEF2FF)", "AppColors.notificationUnreadBackground"),
    ("const Color(0xFF818CF8)", "AppColors.primaryLight"),
    ("Color(0xFF818CF8)", "AppColors.primaryLight"),
    ("const Color(0xFF4F46E5)", "AppColors.primary"),
    ("Color(0xFF4F46E5)", "AppColors.primary"),
    ("const Color(0xFFFDBA74)", "AppColors.accentLight"),
    ("Color(0xFFFDBA74)", "AppColors.accentLight"),
    ("const Color(0xFFF97316)", "AppColors.accent"),
    ("Color(0xFFF97316)", "AppColors.accent"),
    ("const Color(0xFF6EE7B7)", "AppColors.successLight"),
    ("Color(0xFF6EE7B7)", "AppColors.successLight"),
    ("const Color(0xFF22C55E)", "AppColors.success"),
    ("Color(0xFF22C55E)", "AppColors.success"),
    ("const Color(0xFF3730A3)", "AppColors.primaryDark"),
    ("Color(0xFF3730A3)", "AppColors.primaryDark"),
    ("const Color(0xFF6366F1)", "AppColors.orderStatusProcessing"),
    ("Color(0xFF6366F1)", "AppColors.orderStatusProcessing"),
    ("const Color(0xFF8B5CF6)", "AppColors.orderStatusShipped"),
    ("Color(0xFF8B5CF6)", "AppColors.orderStatusShipped"),
    ("const Color(0xFF1877F2)", "AppColors.facebookBrandBlue"),
    ("Color(0xFF1877F2)", "AppColors.facebookBrandBlue"),
    ("const Color(0xFFDADCE0)", "AppColors.googleOAuthOutlineGrey"),
    ("Color(0xFFDADCE0)", "AppColors.googleOAuthOutlineGrey"),
    ("const Color(0xFFF9FAFB)", "AppColors.neutral50"),
    ("Color(0xFFF9FAFB)", "AppColors.neutral50"),
    ("const Color(0xFFF5F3FF)", "AppColors.indigoTint50"),
    ("Color(0xFFF5F3FF)", "AppColors.indigoTint50"),
]


def ensure_app_colors_import(text: str, file_path: pathlib.Path) -> tuple[str, bool]:
    if "app_colors.dart" in text:
        return text, False
    rel_parts = pathlib.Path(file_path).relative_to(ROOT / "lib").parent.parts
    depth = len(rel_parts)
    imp = ("../" * depth) + "core/constants/app_colors.dart"
    line = f"import '{imp}';\n"
    lines = text.splitlines(keepends=True)
    insert_at = 0
    for i, ln in enumerate(lines):
        if ln.startswith("import 'package:flutter"):
            insert_at = i + 1
            continue
        if not ln.startswith("import "):
            break
        insert_at = i + 1
    lines.insert(insert_at, line)
    return "".join(lines), True


def process_file(p: pathlib.Path) -> bool:
    raw = p.read_text(encoding="utf-8")
    out = raw
    changed = False
    new_c = swap_material_colors(out)
    if new_c != out:
        out = new_c
        changed = True
    for a, b in HEX_SUBS:
        if a in out:
            out = out.replace(a, b)
            changed = True

    if changed and "AppColors." in out:
        out2, _added = ensure_app_colors_import(out, p)
        out = out2

    if out != raw:
        p.write_text(out, encoding="utf-8")
        return True
    return False


def main() -> None:
    n = 0
    for base in (ROOT / "lib/features", ROOT / "lib/shared/widgets"):
        for p in base.rglob("*.dart"):
            if process_file(p):
                n += 1
                print("+", p.relative_to(ROOT))
    print("files changed", n)


if __name__ == "__main__":
    main()
