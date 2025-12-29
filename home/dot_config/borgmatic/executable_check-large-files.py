#!/usr/bin/env python3
"""Pre-backup hook to detect large files and abort with notification."""

import argparse
import subprocess
import sys
from pathlib import Path

MAX_SIZE_BYTES = 1 * 1024 * 1024  # 1MB
SOURCE_DIR = Path.home()

VERBOSE = False

EXCLUDE_PATTERNS = [
    "Library",
    "Pictures/Photos Library.photoslibrary",
    "Music/Music Library.musiclibrary",
    "Movies/TV/TV Library.tvlibrary",
    "Movies/TV/Media.localized",
    "Projects.Git",
    "node_modules",
    ".venv",
    "venv",
    ".npm",
    ".cache",
    ".Trash",
    "Downloads",
    "__pycache__",
    "dist",
    "build",
    "target",
    ".next",
    ".nuxt",
    "OrbStack"
]

EXCLUDE_EXTENSIONS = [".pyc", ".iso", ".img", ".dmg"]
EXCLUDE_FILENAMES = [".DS_Store", ".localized"]

# Large files in these directories are expected and won't trigger a prompt
ALLOWED_LARGE_FILE_DIRS = [
    "Projects/Personal.RhythmEngine",
]


def is_in_allowed_dir(path: Path) -> bool:
    """Check if path is within an allowed large file directory."""
    rel_path = path.relative_to(SOURCE_DIR)
    for allowed in ALLOWED_LARGE_FILE_DIRS:
        if str(rel_path).startswith(allowed + "/") or str(rel_path) == allowed:
            return True
    return False


def format_size(size: int) -> str:
    """Format bytes as human-readable size."""
    for unit in ["B", "KB", "MB", "GB"]:
        if size < 1024:
            return f"{size:.1f} {unit}"
        size /= 1024
    return f"{size:.1f} TB"


def should_exclude(path: Path) -> bool:
    """Check if path matches any exclude pattern."""
    path_str = str(path)

    for pattern in EXCLUDE_PATTERNS:
        if f"/{pattern}/" in path_str or path_str.endswith(f"/{pattern}"):
            return True

    if path.suffix in EXCLUDE_EXTENSIONS:
        return True

    if path.name in EXCLUDE_FILENAMES:
        return True

    return False


def should_skip_dir(dirpath: Path, name: str) -> bool:
    """Check if directory should be skipped entirely."""
    if name.startswith("."):
        return True

    # Check if this directory name matches a simple pattern
    if name in EXCLUDE_PATTERNS:
        return True

    # Check if the relative path matches a pattern like "Library/Caches"
    rel_path = (dirpath / name).relative_to(SOURCE_DIR)
    return str(rel_path) in EXCLUDE_PATTERNS


def find_large_files() -> list[Path]:
    """Find files larger than MAX_SIZE_BYTES, respecting exclusions."""
    import os

    large_files = []

    for root, dirs, files in os.walk(SOURCE_DIR):
        root_path = Path(root)
        # Prune excluded directories (modifying dirs in-place prevents descent)
        dirs[:] = [d for d in dirs if not should_skip_dir(root_path, d)]

        for filename in files:
            path = Path(root) / filename

            if should_exclude(path):
                if VERBOSE:
                    print(f"  skip: {path}", file=sys.stderr)
                continue

            try:
                if VERBOSE:
                    print(f"  {path}...", end="", file=sys.stderr, flush=True)
                size = path.stat().st_size
                if VERBOSE:
                    print(f" {format_size(size)}", file=sys.stderr)
                if size > MAX_SIZE_BYTES:
                    large_files.append(path)
            except (PermissionError, OSError):
                continue

    return large_files


def prompt_user(large_files: list[Path]) -> bool:
    """Show macOS dialog with file list. Returns True to allow."""
    # Build list items: "size  filename"
    items = []
    for path in large_files[:20]:  # Limit for dialog readability
        size = format_size(path.stat().st_size)
        rel_path = path.relative_to(SOURCE_DIR)
        items.append(f"{size:>10}  {rel_path}")

    if len(large_files) > 20:
        items.append(f"... and {len(large_files) - 20} more")

    # Escape for AppleScript
    escaped_items = [item.replace('\\', '\\\\').replace('"', '\\"') for item in items]
    items_str = '", "'.join(escaped_items)

    script = f'''
        choose from list {{"{items_str}"}} ¬
            with title "Borgmatic: Large Files Detected" ¬
            with prompt "These {len(large_files)} file(s) > {format_size(MAX_SIZE_BYTES)} will be backed up:" ¬
            OK button name "Allow" ¬
            cancel button name "Prevent" ¬
            multiple selections allowed false ¬
            empty selection allowed true
    '''

    result = subprocess.run(
        ["osascript", "-e", script],
        capture_output=True,
        text=True
    )

    # choose from list returns "false" if cancelled
    return result.returncode == 0 and result.stdout.strip() != "false"


def main() -> int:
    global VERBOSE

    parser = argparse.ArgumentParser(description="Check for large files before backup")
    parser.add_argument("-v", "--verbose", action="store_true", help="Show all files as they're checked")
    args = parser.parse_args()

    VERBOSE = args.verbose

    large_files = find_large_files()

    if not large_files:
        return 0

    # Split into allowed (expected) and unexpected large files
    allowed_files = [f for f in large_files if is_in_allowed_dir(f)]
    unexpected_files = [f for f in large_files if not is_in_allowed_dir(f)]

    # Sort by size descending
    unexpected_files.sort(key=lambda p: p.stat().st_size, reverse=True)

    # Report allowed files (info only)
    if allowed_files:
        print(f"Found {len(allowed_files)} large file(s) in allowed directories (OK).", file=sys.stderr)

    # If no unexpected files, we're good
    if not unexpected_files:
        return 0

    # Build report for unexpected files
    report_lines = [f"Found {len(unexpected_files)} large file(s) in UNEXPECTED locations:", ""]
    for path in unexpected_files[:20]:
        size = format_size(path.stat().st_size)
        report_lines.append(f"  {size:>10}  {path}")

    if len(unexpected_files) > 20:
        report_lines.append(f"  ... and {len(unexpected_files) - 20} more")

    report = "\n".join(report_lines)

    # Print to stderr (goes to borgmatic log)
    print(report, file=sys.stderr)

    # Continue with backup (no prompt)
    return 0


if __name__ == "__main__":
    sys.exit(main())
