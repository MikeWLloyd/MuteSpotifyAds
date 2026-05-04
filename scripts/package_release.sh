#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEME="${SCHEME:-MuteSpotifyAds}"
CONFIGURATION="${CONFIGURATION:-Release}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-${ROOT_DIR}/build-release}"
OUTPUT_DIR="${OUTPUT_DIR:-${ROOT_DIR}/dist}"

PROJECT_PATH="${ROOT_DIR}/MuteSpotifyAds.xcodeproj"
APP_NAME="MuteSpotifyAds.app"
APP_PRODUCTS_DIR="${DERIVED_DATA_PATH}/Build/Products/${CONFIGURATION}"
APP_PATH="${APP_PRODUCTS_DIR}/${APP_NAME}"
BINARY_ARCHIVE_PATH="${OUTPUT_DIR}/MuteSpotifyAds.app.tar.gz"
SOURCE_ARCHIVE_PATH="${OUTPUT_DIR}/MuteSpotifyAds-source.tar.gz"
CHECKSUMS_PATH="${OUTPUT_DIR}/checksums.txt"

mkdir -p "${OUTPUT_DIR}"

echo "Building ${SCHEME} (${CONFIGURATION})..."
xcodebuild \
  -project "${PROJECT_PATH}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  clean build >/dev/null

if [[ ! -d "${APP_PATH}" ]]; then
  echo "Build succeeded, but app not found at ${APP_PATH}" >&2
  exit 1
fi

echo "Creating binary archive: ${BINARY_ARCHIVE_PATH}"
tar -C "${APP_PRODUCTS_DIR}" -czf "${BINARY_ARCHIVE_PATH}" "${APP_NAME}"

echo "Creating source archive: ${SOURCE_ARCHIVE_PATH}"
git -C "${ROOT_DIR}" archive --format=tar.gz --output "${SOURCE_ARCHIVE_PATH}" HEAD

echo "Generating checksums: ${CHECKSUMS_PATH}"
shasum -a 256 "${BINARY_ARCHIVE_PATH}" "${SOURCE_ARCHIVE_PATH}" > "${CHECKSUMS_PATH}"

cat <<EOF

Release artifacts created in ${OUTPUT_DIR}:
- MuteSpotifyAds.app.tar.gz
- MuteSpotifyAds-source.tar.gz
- checksums.txt

Upload these assets to your GitHub Release.
EOF
