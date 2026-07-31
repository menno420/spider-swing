#!/usr/bin/env python3
"""Validate zone alpha assets and build the 25% silhouette contact sheet."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
RUNTIME = ROOT / "assets/runtime/zone-art"
SOURCE = ROOT / "assets/source/zone-art"

ASSETS: dict[str, tuple[tuple[int, int], tuple[int, int]]] = {
    "silk-hollow-backdrop": ((1672, 941), (1280, 720)),
    "silk-hollow-cocoon-cluster": ((1254, 1254), (512, 512)),
    "ruined-arboretum-backdrop": ((1672, 941), (1280, 720)),
    "ruined-arboretum-pane": ((1254, 1254), (512, 512)),
    "storm-ridge-backdrop": ((1672, 941), (1280, 720)),
    "storm-ridge-spire": ((1254, 1254), (512, 512)),
    "web-city-backdrop": ((1672, 941), (1280, 720)),
    "web-city-resident": ((1254, 1254), (512, 512)),
    "ashen-hollow-backdrop": ((1672, 941), (1280, 720)),
    "ashen-hollow-rotten-branch": ((1774, 887), (768, 384)),
    "ashen-hollow-sound-branch": ((1774, 887), (768, 384)),
    "deep-mist-backdrop": ((1672, 941), (1280, 720)),
    "deep-mist-lit-beam": ((2172, 724), (768, 256)),
}

BACKDROPS = {
    "ancient_forest": ROOT / "assets/runtime/forest-biome/forest-backdrop-mid.png",
    "bramble_canopy": ROOT / "assets/runtime/bramble-canopy/bramble-backdrop-mid.png",
    "silk_hollow": RUNTIME / "silk-hollow-backdrop.png",
    "ruined_arboretum": RUNTIME / "ruined-arboretum-backdrop.png",
    "storm_ridge": RUNTIME / "storm-ridge-backdrop.png",
    "web_city": RUNTIME / "web-city-backdrop.png",
    "ashen_hollow": RUNTIME / "ashen-hollow-backdrop.png",
    "deep_mist": RUNTIME / "deep-mist-backdrop.png",
}

ZONE_COLORS: dict[str, dict[str, str]] = {
    "ancient_forest": {
        "background": "#102116", "boundary": "#2f2819", "edge": "#f06449"
    },
    "bramble_canopy": {
        "background": "#0c2518", "boundary": "#173421", "edge": "#b7e087"
    },
    "silk_hollow": {
        "background": "#24150f", "boundary": "#3b241d", "edge": "#e8cda7"
    },
    "ruined_arboretum": {
        "background": "#10201e", "boundary": "#243633", "edge": "#87c4ae"
    },
    "storm_ridge": {
        "background": "#101b2a", "boundary": "#202c3a", "edge": "#c5e6f5"
    },
    "web_city": {
        "background": "#080918", "boundary": "#151628", "edge": "#dffaff"
    },
    "ashen_hollow": {
        "background": "#130f11", "boundary": "#1c1819", "edge": "#a89c94"
    },
    "deep_mist": {
        "background": "#a6adae", "boundary": "#6c7476", "edge": "#b9c2c3"
    },
}


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _alpha_stats(image: Image.Image) -> dict[str, int]:
    rgba = image.convert("RGBA")
    transparent = partial = opaque = fringe = edge = 0
    for red, green, blue, alpha in rgba.get_flattened_data():
        if alpha == 0:
            transparent += 1
        elif alpha == 255:
            opaque += 1
        else:
            partial += 1
            edge += 1
            # Lanczos can reconstruct hidden RGB into 1–9/255 alpha texels.
            # Those are below the helper's own visible-noise floor at source
            # scale; only count chroma that can survive gameplay compositing.
            if (
                alpha >= 12
                and red > green + 28
                and blue > green + 28
                and abs(red - blue) <= 32
            ):
                fringe += 1
    return {
        "transparent": transparent,
        "partial": partial,
        "opaque": opaque,
        "edge_pixels": edge,
        "magenta_fringe_pixels": fringe,
    }


def _audit_assets(
    recorded: dict[str, dict[str, Any]] | None = None,
) -> tuple[list[dict[str, Any]], list[str]]:
    recorded = recorded or {}
    rows: list[dict[str, Any]] = []
    failures: list[str] = []
    for name, (source_size, runtime_size) in ASSETS.items():
        source_path = SOURCE / f"{name}-keyed.png"
        runtime_path = RUNTIME / f"{name}.png"
        if not runtime_path.exists():
            failures.append(f"{name}: missing runtime")
            continue
        with Image.open(runtime_path) as runtime_image:
            runtime = runtime_image.convert("RGBA")
        if runtime.size != runtime_size:
            failures.append(f"{name}: runtime {runtime.size}, expected {runtime_size}")
        gameplay = runtime.resize(
            (max(1, runtime.width // 4), max(1, runtime.height // 4)),
            Image.Resampling.LANCZOS,
        )
        previous = recorded.get(name, {})
        if source_path.exists():
            with Image.open(source_path) as source_image:
                source = source_image.convert("RGBA")
            if source.size != source_size:
                failures.append(f"{name}: source {source.size}, expected {source_size}")
            source_stats = _alpha_stats(source)
            source_sha = _sha256(SOURCE / f"{name}-chroma.png")
            keyed_source_sha = _sha256(source_path)
        elif previous:
            source_stats = previous["alpha"]["source"]
            source_sha = previous["source_sha256"]
            keyed_source_sha = previous["keyed_source_sha256"]
        else:
            failures.append(f"{name}: no keyed source and no recorded source audit")
            source_stats = {}
            source_sha = ""
            keyed_source_sha = ""
        states = {
            "source": source_stats,
            "runtime": _alpha_stats(runtime),
            "gameplay_25_percent": _alpha_stats(gameplay),
        }
        for state, stats in states.items():
            if not stats:
                continue
            if stats["transparent"] == 0:
                failures.append(f"{name}/{state}: no transparent pixels")
            if stats["magenta_fringe_pixels"] > 0:
                failures.append(
                    f"{name}/{state}: {stats['magenta_fringe_pixels']} magenta edge pixels"
                )
        rows.append(
            {
                "asset": name,
                "source_size": list(source_size),
                "runtime_size": list(runtime.size),
                "gameplay_audit_size": list(gameplay.size),
                "source_sha256": source_sha,
                "keyed_source_sha256": keyed_source_sha,
                "runtime_sha256": _sha256(runtime_path),
                "alpha": states,
            }
        )
    return rows, failures


def _backdrop_mask(zone_id: str) -> Image.Image:
    path = BACKDROPS[zone_id]
    with Image.open(path) as opened:
        rgba = opened.convert("RGBA").resize((1280, 720), Image.Resampling.LANCZOS)
    alpha = rgba.getchannel("A")
    if zone_id == "bramble_canopy" and alpha.getextrema() == (255, 255):
        # PR #69's current source is chroma-preview white, not this session's
        # asset. Treat near-white as empty only in the comparison proof.
        luminance = rgba.convert("L")
        alpha = luminance.point(lambda value: 0 if value > 244 else 255)
    return alpha.point(lambda value: 255 if value >= 96 else 0)


def _backdrop_rgba(zone_id: str) -> Image.Image:
    path = BACKDROPS[zone_id]
    with Image.open(path) as opened:
        rgba = opened.convert("RGBA").resize((1280, 720), Image.Resampling.LANCZOS)
    if zone_id == "bramble_canopy" and rgba.getchannel("A").getextrema() == (255, 255):
        luminance = rgba.convert("L")
        rgba.putalpha(luminance.point(lambda value: 0 if value > 244 else 255))
    return rgba


def _draw_polygons(mask: Image.Image, zone: dict[str, Any]) -> None:
    draw = ImageDraw.Draw(mask)
    for collection in ("boundaries", "surfaces", "decorations", "obstacles"):
        for polygon in zone[collection]:
            if len(polygon) >= 3:
                draw.polygon([(float(x), float(y)) for x, y in polygon], fill=255)


def _iou(first: Image.Image, second: Image.Image) -> float:
    first_data = list(first.get_flattened_data())
    second_data = list(second.get_flattened_data())
    intersection = sum(a > 0 and b > 0 for a, b in zip(first_data, second_data))
    union = sum(a > 0 or b > 0 for a, b in zip(first_data, second_data))
    return float(intersection) / float(max(1, union))


def _build_silhouettes(
    geometry_path: Path, output_dir: Path
) -> tuple[list[dict[str, Any]], Path]:
    payload = json.loads(geometry_path.read_text(encoding="utf-8"))
    output_dir.mkdir(parents=True, exist_ok=True)
    silhouettes: dict[str, Image.Image] = {}
    for zone in payload["zones"]:
        mask = _backdrop_mask(zone["id"])
        _draw_polygons(mask, zone)
        small_mask = mask.resize((320, 180), Image.Resampling.LANCZOS).point(
            lambda value: 255 if value >= 96 else 0
        )
        silhouette = Image.new("RGB", small_mask.size, "white")
        silhouette.paste("black", mask=small_mask)
        silhouettes[zone["id"]] = small_mask
        silhouette.save(output_dir / f"{zone['id']}-silhouette-25.png")

    pairs: list[dict[str, Any]] = []
    ids = list(silhouettes)
    for first_index, first_id in enumerate(ids):
        for second_id in ids[first_index + 1 :]:
            pairs.append(
                {
                    "first": first_id,
                    "second": second_id,
                    "intersection_over_union": round(
                        _iou(silhouettes[first_id], silhouettes[second_id]), 6
                    ),
                }
            )

    cell_size = (344, 224)
    sheet = Image.new("RGB", (cell_size[0] * 2, cell_size[1] * 4), "#d9dde0")
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for index, zone in enumerate(payload["zones"]):
        column = index % 2
        row = index // 2
        origin = (column * cell_size[0], row * cell_size[1])
        card = Image.new("RGB", (320, 180), "white")
        card.paste("black", mask=silhouettes[zone["id"]])
        sheet.paste(card, (origin[0] + 12, origin[1] + 28))
        draw.text(
            (origin[0] + 12, origin[1] + 8),
            f"{zone['name']} · {int(zone['metres'])} m",
            fill="black",
            font=font,
        )
    contact_path = output_dir / "zone-silhouette-contact-sheet-25.png"
    sheet.save(contact_path)
    return sorted(pairs, key=lambda item: item["intersection_over_union"], reverse=True), contact_path


def _build_screenshots(geometry_path: Path, output_dir: Path) -> Path:
    """Compose full-size world captures from the same exported geometry as the mask."""
    payload = json.loads(geometry_path.read_text(encoding="utf-8"))
    screenshot_dir = output_dir / "screenshots"
    screenshot_dir.mkdir(parents=True, exist_ok=True)
    previews: list[tuple[dict[str, Any], Image.Image]] = []
    for zone in payload["zones"]:
        colors = ZONE_COLORS[zone["id"]]
        preview = Image.new("RGBA", (1280, 720), colors["background"])
        preview.alpha_composite(_backdrop_rgba(zone["id"]))
        draw = ImageDraw.Draw(preview, "RGBA")

        for polygon in zone["boundaries"]:
            points = [(float(x), float(y)) for x, y in polygon]
            if len(points) < 3:
                continue
            draw.polygon(points, fill=colors["boundary"])
            draw.line(points + [points[0]], fill=colors["edge"], width=4, joint="curve")

        for index, polygon in enumerate(zone["surfaces"]):
            points = [(float(x), float(y)) for x, y in polygon]
            if len(points) < 3:
                continue
            anchor_class = zone["surface_anchor_classes"][index]
            fill = "#a86648" if anchor_class == "sticky_silk" else "#d9f7ff"
            draw.polygon(points, fill=fill)
            draw.line(points + [points[0]], fill="#f4ffff", width=3, joint="curve")

        for polygon in zone["decorations"]:
            points = [(float(x), float(y)) for x, y in polygon]
            if len(points) >= 3:
                draw.polygon(points, fill="#a9e8e8cc")

        for index, polygon in enumerate(zone["obstacles"]):
            points = [(float(x), float(y)) for x, y in polygon]
            if len(points) < 3:
                continue
            anchorable = bool(zone["obstacle_anchorable"][index])
            visual_id = zone["obstacle_visual_ids"][index]
            if visual_id in {"ridge_lightning", "ashen_ember"}:
                fill, edge = "#ff9b3d", "#fff2b0"
            else:
                fill = "#25282b" if zone["id"] != "silk_hollow" else "#56352c"
                edge = "#dffaff" if anchorable else "#ff765d"
            draw.polygon(points, fill=fill)
            draw.line(points + [points[0]], fill=edge, width=4, joint="curve")

        for x, y in zone.get("flies", []):
            draw.ellipse((x - 9, y - 9, x + 9, y + 9), fill="#ffd95a", outline="#fff7b0", width=2)

        screenshot_path = screenshot_dir / f"{zone['id']}-screenshot.png"
        preview.convert("RGB").save(screenshot_path)
        previews.append((zone, preview.convert("RGB")))

    cell_size = (520, 326)
    sheet = Image.new("RGB", (cell_size[0] * 2, cell_size[1] * 4), "#d9dde0")
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for index, (zone, preview) in enumerate(previews):
        column, row = index % 2, index // 2
        origin = (column * cell_size[0], row * cell_size[1])
        reduced = preview.resize((480, 270), Image.Resampling.LANCZOS)
        sheet.paste(reduced, (origin[0] + 20, origin[1] + 36))
        draw.text(
            (origin[0] + 20, origin[1] + 12),
            f"{zone['name']} · {int(zone['metres'])} m",
            fill="black",
            font=font,
        )
    contact_path = output_dir / "zone-screenshot-contact-sheet.png"
    sheet.save(contact_path)
    return contact_path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--geometry", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    args = parser.parse_args()

    recorded: dict[str, dict[str, Any]] = {}
    if args.report.exists():
        try:
            previous_report = json.loads(args.report.read_text(encoding="utf-8"))
            recorded = {
                row["asset"]: row for row in previous_report.get("assets", [])
            }
        except (OSError, ValueError, KeyError):
            recorded = {}
    assets, failures = _audit_assets(recorded)
    pairs, contact_path = _build_silhouettes(args.geometry, args.output_dir)
    screenshot_contact_path = _build_screenshots(args.geometry, args.output_dir)
    report = {
        "assets": assets,
        "silhouette_pairs": pairs,
        "highest_pair_iou": pairs[0] if pairs else {},
        "contact_sheet": str(contact_path),
        "screenshot_contact_sheet": str(screenshot_contact_path),
        "failures": failures,
    }
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"[zone-art-audit] wrote {args.report}")
    if failures:
        for failure in failures:
            print(f"[zone-art-audit] FAIL {failure}")
        return 1
    print(f"[zone-art-audit] PASS {len(assets)} assets; max IoU={pairs[0]['intersection_over_union']:.3f}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
