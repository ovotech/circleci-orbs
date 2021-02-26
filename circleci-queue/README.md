# CircleCI Concurrency Control Orb

> :information_source: Copy of [this repo](https://github.com/eddiewebb/circleci-queue) at [this commit](https://github.com/eddiewebb/circleci-queue/tree/9e7fc054183e0bcd891f9258d2661bd9223ffe06)

CircleCI Orb to limit workflow concurrency.

Why? Some jobs (typically deployments) need to run sequentially and not parallel, but also run to completion. So CircleCI's native `auto-cancel` is not quite the right fit.
See https://github.com/ovotech/circleci-challenge as an example using blue/green cloud foundry deployments.

## Basic Usage

This adds concurrency limits by ensuring any jobs with this step will only continue once no previous builds are running. It supports a single argument of how many minutes to wait before aborting itself and it requires a single Environment Variable `CIRCLECI_API_KEY` - which can be created in [account settings](https://circleci.com/account/api).

# Setup

See https://circleci.com/orbs/registry/orb/ovotech/queue#usage-examples for current examples

## Note

Queueing is not supported on forked repos. If a queue from a fork happens the queue will immediately exit and the next step of the job will begin.
