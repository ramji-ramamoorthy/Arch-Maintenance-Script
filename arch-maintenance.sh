#!/bin/bash
# ─────────────────────────────────────────────
#  arch-maintenance — Arch Linux system cleanup
# ─────────────────────────────────────────────

set -euo pipefail

# ── Colors ──────────────────────────────────
BOLD=$(tput bold)
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)

# ── Helpers ──────────────────────────────────
info()    { echo "${CYAN}${BOLD}==> ${RESET}${BOLD}$*${RESET}"; }
success() { echo "${GREEN}${BOLD} ✔  $*${RESET}"; }
warn()    { echo "${YELLOW}${BOLD} !  $*${RESET}"; }
error()   { echo "${RED}${BOLD} ✘  $*${RESET}" >&2; }

confirm() {
    local prompt="${1:-Are you sure?}"
    read -r -p "${BOLD}${prompt} [y/N] ${RESET}" response
    [[ "${response,,}" == "y" ]]
}

require_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (use sudo)."
        exit 1
    fi
}

disk_usage() {
    df -h / | awk 'NR==2 {print "Used: "$3" / "$2" ("$5" full)"}'
}

# ── Tasks ────────────────────────────────────
task_update() {
    info "Updating system packages..."
    pacman -Syu --noconfirm
    success "System updated."
}

task_clean_cache() {
    info "Clearing package cache (keeping last 2 versions)..."
    if ! command -v paccache &>/dev/null; then
        warn "paccache not found. Install pacman-contrib: pacman -S pacman-contrib"
        return
    fi
    paccache -r
    success "Package cache cleaned."
}

task_remove_orphans() {
    info "Checking for orphan packages..."
    orphans=$(pacman -Qdtq 2>/dev/null || true)
    if [[ -z "$orphans" ]]; then
        success "No orphans found."
        return
    fi

    echo ""
    warn "Orphan packages found:"
    echo "$orphans"
    echo ""

    if confirm "Remove all orphan packages?"; then
        pacman -Rns $orphans --noconfirm
        success "Orphans removed."
    else
        warn "Skipped orphan removal."
    fi
}

task_disk_usage() {
    info "Disk usage:"
    echo "  $(disk_usage)"
}

# ── Modes ────────────────────────────────────
mode_full() {
    require_root
    echo ""
    info "Running FULL maintenance..."
    echo ""

    task_disk_usage
    echo ""
    task_update
    echo ""
    task_clean_cache
    echo ""
    task_remove_orphans
    echo ""
    info "Disk usage after:"
    echo "  $(disk_usage)"
    echo ""
    success "Full maintenance complete."
}

mode_clean() {
    require_root
    echo ""
    info "Running CLEANUP only..."
    echo ""

    task_disk_usage
    echo ""
    task_clean_cache
    echo ""
    task_remove_orphans
    echo ""
    info "Disk usage after:"
    echo "  $(disk_usage)"
    echo ""
    success "Cleanup complete."
}

mode_update() {
    require_root
    echo ""
    task_update
    echo ""
    success "Done."
}

# ── Usage ─────────────────────────────────────
usage() {
    echo ""
    echo "${BOLD}arch-maintenance${RESET} — Arch Linux system maintenance script"
    echo ""
    echo "${BOLD}Usage:${RESET}"
    echo "  sudo $0 [flag]"
    echo ""
    echo "${BOLD}Flags:${RESET}"
    echo "  --full      Update + clean cache + remove orphans (recommended)"
    echo "  --clean     Clean cache + remove orphans only"
    echo "  --update    System update only"
    echo "  --help      Show this help message"
    echo ""
    echo "${BOLD}Examples:${RESET}"
    echo "  sudo $0 --full"
    echo "  sudo $0 --clean"
    echo ""
}

# ── Entry point ───────────────────────────────
case "${1:-}" in
    --full)   mode_full ;;
    --clean)  mode_clean ;;
    --update) mode_update ;;
    --help|-h) usage ;;
    *)
        warn "No flag provided. Defaulting to --full."
        if confirm "Run full maintenance?"; then
            mode_full
        else
            usage
        fi
        ;;
esac
