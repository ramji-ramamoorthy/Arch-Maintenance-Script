# arch-maintenance

A simple Arch Linux maintenance script that updates your system, clears old package cache, and removes orphaned packages — all in one command.

---

## Features

- Full system update via `pacman -Syu`
- Package cache cleanup with `paccache` (keeps last 2 versions)
- Orphan package detection and removal
- Disk usage report before and after
- Colored terminal output
- Confirmation prompts before destructive actions
- `--full`, `--clean`, and `--update` flags

---

## Requirements

- Arch Linux
- `pacman-contrib` (for `paccache`)

```bash
sudo pacman -S pacman-contrib
```

---

## Usage

```bash
chmod +x arch-maintenance.sh
sudo ./arch-maintenance.sh [flag]
```

### Flags

| Flag | Description |
|------|-------------|
| `--full` | Update + clean cache + remove orphans (recommended) |
| `--clean` | Clean cache + remove orphans only |
| `--update` | System update only |
| `--help` | Show help message |

### Examples

```bash
sudo ./arch-maintenance.sh --full
sudo ./arch-maintenance.sh --clean
sudo ./arch-maintenance.sh --update
```

Running with no flag defaults to `--full` after a confirmation prompt.

---

## Output Preview

```
==> Running FULL maintenance...

==> Disk usage:
  Used: 20G / 98G (22% full)

==> Updating system packages...
 ✔  System updated.

==> Clearing package cache (keeping last 2 versions)...
 ✔  Package cache cleaned.

==> Checking for orphan packages...
 ✔  No orphans found.

==> Disk usage after:
  Used: 18G / 98G (19% full)

 ✔  Full maintenance complete.
```

---

## Notes

- Always run with `sudo`
- If you hit package conflicts during update (e.g. `geocode-glib`), resolve them manually with `pacman` before re-running the script
- `paccache` keeps the 2 most recent versions of each package by default

---

## License

MIT
