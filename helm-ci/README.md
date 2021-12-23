# Helm CI Orb

Provides CI functionality for working with Helm.

## Example Usage

### lint-chart

```yaml
orbs:
  helm: ovotech/helm@-ci0.0.1

jobs:
  helm/lint-chart:
    chart_path: <path/to/helm/chart>
    values_files: <values-file.yaml>,<other-values-file.yaml>
```
