# Runbook

Short answers to the questions that come up at 3am.

## A service is returning 5xx

1. `aws ecs describe-services --cluster loyaone-prod --services api` and look at
   `deployments`. Two deployments means a rollout is in progress or stuck.
2. Logs: CloudWatch group `/loyaone/loyaone-prod/api`. Filter on `"level":"error"`.
3. If a bad release: the circuit breaker should already be rolling back. If it is not,
   `make plan ENV=prod` with the previous `image_tag` in `terraform.tfvars` and apply.
4. Shell into a task if you must: `aws ecs execute-command --cluster loyaone-prod
   --task <id> --container api --interactive --command /bin/sh`. Sessions are logged.

## Database is slow

1. RDS Performance Insights for the instance. Top SQL by load is usually the answer.
2. Slow queries over 500 ms are in the `postgresql` log export. Look for `LOCK` lines too.
3. Connections alarm firing: a service is leaking pool connections. Restart it
   (`aws ecs update-service --force-new-deployment`) and file the bug.

## Redis evictions alarm

The working set outgrew the node. Short term: nothing is broken, cache hit rate drops.
Change `redis_node_type` in `locals.tf` and apply in the maintenance window
(`apply_immediately = false` by default).

## Messages in a dead-letter queue

1. `aws sqs receive-message --queue-url <dlq-url> --max-number-of-messages 5` to see
   what failed.
2. Fix the consumer, deploy, then redrive from the console (DLQ -> Start DLQ redrive).
   The redrive allow policy only permits redriving back to the source queue.

## NATS restarted

Consumers reconnect automatically; JetStream state is on EFS and survives. Check
`/loyaone/loyaone-prod/nats` logs for `Restored N messages` on startup. If the task is
crash-looping, EFS mount targets or the access point are the first suspects.

## Rotate the database password

RDS rotates it in Secrets Manager. Services read it at task start, so after a rotation
force a new deployment of each service: `aws ecs update-service --force-new-deployment`.

## Add a service

1. Add its name to `services` in `global/ecr/variables.tf` and apply.
2. Push an image tagged with a version.
3. Add an entry to `services` in the environment's `terraform.tfvars` with a unique
   `priority` and either `host_headers` or `path_patterns`.
4. `make plan ENV=dev`, review, apply. Promote the same tag to staging, then prod.

## Destroy an environment

`make destroy ENV=dev` works. `make destroy ENV=prod` refuses on purpose; prod has
deletion protection on the ALB, RDS and DynamoDB table, and those must be turned off
in `locals.tf` first, deliberately, by a human.
