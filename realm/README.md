# Realm Orb [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/ovotech/realm)](https://circleci.com/orbs/registry/orb/ovotech/realm)

This Orb can be used to post events to [Kaluza's Realm API](https://github.com/ovotech/realm).

It's published as ovotech/realm@0

## Executor

There is no Realm-specific executor provided, the default executor is alpine:3.

> :information_source: <br/> It's likely you'll be using a different executor in
> your deployment jobs. In this case you'll need to ensure you've got Git and Curl
> installed in your container.

## Commands

### realm

Parameters:

- `auto-status` Have the orb automatically determine the deployment event status. Defaults to false
- `environment` The environment the deployment event occurred in. Options: ["dev", "prod", "sandbox", "test", "uat"]. Defaults to prod
- `kaluza-region` The kaluza_region the deployment event occurred in. Options: ["ap1", "eu1", "unknown"]. Defaults to unknown
- `notify-slack-channel` Slack channel to notify (omit the hash prefix). Optional
- `retailer` The retailer the deployment event occurred in. Options: ["oea", "ovo", "unknown"]. Defaults to unknown
- `status` Status of the deployment event. Options: ["failed", "success", "unknown"]. Defaults to unknown
- `team-name` Team slug (should match Ownership data)

### shipit (deprecated)

This command exists purely for back compat reasons (allowing users to
potentially migrate from the Shipit orb to this one with minimal effort, just
change the orb stanza). Where possible the `realm` command should be used
instead of this one.

Parameters:

- `auto-status` Have the orb automatically determine the deployment event status. Defaults to false
- `environment` The environment the deployment event occurred in. Options: ["dev", "nonprod", "prod", "sandbox", "test", "uat"]. Defaults to prod
- `kaluza-region` The kaluza_region the deployment event occurred in. Options: ["ap1", "eu1", "unknown"]. Defaults to unknown
- `notify-slack-channel` Slack channel to notify (omit the hash prefix). Optional
- `retailer` The retailer the deployment event occurred in. Options: ["oea", "ovo", "unknown"]. Defaults to unknown
- `status` Status of the deployment event. Options: ["failed", "success", "unknown"]. Defaults to unknown
- `team-name` Team slug (should match Ownership data)
- `jira-component` JIRA component name to create a release ticket for (Not in use)
- `service-name` A manual override for the name of the service (Not in use)
- `silence-errors` Silence any errors and allow the job to continue (Not in use)

## API Key

An API key is required for this Orb to function. If you're getting started with
the Orb, please contact #kaluza-public-sre and ask for a new API key. You should
set this as a `REALM_API_KEY` in your CircleCI project.

If you're migrating from the Shipit Orb, your `SHIPIT_API_KEY` will continue
to work, but we (kaluza-sre) may be in touch at some point to migrate you over
to a Realm specific key. If you'd like to pre-empt this switch, please get in
touch in [#kaluza-sre-public](https://ovoenergy.slack.com/archives/C039528SAAX).

## Example

Realm makes use of a `status` field on deployment events, so that both
successful and failed events (amongst others) can be registered.

CircleCI doesn't support the handling/triggering of failures on a job-level,
so this has to be done within another job (e.g. the job that deploys, or
runs a smoke test etc.).

Use the `auto-status` parameter when calling the Realm orb to get the orb code
to determine the deployment event status automatically. For example:

```yaml
version: 2.1

orbs:
  realm: ovotech/realm@0

jobs:
  # trigger a Realm event with status=started
  realm_started:
    executor: realm/default
    steps:
      # install required tools (e.g. for alpine/apk)
      - run: apk add --no-cache openssh git curl
      - realm/realm:
          team-name: kaluza-sre
          status: started
  deploy_prod:
    executor: realm/default
    steps:
      # install required tools (e.g. for alpine/apk)
      - run: apk add --no-cache openssh git curl
      - run: |
          echo "doing something fun here"
      # failure/success in this job is handled natively by the Realm orb, so no
      # need to set the Realm event status, just use 'auto-status: true'
      - realm/realm:
          auto-status: true
          team-name: kaluza-sre

workflows:
  deployment:
    jobs:
      - realm_started
      - deploy_prod
```

### Migrating From The Shipit Orb

There is a `shipit` command provided in this Realm Orb, that should allow for
very quick migration (simply change the Orb stanza at the top of your
circleci.yml config to refer to realm instead of shipit).

We strongly recommend using the `realm` command, it should be trivial to fit
into your existing deployment pipelines, and you'll get the new features
of Realm over Shipit, like the deployment status attribute on events.

If you're still keen on using the `shipit` command, please reach out to us at
[#kaluza-sre-public](https://ovoenergy.slack.com/archives/C039528SAAX)
