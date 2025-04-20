# Increment Semantic Version

This is a GitHub action to bump a given semantic version, depending on a given version fragment.

It supports SemVer-compliant versioning with advanced pre-release branching logic.

## Inputs

### `current-version`

**Required** The current semantic version you want to increment (e.g. 3.12.5).
Also accepted: with `v` prefix (e.g. `v2.11.7-alpha.3`)

### `version-fragment`

**Required** The version fragment you want to increment.

---

### 🔹 Supported `version-fragment` options

#### 🔧 Standard fragments
| Fragment   | Description                      |
|------------|----------------------------------|
| `major`    | Increases the major version (x.0.0) and resets minor/patch |
| `minor`    | Increases the minor version (x.y.0) and resets patch |
| `feature`  | Synonym for `minor`              |
| `patch`    | Increases the patch version (x.y.z) |
| `bug`      | Synonym for `patch`              |
| `hotfix`   | Synonym for `patch`              |
| `stable`   | Removes pre-release tag          |

#### 📊 Pre-release fragments
| Fragment   | Description                      |
|------------|----------------------------------|
| `alpha`    | Adds/increments `-alpha` tag     |
| `beta`     | Adds/increments `-beta` tag      |
| `pre`      | Adds/increments `-pre` tag       |
| `rc`       | Adds/increments `-rc` tag        |

#### 🔁 Combined fragments with version increase
| Fragment         | Resulting Behavior                        |
|------------------|--------------------------------------------|
| `patch-alpha`    | Patch + `-alpha`                           |
| `patch-beta`     | Patch + `-beta`                            |
| `patch-pre`      | Patch + `-pre`                             |
| `patch-rc`       | Patch + `-rc`                              |
| `minor-alpha`    | Minor + `-alpha`                           |
| `minor-beta`     | Minor + `-beta`                            |
| `minor-pre`      | Minor + `-pre`                             |
| `minor-rc`       | Minor + `-rc`                              |
| `major-alpha`    | Major + `-alpha`                           |
| `major-beta`     | Major + `-beta`                            |
| `major-pre`      | Major + `-pre`                             |
| `major-rc`       | Major + `-rc`                              |

## Outputs

### `next-version`

The incremented semantic version, based on the logic described above.

---

## Example usage

```yaml
name: Update Version
on:
  workflow_dispatch:

env:
  CURRENT_VERSION_TOP_LEVEL: 'v2.11.7-alpha.3'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Bump release version
        id: bump_version
        uses: psycho0verload/increment-semantic-version@test
        with:
          current-version: ${{ env.CURRENT_VERSION_TOP_LEVEL }}
          version-fragment: 'feature'
      - name: Do something with your bumped release version
        run: echo ${{ steps.bump_version.outputs.next-version }}
```

---

## input / output Examples

| version-fragment | current-version    | output           |
|------------------|--------------------|------------------|
| major            | 2.11.7             | 3.0.0            |
| major-beta       | 2.11.7-alpha.3     | 3.0.0-beta       |
| minor            | 2.11.7             | 2.12.0           |
| minor-rc         | 2.11.7-beta.2      | 2.12.0-rc        |
| patch            | 2.11.7             | 2.11.8           |
| patch-alpha      | 2.11.7             | 2.11.8-alpha     |
| alpha            | 2.11.7             | 2.11.7-alpha     |
| alpha            | 2.11.7-alpha       | 2.11.7-alpha.1   |
| beta             | 2.11.7-alpha.3     | 2.11.7-beta      |
| rc               | 2.11.7-beta.2      | 2.11.7-rc        |
| rc               | 2.11.7-rc          | 2.11.7-rc.1      |
| rc               | 2.11.7-rc.1        | 2.11.7-rc.2      |
| stable           | 2.11.7-beta.4      | 2.11.7           |

---

## Notes

- If switching between pre-release types (e.g. `rc` to `beta`), the suffix resets to `.0`, e.g. `1.2.3-rc.2 → 1.2.3-beta`
- If incrementing to a new base version (e.g. via `minor-pre`), the pre-release suffix starts at `.0` again, e.g. `1.2.3-pre → 1.3.0-pre`

---

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE)