#!/usr/bin/env bash
# Generate the Google Play UPLOAD key and print what to paste into GitHub.
#
# Run this on YOUR machine, not in CI. It writes the keystore to a directory you
# choose OUTSIDE this repository and refuses to run if that would land inside the
# working tree — a committed keystore is the one mistake here that is genuinely
# expensive to undo.
#
# This key signs bundles for UPLOAD only. Google holds the separate app signing
# key that signs what players install, and Google keeps that one safe. Losing
# this upload key is recoverable via Play Console → Protected with Play → Play
# Store protection → Manage Play app signing → request upload key reset.
# See docs/technical/play-closed-test-runbook.md § 2.
set -euo pipefail

OUT_DIR="${1:-$HOME/keys}"
ALIAS="${KEY_ALIAS:-upload}"
KEYSTORE="${OUT_DIR}/spider-swing-upload.jks"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
abs_out="$(mkdir -p "${OUT_DIR}" && cd "${OUT_DIR}" && pwd)"
case "${abs_out}/" in
  "${repo_root}/"*)
    echo "REFUSING: ${abs_out} is inside the repository (${repo_root})." >&2
    echo "Pick a directory outside it, e.g. ~/keys" >&2
    exit 1
    ;;
esac

if ! command -v keytool >/dev/null 2>&1; then
  echo "keytool not found. Install a JDK (Temurin 17 or later) and re-run." >&2
  exit 1
fi

if [ -e "${KEYSTORE}" ]; then
  echo "REFUSING: ${KEYSTORE} already exists." >&2
  echo "Overwriting it would destroy the key Play associates with your uploads." >&2
  exit 1
fi

echo "Creating upload keystore: ${KEYSTORE}"
echo "Choose a strong password. You will need it again as a GitHub secret."
echo

# RSA 2048 is Google's stated minimum for an upload key. 10000 days is the
# long-standing Android convention -- it is NOT a documented Play requirement.
keytool -genkeypair -v \
  -keystore "${KEYSTORE}" \
  -alias "${ALIAS}" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

chmod 600 "${KEYSTORE}"

echo
echo "======================================================================"
echo "Keystore created: ${KEYSTORE}"
echo
echo "BACK THIS FILE UP now, somewhere that is not this repository and not"
echo "only this laptop. A password manager attachment or private cloud folder"
echo "is fine."
echo "======================================================================"
echo
echo "Add these at GitHub -> spider-swing -> Settings -> Secrets and variables"
echo "-> Actions -> Secrets (NOT Variables):"
echo
echo "  RELEASE_KEYSTORE_USER      = ${ALIAS}"
echo "  RELEASE_KEYSTORE_PASSWORD  = the password you just typed"
echo "  RELEASE_KEYSTORE_BASE64    = the block printed below"
echo
echo "---------- RELEASE_KEYSTORE_BASE64 (copy everything between the lines) ----------"
base64 -w0 "${KEYSTORE}" 2>/dev/null || base64 "${KEYSTORE}" | tr -d '\n'
echo
echo "--------------------------------------------------------------------------------"
echo
echo "Then set the two Variables (Settings -> ... -> Variables):"
echo "  RELEASE_PACKAGE_ID  = e.g. com.menno420.swingyspider   (PERMANENT once published)"
echo "  RELEASE_APP_NAME    = store-visible label, 30 characters maximum"
echo
echo "Nothing above was written into the repository. Verify with: git status"
