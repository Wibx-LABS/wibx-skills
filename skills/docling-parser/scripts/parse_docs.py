#!/usr/bin/env python3
"""
parse_docs.py

A deterministic, offline document parser that converts non-markdown documents
(PDF, DOCX, PPTX, HTML, XLSX, PNG, JPG) to clean Markdown using IBM's Docling.
Designed for Obsidian vaults and LLM wiki ingestion.
"""

import os
import sys
import json
import argparse
import shutil
import re
from datetime import datetime
from pathlib import Path

# Check docling availability and fail gracefully if not installed
try:
    from docling.document_converter import DocumentConverter
except ImportError:
    print("\n" + "="*80)
    print("ERROR: The 'docling' library is not installed in your Python environment.")
    print("="*80)
    print("Docling is required to run this script. You can install it using pip:")
    print("    pip install docling")
    print("\nAlternatively, set up a virtual environment:")
    print("    python3 -m venv .venv")
    print("    source .venv/bin/activate")
    print("    pip install docling")
    print("="*80 + "\n")
    sys.exit(1)


def sanitize_filename(name: str) -> str:
    """Sanitizes file names to be safe for Obsidian and all OS file systems."""
    # Remove characters that are illegal in file names: \ / : * ? " < > |
    sanitized = re.sub(r'[\\/*?:"<>|]', "", name)
    # Strip leading/trailing whitespaces and dots
    sanitized = sanitized.strip().strip('.')
    # Replace multiple spaces with a single space
    sanitized = re.sub(r'\s+', ' ', sanitized)
    return sanitized if sanitized else "unnamed_document"


def load_state(state_file_path: Path) -> dict:
    """Loads the state registry file tracking already processed documents."""
    if state_file_path.exists():
        try:
            with open(state_file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"Warning: Failed to load state file ({e}). Starting fresh.")
    return {"processed_files": {}}


def save_state(state: dict, state_file_path: Path):
    """Saves the state registry file."""
    try:
        with open(state_file_path, 'w', encoding='utf-8') as f:
            json.dump(state, f, indent=2, ensure_ascii=False)
    except Exception as e:
        print(f"Warning: Failed to save state file ({e}).")


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Deterministic document to Markdown parser using IBM Docling."
    )
    parser.add_argument(
        "--source", "-s",
        type=str,
        default="raw",
        help="Directory containing raw files to parse (default: 'raw')"
    )
    parser.add_argument(
        "--output", "-o",
        type=str,
        default="notes",
        help="Directory where parsed Markdown files will be saved (default: 'notes')"
    )
    parser.add_argument(
        "--archive", "-a",
        type=str,
        default="raw/archive",
        help="Directory to move processed raw files to. Set to 'none' to disable moving (default: 'raw/archive')"
    )
    parser.add_argument(
        "--state-file",
        type=str,
        default=".docling_state.json",
        help="JSON file tracking processed document hashes/paths (default: '.docling_state.json')"
    )
    parser.add_argument(
        "--tags", "-t",
        type=str,
        default="imported/docling, document",
        help="Comma-separated tags to add to YAML frontmatter (default: 'imported/docling, document')"
    )
    parser.add_argument(
        "--force", "-f",
        action="store_true",
        help="Reprocess files even if they are marked as processed in the state file"
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose output"
    )
    return parser.parse_args()


