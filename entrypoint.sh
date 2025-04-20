#!/bin/bash -l
set -euo pipefail

main() {
  local prev_version="$1"
  local release_type="$2"

  if [[ -z "$prev_version" ]]; then
    echo "could not read previous version"; exit 1
  fi

  local possible_release_types=(
    major minor patch stable
    feature bug hotfix
    alpha beta pre rc
    patch-alpha patch-beta patch-pre patch-rc
    minor-alpha minor-beta minor-pre minor-rc
    major-alpha major-beta major-pre major-rc
  )

  [[ " ${possible_release_types[*]} " =~ " ${release_type} " ]] || {
    echo "valid argument: [ ${possible_release_types[*]} ]"; exit 1;
  }

  # Synonyme normalisieren
  case "$release_type" in
    feature) release_type="minor" ;;
    bug|hotfix) release_type="patch" ;;
  esac

  # Versionsbestandteile vorbereiten
  local major=0 minor=0 patch=0 pre="" preversion=""
  local version_changed=false

  local regex="^v?([0-9]+)\.([0-9]+)\.([0-9]+)(?:-([a-z]+)(?:\.([0-9]+))?)?$"
  if [[ "$prev_version" =~ $regex ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"
    pre="${BASH_REMATCH[4]:-}"
    preversion="${BASH_REMATCH[5]:-}"
  else
    echo "previous version '$prev_version' is not a semantic version"
    exit 1
  fi

  # Typ aufsplitten (z. B. patch-alpha → bump=patch, pre_type=alpha)
  local bump_type="${release_type%%-*}"
  local pre_type="${release_type#*-}"

  # Hauptversion anpassen
  case "$bump_type" in
    major) ((++major)); minor=0; patch=0; version_changed=true ;;
    minor) ((++minor)); patch=0; version_changed=true ;;
    patch) ((++patch)); version_changed=true ;;
    stable) pre=""; preversion="" ;;
  esac

  # Pre-Release behandeln, wenn nötig
  if [[ "$release_type" == *"-"* || "$release_type" =~ ^(alpha|beta|pre|rc)$ ]]; then
    if [[ "$version_changed" == true || -z "$pre" || "$pre" != "$pre_type" ]]; then
      preversion=0
    else
      ((preversion++))
    fi
    pre="-$pre_type${preversion:+.$preversion}"
  else
    pre=""
  fi

  local next_version="${major}.${minor}.${patch}${pre}"
  echo "create $release_type-release version: $prev_version -> $next_version"
  echo "next-version=$next_version" >> "$GITHUB_OUTPUT"
}

main "$@"