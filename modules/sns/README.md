# sns

Topic with optional email and SQS subscriptions and a publisher IAM policy fragment.

## Usage

```hcl
module "sns" {
  source = "../../modules/sns"
  name = ...
  topic_name = ...
}
```

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `name` | Environment prefix, e.g. loyaone-dev. | `string` | required |
| `topic_name` | Topic purpose, e.g. alarms, loyalty-events. | `string` | required |
| `email_subscribers` | Email addresses to subscribe (each must confirm). | `list(string)` | `[]` |
| `sqs_subscriber_arns` | Map of label to SQS queue ARN to subscribe. | `map(string)` | `{}` |
| `kms_key_arn` | KMS key for encryption. Null uses the SNS default. | `string` | `null` |
| `tags` | Tags applied to every resource. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `topic_arn` | Topic ARN. |
| `publisher_policy_json` | IAM policy JSON allowing publish to this topic. |
