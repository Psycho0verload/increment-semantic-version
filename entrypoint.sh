#!/bin/bash -l

# active bash options:
#   - stops the execution of the shell script whenever there are any errors from a command or pipeline (-e)
#   - option to treat unset variables as an error and exit immediately (-u)
#   - print each command before executing it (-x)
#   - sets the exit code of a pipeline to that of the rightmost command
#     to exit with a non-zero status, or to zero if all commands of the
#     pipeline exit successfully (-o pipefail)
set -euo pipefail

main() {

  prev_version="$1"; release_type="$2"

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

  major=0; minor=0; patch=0; pre=""; preversion=""

  # break down the version number into its components
  regex="^v?([0-9]+)\.([0-9]+)\.([0-9]+)(-([a-z]+)(\\.([0-9]+))?)?$"
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

   # increment version number based on given release type
  case "$release_type" in
    major)
      ((++major)); minor=0; patch=0; pre="";;
    feature | minor)
      ((++minor)); patch=0; pre="";;
    bug | patch | hotfix)
      ((++patch)); pre="";;
    stable)
      pre=""; preversion="";;

    patch-* | minor-* | major-*)
      IFS='-' read -r bump pre_type <<< "$release_type"
      case "$bump" in
        patch) ((++patch)) ;;
        minor) ((++minor)); patch=0 ;;
        major) ((++major)); minor=0; patch=0 ;;
      esac

      if [[ -z "$pre" || "$pre" != "$pre_type" ]]; then
        preversion=0
      else
        ((++preversion))
      fi

      if [[ "$preversion" == "0" ]]; then
        pre="-$pre_type"
      else
        pre="-$pre_type.$preversion"
      fi
      ;;

    alpha | beta | pre | rc)
      pre_type="$release_type"

      if [[ -z "$pre" || "$pre" != "$pre_type" ]]; then
        preversion=0
      else
        ((++preversion))
      fi

      if [[ "$preversion" == "0" ]]; then
        pre="-$pre_type"
      else
        pre="-$pre_type.$preversion"
      fi
      ;;
  esac

  next_version="${major}.${minor}.${patch}${pre}"
  echo "create $release_type-release version: $prev_version -> $next_version"

  echo "next-version=$next_version" >> "$GITHUB_OUTPUT"
}

main "$1" "$2"