#!/bin/bash
#
# install-office-addin.sh
#
# Sideloads an Office add-in manifest on macOS by creating the required
# "wef" folder inside the sandboxed container for Word, Excel, and/or
# PowerPoint, then downloading the manifest.xml into it.
#
# Usage:
#   ./install-office-addin.sh              # installs for Word, Excel, and PowerPoint
#   ./install-office-addin.sh word          # installs for Word only
#   ./install-office-addin.sh excel         # installs for Excel only
#   ./install-office-addin.sh powerpoint    # installs for PowerPoint only
#
# Manifest source: https://pivot.claude.ai/manifest.xml

set -euo pipefail

MANIFEST_URL="https://pivot.claude.ai/manifest.xml"
MANIFEST_NAME="manifest.xml"

# Returns the bundle ID for a given app name
get_bundle_id() {
  case "$1" in
    word)        echo "com.microsoft.Word" ;;
    excel)       echo "com.microsoft.Excel" ;;
    powerpoint)  echo "com.microsoft.Powerpoint" ;;
    *)           echo "" ;;
  esac
}

# Determine which app(s) to install for
if [[ $# -eq 0 ]]; then
  APPS=(word excel powerpoint)
else
  APPS=("$(echo "$1" | tr '[:upper:]' '[:lower:]')")
  if [[ -z "$(get_bundle_id "${APPS[0]}")" ]]; then
    echo "Error: unknown app '$1'. Use one of: word, excel, powerpoint" >&2
    exit 1
  fi
fi

echo "Installing add-in manifest for: ${APPS[*]}"
echo

for app in "${APPS[@]}"; do
  bundle_id="$(get_bundle_id "$app")"
  target_dir="$HOME/Library/Containers/${bundle_id}/Data/Documents/wef"
  app_cap="$(echo "${app:0:1}" | tr '[:lower:]' '[:upper:]')${app:1}"

  echo "--- ${app_cap} ---"

  if [[ ! -d "$HOME/Library/Containers/${bundle_id}" ]]; then
    echo "  Warning: ${bundle_id} container not found. Is Microsoft ${app_cap} installed and has it been opened at least once?"
    echo "  Skipping ${app}."
    echo
    continue
  fi

  # Create the wef folder if it doesn't exist
  if [[ ! -d "$target_dir" ]]; then
    echo "  Creating folder: $target_dir"
    mkdir -p "$target_dir"
  else
    echo "  Folder already exists: $target_dir"
  fi

  # Download the manifest into it
  dest_file="$target_dir/$MANIFEST_NAME"
  echo "  Downloading manifest to: $dest_file"
  if curl -fsSL "$MANIFEST_URL" -o "$dest_file"; then
    echo "  Done."
  else
    echo "  Error: failed to download manifest from $MANIFEST_URL" >&2
  fi

  # Reveal the folder in Finder
  open "$target_dir"

  echo
done

echo "All requested installs complete. Restart Word/Excel/PowerPoint (fully quit and reopen) for the add-in to appear under Insert > My Add-ins."
