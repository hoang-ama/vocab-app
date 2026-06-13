#!/usr/bin/env python3
"""Convert Structure.csv into sentence-structures import JSON."""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from pathlib import Path
from typing import Any


URL_RE = re.compile(r"^https?://", re.I)
AI_PROMPT_RE = re.compile(r"^=ai\(", re.I)
SKIP_EXAMPLE_VALUES = {"ref.", "ref", "loop mail"}


def clean_text(value: str) -> str:
    return " ".join(str(value or "").replace("\r\n", "\n").replace("\r", "\n").split())


def normalize_example(value: str) -> str:
    text = str(value or "").strip()
    if not text:
        return ""
    if URL_RE.match(text):
        return ""
    if AI_PROMPT_RE.match(text):
        return ""
    if clean_text(text).lower() in SKIP_EXAMPLE_VALUES:
        return ""
    return text


def first_line(value: str, max_len: int = 120) -> str:
    for line in str(value).replace("\r\n", "\n").replace("\r", "\n").split("\n"):
        line = line.strip()
        if line:
            if len(line) <= max_len:
                return line
            return line[: max_len - 3].rstrip() + "..."
    return "general template"


def add_keywords(keywords: set[str], raw: str) -> None:
    for part in str(raw or "").split(","):
        part = part.strip()
        if part:
            keywords.add(part)


def get_or_create_purpose(
    purposes: dict[str, dict[str, Any]],
    title: str,
) -> dict[str, Any]:
    key = title.strip()
    if key not in purposes:
        purposes[key] = {
            "title": key,
            "description": "",
            "keywords": set(),
            "structures": [],
            "_structure_index": {},
        }
    return purposes[key]


def get_or_create_structure(
    purpose: dict[str, Any],
    pattern: str,
) -> dict[str, Any]:
    pattern = pattern.strip()
    if not pattern:
        raise ValueError("structure pattern must not be empty")

    index: dict[str, dict[str, Any]] = purpose["_structure_index"]
    if pattern not in index:
        structure = {"pattern": pattern, "notes": "", "examples": []}
        purpose["structures"].append(structure)
        index[pattern] = structure
    return index[pattern]


def add_example(structure: dict[str, Any], example: str) -> None:
    example = normalize_example(example)
    if not example:
        return
    if example not in structure["examples"]:
        structure["examples"].append(example)


def convert_csv(rows: list[list[str]]) -> list[dict[str, Any]]:
    purposes: dict[str, dict[str, Any]] = {}
    current_purpose: dict[str, Any] | None = None
    current_structure: dict[str, Any] | None = None

    for row in rows:
        while len(row) < 6:
            row.append("")

        objective = row[0].strip()
        keyword = row[1].strip()
        structure = row[2].strip()
        example_main = row[3].strip()
        example_extra = row[5].strip() if len(row) > 5 else ""

        if objective:
            current_purpose = get_or_create_purpose(purposes, objective)
            current_structure = None

        if not current_purpose:
            continue

        if keyword:
            add_keywords(current_purpose["keywords"], keyword)

        structure_notes = ""
        if structure and URL_RE.match(structure):
            structure_notes = structure
            structure = ""

        if structure:
            current_structure = get_or_create_structure(current_purpose, structure)
            if structure_notes:
                current_structure["notes"] = structure_notes

        examples = [example_main, example_extra]
        if structure and not any(normalize_example(item) for item in examples):
            continue

        if structure:
            for example in examples:
                add_example(current_structure, example)
            continue

        for example in examples:
            normalized = normalize_example(example)
            if not normalized:
                continue
            pattern = first_line(normalized)
            orphan_structure = get_or_create_structure(current_purpose, pattern)
            if structure_notes and not orphan_structure["notes"]:
                orphan_structure["notes"] = structure_notes
            add_example(orphan_structure, normalized)
            current_structure = orphan_structure

    output: list[dict[str, Any]] = []
    for purpose in purposes.values():
        structures = []
        for structure in purpose["structures"]:
            if not structure["examples"]:
                continue
            structures.append(
                {
                    "pattern": structure["pattern"],
                    "notes": structure["notes"],
                    "examples": structure["examples"],
                }
            )
        if not structures:
            continue
        output.append(
            {
                "title": purpose["title"],
                "description": purpose["description"],
                "keywords": ", ".join(sorted(purpose["keywords"])),
                "structures": structures,
            }
        )

    return output


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv_file", help="Path to Structure.csv")
    parser.add_argument(
        "-o",
        "--output",
        default="sentence-structures.json",
        help="Output JSON path (default: sentence-structures.json)",
    )
    args = parser.parse_args()

    csv_path = Path(args.csv_file)
    if not csv_path.exists():
        print(f"CSV file not found: {csv_path}", file=sys.stderr)
        return 1

    with csv_path.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.reader(handle)
        rows = list(reader)

    if not rows:
        print("CSV file is empty.", file=sys.stderr)
        return 1

    # Drop header row when it looks like a header.
    if rows[0] and "objectives" in rows[0][0].lower():
        rows = rows[1:]

    payload = convert_csv(rows)
    output_path = Path(args.output)
    output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    purpose_count = len(payload)
    structure_count = sum(len(item["structures"]) for item in payload)
    example_count = sum(
        len(structure["examples"])
        for item in payload
        for structure in item["structures"]
    )
    print(f"Wrote {output_path}")
    print(f"purposes={purpose_count}, structures={structure_count}, examples={example_count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
