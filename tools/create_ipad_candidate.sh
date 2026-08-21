#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "Usage: $0 <commit> <dossier-de-sortie>" >&2
}

if [[ $# -ne 2 ]]; then
    usage
    exit 64
fi

repository_root="$(git rev-parse --show-toplevel)"
requested_ref="$1"
output_directory="$2"
commit="$(git -C "$repository_root" rev-parse --verify "${requested_ref}^{commit}")"
short_commit="${commit:0:12}"
archive_name="album-photo-${short_commit}.zip"
archive_path="${output_directory%/}/${archive_name}"
archive_prefix="album-photo-${short_commit}/"
information_path="${archive_prefix}Albumzh.swiftpm/Sources/AppModule/ApplicationInformationView.swift"
temporary_directory="$(mktemp -d)"
temporary_archive="${temporary_directory}/${archive_name}"

cleanup() {
    rm -rf -- "$temporary_directory"
}
trap cleanup EXIT

mkdir -p -- "$output_directory"

git -C "$repository_root" archive \
    --format=zip \
    --prefix="$archive_prefix" \
    --output="$temporary_archive" \
    "$commit"

information_source="$(unzip -p "$temporary_archive" "$information_path")"
if [[ "$information_source" != *"archivedGitCommit = \"${commit}\""* ]]; then
    echo "Erreur : le commit ${commit} n’a pas été estampillé dans l’archive." >&2
    exit 1
fi
if [[ "$information_source" == *'$Format:%H$'* ]]; then
    echo "Erreur : le marqueur export-subst brut subsiste dans l’archive." >&2
    exit 1
fi

cp -- "$temporary_archive" "$archive_path"
echo "$archive_path"
echo "Commit estampillé : $commit"
