#!/usr/bin/env python3
"""Import sentence structures JSON into Supabase (idempotent by purpose title)."""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from typing import Any


def request_json(
    method: str,
    url: str,
    api_key: str,
    payload: dict[str, Any] | list[Any] | None = None,
) -> Any:
    data = None
    headers = {
        "apikey": api_key,
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "Prefer": "return=representation",
    }
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode("utf-8")
            return json.loads(body) if body else None
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"{method} {url} failed ({exc.code}): {detail}") from exc


def fetch_existing_purposes(base_url: str, api_key: str) -> dict[str, str]:
    url = f"{base_url.rstrip('/')}/rest/v1/sentence_purposes?select=id,title"
    rows = request_json("GET", url, api_key) or []
    return {str(row["title"]).strip().lower(): row["id"] for row in rows if row.get("title")}


def import_payload(base_url: str, api_key: str, items: list[dict[str, Any]], skip_existing: bool) -> None:
    existing = fetch_existing_purposes(base_url, api_key) if skip_existing else {}
    created_purposes = 0
    created_structures = 0
    created_examples = 0
    skipped_purposes = 0

    for item in items:
        title = str(item.get("title", "")).strip()
        if not title:
            print("Skipping entry without title")
            continue

        title_key = title.lower()
        if skip_existing and title_key in existing:
            print(f"Skip existing purpose: {title}")
            skipped_purposes += 1
            continue

        purpose_payload = {
            "title": title,
            "description": str(item.get("description", "")).strip(),
            "keywords": str(item.get("keywords", "")).strip(),
        }
        purpose_rows = request_json(
            "POST",
            f"{base_url.rstrip('/')}/rest/v1/sentence_purposes",
            api_key,
            purpose_payload,
        )
        purpose_id = purpose_rows[0]["id"]
        existing[title_key] = purpose_id
        created_purposes += 1
        print(f"Created purpose: {title}")

        structures = item.get("structures") or []
        for sort_order, structure in enumerate(structures):
            pattern = str(structure.get("pattern", "")).strip()
            if not pattern:
                continue

            structure_payload = {
                "purpose_id": purpose_id,
                "pattern": pattern,
                "notes": str(structure.get("notes", "")).strip(),
                "sort_order": sort_order,
            }
            structure_rows = request_json(
                "POST",
                f"{base_url.rstrip('/')}/rest/v1/sentence_structures",
                api_key,
                structure_payload,
            )
            structure_id = structure_rows[0]["id"]
            created_structures += 1
            print(f"  + structure: {pattern}")

            for example in structure.get("examples") or []:
                sentence = str(example).strip()
                if not sentence:
                    continue
                request_json(
                    "POST",
                    f"{base_url.rstrip('/')}/rest/v1/sentence_examples",
                    api_key,
                    {
                        "structure_id": structure_id,
                        "sentence": sentence,
                    },
                )
                created_examples += 1
                print(f"    + example: {sentence[:72]}{'...' if len(sentence) > 72 else ''}")

    print(
        f"\nDone. purposes={created_purposes}, structures={created_structures}, "
        f"examples={created_examples}, skipped_purposes={skipped_purposes}"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("json_file", help="Path to sentence structures JSON file")
    parser.add_argument("--supabase-url", default=os.getenv("SUPABASE_URL", ""))
    parser.add_argument("--supabase-key", default=os.getenv("SUPABASE_ANON_KEY", ""))
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        default=True,
        help="Skip purposes whose title already exists (default: true)",
    )
    parser.add_argument(
        "--force-duplicates",
        action="store_true",
        help="Import even when a purpose title already exists",
    )
    args = parser.parse_args()

    if not args.supabase_url or not args.supabase_key:
        print("Set SUPABASE_URL and SUPABASE_ANON_KEY env vars or pass CLI flags.", file=sys.stderr)
        return 1

    with open(args.json_file, "r", encoding="utf-8") as handle:
        payload = json.load(handle)

    if not isinstance(payload, list):
        print("JSON root must be an array of purpose objects.", file=sys.stderr)
        return 1

    import_payload(
        args.supabase_url,
        args.supabase_key,
        payload,
        skip_existing=not args.force_duplicates,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
