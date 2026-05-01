# KEGG Module Parser
A command-line tool for determining whether a KEGG metabolic module is functionally complete in a given organism, based on the KOs (KEGG Orthologs) detected in that species.

## Overview

Given a KofamScan output file and a KEGG module definition file, `module_parser.py` parses the module's boolean logic (AND/OR relationships between KOs), checks which KOs are present in the species, and evaluates whether the module is functional. It also reports which KOs are present and which are missing.

## Requirements

- Python 3.9+
- No external dependencies (uses only the standard library: `csv`, `re`, `argparse`)

## Usage

```bash
python module_parser.py -1 <tsv_file> -2 <module_file>
```

### Arguments

| Flag | Long form | Description | Required |
|------|-----------|-------------|----------|
| `-1` | `--tsv_file` | Path to the KofamScan output TSV file for the species of interest | Yes |
| `-2` | `--module_file` | Path to a text file containing the KEGG module KO definition string | Yes |

### Example

```bash
python module_parser.py -1 ./Plac_ko_annotations.tsv -2 ./hist_biosyn.txt
```

## Input File Formats

### TSV file (`-1`)
A tab-separated KofamScan output file. The script reads KO identifiers from the **3rd column** (0-indexed: column 2) and skips the first two header rows. KOs are expected to match the pattern `K` followed by 5 digits (e.g., `K00801`).

### Module file (`-2`)
A plain text file containing a KEGG module definition string. This string uses standard KEGG module notation:

| Symbol | Meaning |
|--------|---------|
| ` ` (space) | AND — both KOs required |
| `,` | OR — either KO is sufficient |
| `+` | AND — both KOs required (complex formation) |
| `(` `)` | Grouping |
| `-K#####` | Optional KO — excluded from evaluation |

**Example module string:**
```
K00232 K12405 (K07513,K08764)
```
This means: K00232 AND K12405 AND (K07513 OR K08764) are required.

## Output

The script prints a single tab-separated line to stdout:

```
<functionality>    <missing KOs>    <present KOs>
```

| Field | Description |
|-------|-------------|
| `functionality` | `True` if the module is complete, `False` otherwise |
| `missing KOs` | Space-separated list of required KOs not found in the species |
| `present KOs` | Space-separated list of required KOs found in the species |

### Example output
```
True     K07748 K00213    K00801 K00511 K01852
```

## How It Works

1. **Load KOs** — Reads the species' detected KOs from the TSV file into a set.
2. **Load module** — Reads the module definition string from the text file.
3. **Parse module** — Converts the KEGG module notation into a Python boolean expression (spaces → `and`, commas → `or`, `+` → `and`). Optional KOs (prefixed with `-`) are removed.
4. **Extract KOs** — Pulls all KO identifiers from the boolean expression for reporting.
5. **Substitute booleans** — Replaces each KO in the expression with `True` or `False` based on whether it was detected in the species.
6. **Evaluate** — Evaluates the resulting boolean expression to determine module completeness.
7. **Report** — Prints the result along with lists of present and missing KOs.

## Notes

- Double hyphens (`--`) in KEGG module notation (indicating unassigned functions) are not currently handled.


