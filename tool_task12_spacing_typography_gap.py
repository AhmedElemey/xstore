#!/usr/bin/env python3
"""One-off normalization: Gap(N), SizedBox(height/width: N), EdgeInsets helpers → AppSpacing.

Run from repo root: python3 tool_task12_spacing_typography_gap.py
"""

from __future__ import annotations

import pathlib
import re


ROOT = pathlib.Path(__file__).resolve().parent
LIB_FEATURES = ROOT / "lib" / "features"
LIB_SHARED = ROOT / "lib" / "shared" / "widgets"

NUM_MAP: dict[float, str] = {
    4.0: "AppSpacing.xs",
    6.0: "AppSpacing.spacing6",
    8.0: "AppSpacing.sm",
    10.0: "AppSpacing.spacing10",
    12.0: "AppSpacing.md",
    14.0: "AppSpacing.inputContentPaddingH",
    16.0: "AppSpacing.lg",
    18.0: "AppSpacing.spacing18",
    20.0: "AppSpacing.xl",
    22.0: "AppSpacing.spacing22",
    24.0: "AppSpacing.x2l",
    28.0: "AppSpacing.spacing28",
    32.0: "AppSpacing.x3l",
    48.0: "AppSpacing.x4l",
}


def rel_app_spacing_import(file_path: pathlib.Path) -> str:
    rel_parts = pathlib.Path(file_path).relative_to(ROOT / "lib").parent.parts
    depth = len(rel_parts)
    return ("../" * depth) + "core/constants/app_spacing.dart"


def maybe_add_import(original: str, file_path: pathlib.Path, needs_spacing: bool) -> str:
    if not needs_spacing:
        return original
    if "app_spacing.dart" in original:
        return original
    imp = rel_app_spacing_import(file_path)
    line = f"import '{imp}';\n"
    lines = original.splitlines(keepends=True)
    insert_at = 0
    for i, ln in enumerate(lines):
        insert_at = i + 1
        if not ln.startswith("import "):
            break
        if ln.startswith("import 'package:flutter"):
            insert_at = i + 1
            continue
    lines.insert(insert_at, line)
    return "".join(lines)


def rewrite_numbers_in_call(call_text: str) -> tuple[str | None, bool]:
    """Replace positional numeric args in Gap/SizedBox/EdgeInsets.only etc."""
    span = NUM_MAP.keys()

    # Gap(12), const Gap(12)
    gm = re.match(r"^(const\s+)?Gap\(\s*([\d.]+)\s*\)\s*$", call_text.strip())
    if gm:
        n = float(gm.group(2))
        if n not in NUM_MAP:
            return None, False
        return f'{gm.group(1) or ""}Gap({NUM_MAP[n]})'.replace(
            'const Gap(', 'const Gap('
        ), True

    # SizedBox(width: X) / height
    wm = re.search(
        r"^(const\s+)?SizedBox\(\s*(?:width|height):\s*([\d.]+)\s*\)\s*$",
        call_text.strip(),
        re.I,
    )
    if wm:
        n = float(wm.group(2))
        if n not in NUM_MAP:
            return None, False
        kind = (
            "width:"
            if re.search(r"\bwidth\s*:", call_text)
            else "height:"
        )
        return (
            f"{wm.group(1) or ''}SizedBox({kind} {NUM_MAP[n]})",
            True,
        )

    # EdgeInsets.all(N)
    am = re.match(
        r"^(const\s+)?EdgeInsets\.all\(\s*([\d.]+)\s*\)\s*$", call_text.strip()
    )
    if am:
        n = float(am.group(2))
        if n not in NUM_MAP:
            return None, False
        return f'{am.group(1) or ""}EdgeInsets.all({NUM_MAP[n]})', True

    # EdgeInsets.symmetric horizontal: vertical:
    symm = re.match(
        r"^(const\s+)?EdgeInsets\.symmetric\(([^)]*)\)\s*$",
        call_text.strip(),
    )
    if symm:
        prefix, inner = symm.group(1) or "", symm.group(2)
        changed_inner = inner
        out_changed = False
        for kw in ("horizontal:", "vertical:"):
            m = re.search(rf"{re.escape(kw)}\s*([\d.]+)", changed_inner)
            if m:
                n = float(m.group(1))
                if n in NUM_MAP:
                    changed_inner = re.sub(
                        rf"({re.escape(kw)}\s*){re.escape(m.group(1))}",
                        rf"\g<1>{NUM_MAP[n]}",
                        changed_inner,
                        count=1,
                    )
                    out_changed = True
        if out_changed:
            return f'{prefix}EdgeInsets.symmetric({changed_inner})', True

    # EdgeInsets.fromLTRB
    fm = re.match(
        r"^(const\s+)?EdgeInsets\.fromLTRB\(\s*([^)]*)\s*\)\s*$",
        call_text.strip(),
    )
    if fm:
        prefix, nums = fm.group(1) or "", fm.group(2)
        parts = [p.strip() for p in nums.split(",")]
        if len(parts) == 4:
            try:
                fs = [float(p) for p in parts]
            except ValueError:
                return None, False
            if all(f in NUM_MAP for f in fs):
                reps = ", ".join(NUM_MAP[f] for f in fs)
                return f"{prefix}EdgeInsets.fromLTRB({reps})", True

    # EdgeInsets.only
    om = re.match(
        r"^(const\s+)?EdgeInsets\.only\(\s*([^)]*)\s*\)\s*$", call_text.strip()
    )
    if om:
        prefix, inner = om.group(1) or "", om.group(2)
        new_inner = inner
        kw_changed = False
        for name in ("left", "right", "top", "bottom"):
            m = re.search(rf"{name}:\s*([\d.]+)", new_inner)
            if m:
                n = float(m.group(1))
                if n in NUM_MAP:
                    new_inner = re.sub(
                        rf"({name}:\s*){re.escape(m.group(1))}",
                        rf"\g<1>{NUM_MAP[n]}",
                        new_inner,
                        count=1,
                    )
                    kw_changed = True
        if kw_changed:
            return f"{prefix}EdgeInsets.only({new_inner})", True

    return None, False