def main():
    args = parse_arguments()

    source_dir = Path(args.source).resolve()
    output_dir = Path(args.output).resolve()
    state_file = Path(args.state_file).resolve()
    
    archive_dir = None
    if args.archive.lower() != 'none':
        archive_dir = Path(args.archive).resolve()

    # Ensure source directory exists
    if not source_dir.exists():
        print(f"Error: Source directory '{source_dir}' does not exist.")
        sys.exit(1)

    # Ensure output and archive directories exist
    output_dir.mkdir(parents=True, exist_ok=True)
    if archive_dir:
        archive_dir.mkdir(parents=True, exist_ok=True)

    # Load state tracking
    state = load_state(state_file)
    processed_dict = state.setdefault("processed_files", {})

    # Define supported extensions for Docling
    # PDF, Word, PowerPoint, Excel, HTML, Images
    supported_extensions = {
        '.pdf', '.docx', '.pptx', '.xlsx', '.html', '.htm',
        '.png', '.jpg', '.jpeg', '.tiff', '.bmp'
    }

    # Find candidate files
    files_to_process = []
    for root, _, files in os.walk(source_dir):
        root_path = Path(root)
        # Avoid walking into archive directory if it is a subdirectory of source
        if archive_dir and archive_dir in root_path.parents or root_path == archive_dir:
            continue
            
        for file in files:
            file_path = root_path / file
            if file_path.suffix.lower() in supported_extensions:
                files_to_process.append(file_path)

    if not files_to_process:
        print(f"No documents to process in source directory '{source_dir}'.")
        return

    print(f"Found {len(files_to_process)} document(s) in source directory.")
    print("Initializing Docling DocumentConverter (this may take a few seconds on first run)...")
    
    try:
        converter = DocumentConverter()
    except Exception as e:
        print(f"Critical Error: Failed to initialize Docling converter. Details: {e}")
        sys.exit(1)

    success_count = 0
    fail_count = 0
    skip_count = 0

    # Split tags
    tags_list = [tag.strip() for tag in args.tags.split(',') if tag.strip()]

    for file_path in files_to_process:
        rel_path = str(file_path.relative_to(source_dir))
        
        # Check if modified since last process
        mtime = file_path.stat().st_mtime
        file_size = file_path.stat().st_size
        
        is_processed = rel_path in processed_dict
        up_to_date = is_processed and processed_dict[rel_path].get("mtime") == mtime

        if up_to_date and not args.force:
            if args.verbose:
                print(f"Skipping (already processed): {rel_path}")
            skip_count += 1
            # If the user enabled archiving but files are still in the raw folder (e.g. from previous manual runs)
            # we should archive them now
            if archive_dir:
                try:
                    dest_path = archive_dir / file_path.relative_to(source_dir)
                    dest_path.parent.mkdir(parents=True, exist_ok=True)
                    shutil.move(str(file_path), str(dest_path))
                    if args.verbose:
                        print(f"  Moved skipped file to archive: {dest_path.name}")
                except Exception as e:
                    print(f"  Warning: Failed to move skipped file to archive: {e}")
            continue

        print(f"Parsing: {rel_path} ({file_size / 1024:.1f} KB)...")
        
        try:
            start_time = datetime.now()
            # Convert file
            result = converter.convert(file_path)
            
            # Export to Markdown
            markdown_text = result.document.export_to_markdown()
            
            # Create YAML Frontmatter
            doc_title = file_path.stem
            clean_title = sanitize_filename(doc_title)
            
            # Build frontmatter fields
            frontmatter_tags = tags_list + [f"docling/{file_path.suffix[1:].lower()}"]
            frontmatter_tags_str = "\n".join(f"  - {tag}" for tag in frontmatter_tags)
            
            frontmatter = f"""---
title: "{clean_title}"
source_file: "{rel_path}"
parsed_at: {datetime.now().isoformat()}
original_size_bytes: {file_size}
tags:
{frontmatter_tags_str}
---

"""
            full_markdown = frontmatter + markdown_text
            
            # Write markdown file
            out_filename = f"{clean_title}.md"
            out_file_path = output_dir / out_filename
            
            # If output file already exists, let's append a suffix or overwrite
            # For Obsidian, we usually want to write clean notes
            with open(out_file_path, "w", encoding="utf-8") as f:
                f.write(full_markdown)

            duration = (datetime.now() - start_time).total_seconds()
            print(f"  ✓ Saved to: {out_file_path.name} (took {duration:.2f}s)")
            
            # Update state registry
            processed_dict[rel_path] = {
                "mtime": mtime,
                "size": file_size,
                "parsed_at": datetime.now().isoformat(),
                "markdown_file": str(out_file_path.relative_to(output_dir))
            }
            save_state(state, state_file)
            
            # Move raw file to archive if configured
            if archive_dir:
                try:
                    dest_path = archive_dir / file_path.relative_to(source_dir)
                    dest_path.parent.mkdir(parents=True, exist_ok=True)
                    shutil.move(str(file_path), str(dest_path))
                    print(f"  ✓ Moved original to archive: {dest_path.name}")
                except Exception as e:
                    print(f"  ✗ Warning: Failed to move raw file to archive: {e}")

            success_count += 1

        except Exception as e:
            print(f"  ✗ Failed to parse '{rel_path}': {e}")
            fail_count += 1

    print("\n" + "="*40)
    print("Parsing Summary:")
    print(f"  Processed successfully: {success_count}")
    print(f"  Failed:                 {fail_count}")
    print(f"  Skipped (up-to-date):  {skip_count}")
    print("="*40 + "\n")


if __name__ == "__main__":
    main()
