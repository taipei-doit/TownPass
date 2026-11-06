# /// script
# requires-python = ">=3.10"
# dependencies = ["pymupdf>=1.24"]
# ///
"""PDF documents -> Markdown files that scripts/rag-build.mjs reads, plus their pictures.

    uv run --no-project --with pymupdf python scripts/rag-pdf.py <folder of PDFs> <output folder of .md files>

Pictures go to public/rag/img/. Pictures with no description get a placeholder: write a real `alt`
and `caption` in the Markdown afterwards, and add lat, lng, validFrom and validTo where they apply.
A scanned PDF has no text layer, so it needs OCR first; the script says which files that affects.
Build tool only: nothing here runs on the phone. PyMuPDF is AGPL-3.0, the same as this project.
"""

import json
import re
import sys
from pathlib import Path

import pymupdf

MIN_IMAGE_SIDE = 80  # smaller pictures are logos and decorations
IMAGE_DIR = Path(__file__).resolve().parent.parent / "public" / "rag" / "img"


def convert(pdf_path: Path, output_dir: Path) -> None:
    doc_id = re.sub(r"[^\w-]+", "-", pdf_path.stem).strip("-").lower()
    with pymupdf.open(pdf_path) as pdf:
        lines = [line.strip() for page in pdf for line in page.get_text().splitlines() if line.strip()]
        images = extract_images(pdf, doc_id)
    if not lines:
        print(f"  warning: {pdf_path.name} has no text layer, it needs OCR first")
    front_matter = [
        "---",
        f"id: {doc_id}",
        f"title: {lines[0] if lines else pdf_path.stem}",
        f"source: {pdf_path.name}",
        *([f"images: {json.dumps(images, ensure_ascii=False)}"] if images else []),
        "---",
    ]
    (output_dir / f"{doc_id}.md").write_text("\n".join(front_matter + lines) + "\n", encoding="utf-8")
    print(f"  {pdf_path.name}: {len(lines)} lines, {len(images)} pictures")


def extract_images(pdf: pymupdf.Document, doc_id: str) -> list[dict[str, str]]:
    images = []
    seen = set()
    for page in pdf:
        for info in page.get_images(full=True):
            xref = info[0]
            if xref in seen:
                continue
            seen.add(xref)
            picture = pdf.extract_image(xref)
            if min(picture["width"], picture["height"]) < MIN_IMAGE_SIDE:
                continue
            number = len(images) + 1
            name = f"{doc_id}-{number}.{picture['ext']}"
            IMAGE_DIR.mkdir(parents=True, exist_ok=True)
            (IMAGE_DIR / name).write_bytes(picture["image"])
            images.append({"src": f"rag/img/{name}", "alt": f"文件第 {page.number + 1} 頁的附圖 {number}"})
    return images


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("usage: uv run --no-project --with pymupdf python scripts/rag-pdf.py <folder of PDFs> <output folder of .md files>")
    source, output = Path(sys.argv[1]), Path(sys.argv[2])
    output.mkdir(parents=True, exist_ok=True)
    for pdf_path in sorted(source.glob("*.pdf")):
        convert(pdf_path, output)


if __name__ == "__main__":
    main()
