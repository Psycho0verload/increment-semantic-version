#!/bin/bash -l
set -euo pipefail

main() {
  prev_version="$1"; release_type="$2"; strict_preversion="${3:-true}"

  if [[ -z "$prev_version" ]]; then
    echo "could not read previous version"; exit 1
  fi

  possible_release_types=(
    major feature minor bug patch hotfix stable
    alpha beta pre rc
    patch-alpha patch-beta patch-pre patch-rc
    minor-alpha minor-beta minor-pre minor-rc
    major-alpha major-beta major-pre major-rc
  )

  if [[ ! " ${possible_release_types[*]} " =~ " ${release_type} " ]]; then
    echo "valid argument: [ ${possible_release_types[*]} ]"; exit 1
  fi

  [[ "$release_type" == "feature" ]] && release_type="minor"
  [[ "$release_type" == "bug" || "$release_type" == "hotfix" ]] && release_type="patch"

  major=0; minor=0; patch=0; pre=""; preversion=""
  version_changed=false

  regex="^v?([0-9]+)\.([0-9]+)\.([0-9]+)(-([a-z]+)(\.([0-9]+))?)?$"
  if [[ $prev_version =~ $regex ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"
    pre="${BASH_REMATCH[5]}"
    preversion="${BASH_REMATCH[7]}"
  else
    echo "previous version '$prev_version' is not a semantic version"
    exit 1
  fi

  case "$release_type" in
    major)
      ((++major)); minor=0; patch=0; pre=""; version_changed=true;;
    minor)
      ((++minor)); patch=0; pre=""; version_changed=true;;
    patch)
      ((++patch)); pre=""; version_changed=true;;
    stable)
      pre=""; preversion="";;

    patch-* | minor-* | major-*)
      IFS='-' read -r bump pre_type <<< "$release_type"
      case "$bump" in
        patch) ((++patch)) ;;
        minor) ((++minor)); patch=0 ;;
        major) ((++major)); minor=0; patch=0 ;;
      esac
      version_changed=true

      if [[ "$version_changed" == "true" || -z "$pre" || "$pre" != "$pre_type" ]]; then
        preversion=0
      else
        ((++preversion))
      fi

      pre="-$pre_type"
      if [[ "$strict_preversion" == "true" || "$preversion" -gt 0 ]]; then
        pre+=".$preversion"
      fi
      ;;

    alpha | beta | pre | rc)
      pre_type="$release_type"

      if [[ "$version_changed" == "true" || -z "$pre" || "$pre" != "$pre_type" ]]; then
        preversion=0
      else
        ((++preversion))
      fi

      pre="-$pre_type"
      if [[ "$strict_preversion" == "true" || "$preversion" -gt 0 ]]; then
        pre+=".$preversion"
      fi
      ;;
  esac

  next_version="${major}.${minor}.${patch}${pre}"
  echo "create $release_type-release version: $prev_version -> $next_version"

  echo "next-version=$next_version" >> "$GITHUB_OUTPUT"
}

main "$1" "$2" "${3:-true}"