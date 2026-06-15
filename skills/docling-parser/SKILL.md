---
name: docling-parser
description: Convert documents (PDF, DOCX, PPTX, XLSX, HTML, images) into Markdown format locally and deterministically using IBM Docling. Make sure to use this skill whenever the user mentions document parsing, importing files, converting PDFs to MD, sync folders, Obsidian vaults, ingestion, processing PDFs/DOCX/PPTX/HTML without using LLM tokens, or managing a raw/inbox folder for LLM wikis.
---

# Docling Parser

A deterministic, offline tool and workflow for converting document formats (PDF, DOCX, PPTX, XLSX, HTML, and images) to clean, Obsidian-ready Markdown using IBM's Docling.

This skill allows the agent to run local parsing pipelines that avoid high token costs and non-deterministic formatting of LLM-based parsing.

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites & Installation](#prerequisites--installation)
3. [Script Location & Usage](#script-location--usage)
4. [Obsidian & LLM Ingestion Configuration](#obsidian--llm-ingestion-configuration)
5. [Step-by-Step Execution Guide](#step-by-step-execution-guide)
6. [Troubleshooting & Optimizations](#troubleshooting--optimizations)

---

## Overview

Ask-an-LLM methods for parsing layout-heavy documents (like PDFs with tables, columns, or headers) consume excessive input/output tokens and can hallucinate or omit data. 

This skill uses a Python script (`parse_docs.py`) powered by **Docling** to parse files locally. Key benefits:
- **Deterministic**: Document layout, tables, and text are converted via local layout/vision models.
- **Incremental Processing**: Tracks file modification times (`mtime`) and sizes in a state file (`.docling_state.json`) so only new or edited files are processed.
- **Obsidian Optimization**: Automatically sanitizes filenames and generates YAML frontmatter (with parsed date, tags, and source paths).
- **Inbox/Archive Workflow**: Cleans the input folder by moving processed raw files to an archive directory.

---

## Prerequisites & Installation

To run this parser, the local environment must have Python 3.10+ and the `docling` package installed.

### Option A: Install in Active Environment
```bash
pip install docling
```

### Option B: Isolated Virtual Environment (Recommended)
Set up a dedicated virtual environment in the workspace:
```bash
# Create venv
python3 -m venv .venv

# Activate venv
source .venv/bin/activate

# Install docling and dependencies
pip install --upgrade pip
pip install docling
```

> [!NOTE]
> On first run, Docling will automatically download its required AI layout detection and OCR models (such as TableFormer). This requires an internet connection and may take a minute or two. Subsequent runs are fully offline.

---

## Script Location & Usage

The python script is bundled with this skill:
`skills/docling-parser/scripts/parse_docs.py`

### CLI Command Options

You can invoke the script from the workspace root or your Obsidian vault:

```bash
python3 skills/docling-parser/scripts/parse_docs.py [OPTIONS]
```

| Argument | Short | Default | Description |
| :--- | :--- | :--- | :--- |
| `--source` | `-s` | `raw` | Directory containing raw files to parse. |
| `--output` | `-o` | `notes` | Directory where parsed Markdown files will be saved. |
| `--archive` | `-a` | `raw/archive` | Directory to move processed raw files to. Set to `none` to disable. |
| `--state-file` | - | `.docling_state.json` | JSON database tracking already converted files. |
| `--tags` | `-t` | `imported/docling, document` | Comma-separated tags to put in Obsidian YAML frontmatter. |
| `--force` | `-f` | `False` | Force reprocessing of files already tracked in the state file. |
| `--verbose` | `-v` | `False` | Enable detailed processing logs. |

---

## Obsidian & LLM Ingestion Configuration

The parser produces standard markdown with Obsidian-compatible properties. Here is the layout of the generated files:

### 1. Filename Sanitization
Filenames are stripped of special OS characters (`/`, `\`, `:`, etc.) to prevent link breakage.

### 2. YAML Frontmatter Template
Each converted file starts with:
```yaml
---
title: "Clean Document Title"
source_file: "path/to/original/file.pdf"
parsed_at: 2026-06-05T19:00:00.000000
original_size_bytes: 1048576
tags:
  - imported/docling
  - document
  - docling/pdf
---
```
*(The specific source file extension is automatically appended to tags, e.g., `docling/pdf`, `docling/docx`, `docling/pptx`).*

### 3. Structural Elements
- **Tables**: Extracted into clean Markdown table format (`| Header 1 | Header 2 |`).
- **Lists/Headers**: Reconstructed correctly based on document layout hierarchy.
- **Images**: Inline text and equations are extracted.

---

## Step-by-Step Execution Guide

When a user asks to parse files, ingest documents, or set up the parsing workflow:

### Step 1: Detect/Create Input Folders
Ensure the directories exist (default `raw` and `notes`). If they don't, create them:
```bash
mkdir -p raw notes raw/archive
```

### Step 2: Validate Environment
Check if python is available and see if `docling` is installed:
```bash
python3 -c "import docling"
```
If this command fails, instruct the user to install `docling` using the commands in [Prerequisites & Installation](#prerequisites--installation).

### Step 3: Run the Conversion Command
Propose running the script. Customize the directories if the user's Obsidian Vault uses different paths (e.g. `/Users/username/Obsidian/Vault/Inbox`):
```bash
python3 skills/docling-parser/scripts/parse_docs.py \
  --source "raw" \
  --output "notes" \
  --archive "raw/archive" \
  --verbose
```

### Step 4: Verify and Present Results
After the script executes:
1. Show the user a summary of how many files were processed, skipped, or failed.
2. Provide links to the newly generated Markdown files in their vault.
3. Suggest adding `/schedule` if they want to automate this process to run periodically (e.g., hourly or daily).

---

## Troubleshooting & Optimizations

### CPU vs GPU
By default, Docling runs on CPU. If you have a Mac with Apple Silicon (M1/M2/M3), you can accelerate parsing by running python with PyTorch configured for MPS (Metal Performance Shaders), which Docling will automatically leverage if PyTorch is installed with MPS support.

### OCR for Scanned Documents
If a PDF is purely image-based (scanned), Docling uses Tesseract/EasyOCR. Ensure you have system dependencies installed if OCR fails:
- **macOS**: `brew install tesseract`
- **Linux**: `sudo apt-get install tesseract-ocr`

### Memory Issues on Large Files
Very large PDFs (hundreds of pages) can consume significant RAM. If running out of memory, recommend parsing large files individually or chunks using `--force` one-by-one.
