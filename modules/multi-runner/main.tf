locals {
  tags = merge(var.tags, {
    "ghr:environment" = var.prefix
  })

  github_app_parameters = var.create_ssm_parameters_github_app ? {
    id             = module.ssm[0].parameters.github_app_id
    key_base64     = module.ssm[0].parameters.github_app_key_base64
    webhook_secret = module.ssm[0].parameters.github_app_webhook_secret
    } : {
    id             = var.github_app_ssm_parameters.id
    key_base64     = var.github_app_ssm_parameters.key_base64
    webhook_secret = var.github_app_ssm_parameters.webhook_secret
  }

  runner_extra_labels = { for k, v in var.multi_runner_config : k => sort(setunion(flatten(v.matcherConfig.labelMatchers), compact(v.runner_config.runner_extra_labels))) }

  runner_config = { for k, v in var.multi_runner_config : k => merge({ id = aws_sqs_queue.queued_builds[k].id, arn = aws_sqs_queue.queued_builds[k].arn, url = aws_sqs_queue.queued_builds[k].url }, merge(v, { runner_config = merge(v.runner_config, { runner_extra_labels = local.runner_extra_labels[k] }) })) }

  tmp_distinct_list_unique_os_and_arch = distinct([for i, config in local.runner_config : { "os_type" : config.runner_config.runner_os, "architecture" : config.runner_config.runner_architecture } if config.runner_config.enable_runner_binaries_syncer])
  unique_os_and_arch                   = { for i, v in local.tmp_distinct_list_unique_os_and_arch : "${v.os_type}_${v.architecture}" => v }

  ssm_root_path = "/${var.ssm_paths.root}/${var.prefix}"
}

resource "random_string" "random" {
  length  = 24
  special = false
  upper   = false
}
