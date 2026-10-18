#!/usr/bin/env bash
# ==============================================================================
# vget - Standalone Installer Wrapper
# Role: Déclenche l'initialisation et l'intégration globale de vget
# ==============================================================================
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/bin/vget" init