GAP_CALL = re.compile(
    r"(const\s+)?Gap\(\s*([\d.]+(?:\.0)?)\s*\)"
)
SZ_CALL = re.compile(
    r"(const\s+)?SizedBox\(\s*(width|height)\s*:\s*([\d.]+)\s*\)"
)
EDGE_ALL = re.compile(
    r"(const\s+)?EdgeInsets\.all\(\s*([\d.]+(?:\.0)?)\s*\)"
)


def rewrite_file_content(text: str, file_path: pathlib.Path) -> str:
    modified = False
    needs_spacing = False

    def repl_gap(m):
        nonlocal modified, needs_spacing
        prefix = m.group(1) or ""
        n = float(m.group(2))
        if n not in NUM_MAP:
            return m.group(0)
        modified = True
        needs_spacing = True
        return f"{prefix}Gap({NUM_MAP[n]})"

    def repl_sz(m):
        nonlocal modified, needs_spacing
        prefix = m.group(1) or ""
        axis = m.group(2)
        n = float(m.group(3))
        if n not in NUM_MAP:
            return m.group(0)
        modified = True
        needs_spacing = True
        return f"{prefix}SizedBox({axis}: {NUM_MAP[n]})"

    def repl_ea(m):
        nonlocal modified, needs_spacing
        prefix = m.group(1) or ""
        n = float(m.group(2))
        if n not in NUM_MAP:
            return m.group(0)
        modified = True
        needs_spacing = True
        return f"{prefix}EdgeInsets.all({NUM_MAP[n]})"

    out = text
    out = GAP_CALL.sub(repl_gap, out)
    out = SZ_CALL.sub(repl_sz, out)
    out = EDGE_ALL.sub(repl_ea, out)

    # EdgeInsets.fromLTRB with four numeric literals only
    def repl_from_ltrb(m):
        nonlocal modified, needs_spacing
        prefix = m.group(1) or ""
        parts = [p.strip() for p in m.group(2).split(",")]
        if len(parts) != 4:
            return m.group(0)
        try:
            fs = [float(p) for p in parts]
        except ValueError:
            return m.group(0)
        if not all(f in NUM_MAP for f in fs):
            return m.group(0)
        modified = True
        needs_spacing = True
        return (
            prefix
            + "EdgeInsets.fromLTRB("
            + ", ".join(NUM_MAP[f] for f in fs)
            + ")"
        )

    out = re.sub(
        r"(const\s+)?EdgeInsets\.fromLTRB\(\s*([\d.]+\s*,\s*[\d.]+\s*,\s*[\d.]+\s*,\s*[\d.]+)\s*\)",
        repl_from_ltrb,
        out,
    )

    def repl_symm(m):
        nonlocal modified, needs_spacing
        prefix = m.group(1) or ""
        inner = m.group(2)
        new_inner = inner
        kw_changed = False
        for kw in ("horizontal:", "vertical:"):
            nm = re.search(rf"{kw}\s*([\d.]+)", new_inner)
            if nm:
                n = float(nm.group(1))
                if n in NUM_MAP:
                    new_inner = re.sub(
                        rf"({re.escape(kw)}\s*){re.escape(nm.group(1))}",
                        rf"\g<1>{NUM_MAP[n]}",
                        new_inner,
                        count=1,
                    )
                    kw_changed = True
        if not kw_changed:
            return m.group(0)
        modified = True
        needs_spacing = True
        return f"{prefix}EdgeInsets.symmetric({new_inner})"

    out = re.sub(
        r"(const\s+)?EdgeInsets\.symmetric\(\s*([^)]+)\)",
        repl_symm,
        out,
    )

    if modified:
        out = maybe_add_import(out, file_path, needs_spacing)
    return out


def main() -> None:
    targets: list[pathlib.Path] = []
    for base in (LIB_FEATURES, LIB_SHARED):
        targets.extend(base.rglob("*.dart"))

    touched = 0
    for p in targets:
        raw = p.read_text(encoding="utf-8")
        new = rewrite_file_content(raw, p)
        if new != raw:
            p.write_text(new, encoding="utf-8")
            touched += 1
            print("+", p.relative_to(ROOT))

    print(f"modified {touched} files")


if __name__ == "__main__":
    main()
