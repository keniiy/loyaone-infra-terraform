output "alarm_names" {
  description = "Every alarm created, for dashboards or runbooks."
  value = concat(
    [aws_cloudwatch_metric_alarm.alb_5xx.alarm_name, aws_cloudwatch_metric_alarm.target_5xx.alarm_name],
    [for a in aws_cloudwatch_metric_alarm.unhealthy_targets : a.alarm_name],
    [for a in aws_cloudwatch_metric_alarm.ecs_cpu : a.alarm_name],
    [for a in aws_cloudwatch_metric_alarm.ecs_memory : a.alarm_name],
    [aws_cloudwatch_metric_alarm.rds_cpu.alarm_name, aws_cloudwatch_metric_alarm.rds_storage.alarm_name, aws_cloudwatch_metric_alarm.rds_connections.alarm_name],
    [aws_cloudwatch_metric_alarm.redis_cpu.alarm_name, aws_cloudwatch_metric_alarm.redis_evictions.alarm_name],
    [for a in aws_cloudwatch_metric_alarm.dlq_messages : a.alarm_name],
  )
}
