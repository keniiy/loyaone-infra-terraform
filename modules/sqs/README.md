# sqs

Queue plus dead-letter queue with redrive, and ready-made consumer and producer IAM policy fragments.

## Usage

```hcl
module "sqs" {
  source = "../../modules/sqs"
  name = ...
  queue_name = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Environment prefix, e.g. loyaone-dev. | `string` | required |
| `queue_name` | Queue purpose, e.g. points-accrual, webhook-retry. | `string` | required |
| `fifo` | Create a FIFO queue (ordering + exactly-once within a group). | `bool` | `false` |
| `content_based_deduplication` | For FIFO queues, dedupe on message body hash. | `bool` | `true` |
| `visibility_timeout_seconds` | How long a message is hidden after receipt. Set above the consumer's processing time. | `number` | `60` |
| `retention_seconds` | Message retention (max 14 days). | `number` | `345600` |
| `dlq_retention_seconds` | DLQ retention (default 14 days). | `number` | `1209600` |
| `receive_wait_time_seconds` | Long polling wait time. | `number` | `20` |
| `max_receive_count` | Receives before a message moves to the DLQ. | `number` | `5` |
| `kms_key_arn` | KMS key for encryption. Null uses SQS-managed keys. | `string` | `null` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `queue_url` | Queue URL. |
| `queue_arn` | Queue ARN. |
| `queue_name` | Queue name, used by CloudWatch alarms. |
| `dlq_arn` | Dead-letter queue ARN. |
| `dlq_name` | Dead-letter queue name, used by CloudWatch alarms. |
| `consumer_policy_json` | IAM policy JSON for a consumer. Attach to the consuming service's task role. |
| `producer_policy_json` | IAM policy JSON for a producer. |
