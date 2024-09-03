variable "tfe_token" {
  description = "The Terraform Cloud API token"
  sensitive   = true
  type        = string
}

variable "organization" {
  description = "Organization variables"
  type = list(object({
    name                                                    = string
    email                                                   = string
    aggregated_commit_status_enabled                        = optional(bool, true)
    allow_force_delete_workspaces                           = optional(bool, false)
    assessments_enforced                                    = optional(bool, false)
    collaborator_auth_policy                                = string
    cost_estimation_enabled                                 = optional(bool, true)
    send_passing_statuses_for_untriggered_speculative_plans = optional(bool, false)
    variable_description                                    = optional(string, "")
    variable_global                                         = optional(bool, true)
    variable_priority                                       = optional(bool, true)
    variables = list(object({
      key       = string
      value     = string
      category  = string
      sensitive = bool
    }))
  }))

  validation {
    condition = alltrue([
      for org in var.organization :
      contains(["password", "two_factor_mandatory"], org.collaborator_auth_policy)
    ])
    error_message = "collaborator_auth_policy must be one of 'password' or 'two_factor_mandatory'."
  }

  default = []
}

variable "projects" {
  description = "List of projects with their variables"
  type = list(object({
    name         = string
    description  = string
    organization = string
    inherit = object({
      organization = bool
    })
    global   = bool
    priority = bool
    variables = list(object({
      key       = string
      value     = string
      category  = string
      sensitive = bool
    }))
  }))
  default = []
}

variable "workspaces" {
  description = "List of workspaces with their variables"
  type = list(object({
    name                           = string
    description                    = string
    organization                   = string
    project                        = string
    allow_destroy_plan             = optional(bool, true)
    assessments_enabled            = optional(bool, false)
    auto_apply                     = optional(bool, false)
    auto_apply_run_trigger         = optional(bool, false)
    auto_destroy_activity_duration = optional(string, null)
    auto_destroy_at                = optional(string, null)
    file_triggers_enabled          = optional(bool, true)
    force_delete                   = optional(bool, false)
    global_remote_state            = optional(bool, false)
    ignore_additional_tag_names    = optional(string, null)

    inherit = object({
      organization = bool
      project      = bool
    })

    variables = list(object({
      key       = string
      value     = string
      category  = string
      sensitive = bool
    }))

    queue_all_runs                = optional(bool, true)
    remote_state_consumer_ids     = optional(list(string), [])
    source_name                   = optional(string, null)
    source_url                    = optional(string, null)
    speculative_enabled           = optional(bool, true)
    ssh_key_id                    = optional(string, "")
    structured_run_output_enabled = optional(bool, true)
    tag_names                     = optional(list(string), [])
    terraform_version             = optional(string, "")
    trigger_patterns              = optional(list(string), null)
    trigger_prefixes              = optional(list(string), null)

    vcs_repo = optional(object({
      identifier                 = string
      branch                     = optional(string, "")
      github_app_installation_id = optional(string, null)
      ingress_submodules         = optional(bool, false)
      oauth_token_id             = optional(string, null)
      tags_regex                 = optional(string, "")
    }), null)

    working_directory = optional(string, "")
  }))
  default = []
}
