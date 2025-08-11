output "webhook_endpoint" {
  # value = module.runners.webhook.endpoint
  value = module.multi-runner.webhook.endpoint
}

output "webhook_secret" {
  sensitive = true
  value     = random_id.random.hex
}

output "deprecated_variables_warning" {
  value = join("", [
    module.multi-runner.deprecated_variables_warning,
  ])
}
