#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

ENV_FILE="${ENV_FILE:-${REPO_ROOT}/.env.firebase}"
IOS_EXPORT_METHOD="${IOS_EXPORT_METHOD:-ad-hoc}"
SKIP_BUILD="${SKIP_BUILD:-0}"
ARTIFACT_PATH="${ARTIFACT_PATH:-}"

resolve_repo_path() {
  local input_path="$1"
  if [[ -z "${input_path}" ]]; then
    return 0
  fi

  if [[ "${input_path}" = /* ]]; then
    printf '%s\n' "${input_path}"
  else
    printf '%s\n' "${REPO_ROOT}/${input_path}"
  fi
}

assert_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Required command '$1' was not found on PATH." >&2
    exit 1
  fi
}

add_file_option() {
  local option_name="$1"
  local file_value="$2"

  if [[ -z "${file_value}" ]]; then
    return 0
  fi

  local resolved_path
  resolved_path="$(resolve_repo_path "${file_value}")"
  if [[ ! -f "${resolved_path}" ]]; then
    echo "Configured path for ${option_name} does not exist: ${resolved_path}" >&2
    exit 1
  fi

  FIREBASE_ARGS+=("${option_name}" "${resolved_path}")
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "iOS distribution must run on macOS." >&2
  exit 1
fi

if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

assert_command flutter
assert_command firebase

IOS_APP_ID="${FIREBASE_APP_ID_IOS:-${FIREBASE_IOS_APP_ID:-}}"

if [[ -z "${IOS_APP_ID}" ]]; then
  echo "FIREBASE_APP_ID_IOS is required. Set it in the environment or in .env.firebase." >&2
  exit 1
fi

cd "${REPO_ROOT}"

if [[ "${SKIP_BUILD}" != "1" ]]; then
  flutter build ipa --release --export-method="${IOS_EXPORT_METHOD}"
fi

if [[ -z "${ARTIFACT_PATH}" ]]; then
  shopt -s nullglob
  ipa_files=(build/ios/ipa/*.ipa)
  shopt -u nullglob

  if [[ "${#ipa_files[@]}" -eq 0 ]]; then
    echo "No IPA artifact was found under build/ios/ipa." >&2
    exit 1
  fi

  if [[ "${#ipa_files[@]}" -gt 1 ]]; then
    echo "Multiple IPA artifacts were found. Set ARTIFACT_PATH explicitly." >&2
    exit 1
  fi

  ARTIFACT_PATH="${ipa_files[0]}"
fi

ARTIFACT_PATH="$(resolve_repo_path "${ARTIFACT_PATH}")"
if [[ ! -f "${ARTIFACT_PATH}" ]]; then
  echo "Artifact not found: ${ARTIFACT_PATH}" >&2
  exit 1
fi

FIREBASE_ARGS=("appdistribution:distribute" "${ARTIFACT_PATH}" "--app" "${IOS_APP_ID}")

add_file_option "--release-notes-file" "${FIREBASE_RELEASE_NOTES_FILE:-}"
if [[ -n "${FIREBASE_TESTERS:-}" ]]; then
  FIREBASE_ARGS+=("--testers" "${FIREBASE_TESTERS}")
fi
add_file_option "--testers-file" "${FIREBASE_TESTERS_FILE:-}"
if [[ -n "${FIREBASE_TESTER_GROUPS:-}" ]]; then
  FIREBASE_ARGS+=("--groups" "${FIREBASE_TESTER_GROUPS}")
fi
add_file_option "--groups-file" "${FIREBASE_GROUPS_FILE:-}"

if [[ -n "${FIREBASE_TOKEN:-}" ]]; then
  FIREBASE_ARGS+=("--token" "${FIREBASE_TOKEN}")
fi

firebase "${FIREBASE_ARGS[@]}"
