# Helm CI Orb

Provides CI functionality for working with Helm.

## Example Usage

### lint-chart

```yaml
orbs:
  helm-ci: ovotech/helm@-ci0.0.1

workflows:
  commit:
    jobs:
      - helm-ci/lint-chart:
          chart_path: <path/to/helm/chart>
          values_files: <values-file.yaml>,<other-values-file.yaml>
```
