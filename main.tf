###############################
# ORGANIZATION CREATION
###############################

resource "tfe_organization" "this" {
  name                                                    = local.org_detail.name
  email                                                   = local.org_detail.email
  aggregated_commit_status_enabled                        = local.org_detail.aggregated_commit_status_enabled
  allow_force_delete_workspaces                           = local.org_detail.allow_force_delete_workspaces
  assessments_enforced                                    = local.org_detail.assessments_enforced
  collaborator_auth_policy                                = local.org_detail.collaborator_auth_policy
  cost_estimation_enabled                                 = local.org_detail.cost_estimation_enabled
  send_passing_statuses_for_untriggered_speculative_plans = local.org_detail.send_passing_statuses_for_untriggered_speculative_plans
}

###############################
# PROJECT CREATION
###############################

resource "tfe_project" "this" {
  for_each = { for prj in local.projects_detail : prj.name => prj }

  name         = each.value.name
  description  = each.value.description
  organization = each.value.organization

  depends_on = [
    tfe_organization.this
  ]
}

###############################
# WORKSPACE CREATION
###############################

resource "tfe_workspace" "this" {
  for_each = { for ws in local.workspaces_detail : ws.name => ws }

  name                           = each.value.name
  description                    = each.value.description
  organization                   = each.value.organization
  project_id                     = each.value.project_id
  allow_destroy_plan             = each.value.allow_destroy_plan
  assessments_enabled            = each.value.assessments_enabled
  auto_apply                     = each.value.auto_apply
  auto_apply_run_trigger         = each.value.auto_apply_run_trigger
  auto_destroy_activity_duration = each.value.auto_destroy_activity_duration
  auto_destroy_at                = each.value.auto_destroy_at
  file_triggers_enabled          = each.value.file_triggers_enabled
  force_delete                   = each.value.force_delete
  global_remote_state            = each.value.global_remote_state
  ignore_additional_tag_names    = each.value.ignore_additional_tag_names
  queue_all_runs                 = each.value.queue_all_runs
  remote_state_consumer_ids      = each.value.remote_state_consumer_ids
  source_name                    = each.value.source_name
  source_url                     = each.value.source_url
  speculative_enabled            = each.value.speculative_enabled
  ssh_key_id                     = each.value.ssh_key_id
  structured_run_output_enabled  = each.value.structured_run_output_enabled
  tag_names                      = each.value.tag_names
  terraform_version              = each.value.terraform_version
  trigger_patterns               = each.value.trigger_patterns
  trigger_prefixes               = each.value.trigger_prefixes

  dynamic "vcs_repo" {
    for_each = each.value.vcs_repo != null ? [each.value.vcs_repo] : []
    content {
      identifier                 = vcs_repo.value.identifier
      branch                     = vcs_repo.value.branch
      github_app_installation_id = vcs_repo.value.github_app_installation_id
      ingress_submodules         = vcs_repo.value.ingress_submodules
      oauth_token_id             = vcs_repo.value.oauth_token_id
      tags_regex                 = vcs_repo.value.tags_regex
    }
  }

  working_directory = each.value.working_directory

  depends_on = [
    tfe_organization.this,
    tfe_project.this
  ]
}

###############################
# WORKSPACE VARIABLES
###############################

locals {
  workspace_variables = flatten([
    for ws in var.workspaces : [
      for v in ws.variables : {
        name                 = ws.name
        inherit_project      = ws.inherit.project
        inherit_organization = ws.inherit.organization
        organization         = ws.organization
        project              = ws.project
        key                  = v.key
        value                = v.value
        category             = v.category
        sensitive            = v.sensitive
      }
    ]
  ])

  workspaces_detail = flatten([
    for ws in var.workspaces : [
      {
        name                           = ws.name
        description                    = ws.description
        organization                   = ws.organization
        allow_destroy_plan             = ws.allow_destroy_plan
        assessments_enabled            = ws.assessments_enabled
        auto_apply                     = ws.auto_apply
        auto_apply_run_trigger         = ws.auto_apply_run_trigger
        auto_destroy_activity_duration = ws.auto_destroy_activity_duration
        auto_destroy_at                = ws.auto_destroy_at
        file_triggers_enabled          = ws.file_triggers_enabled
        force_delete                   = ws.force_delete
        global_remote_state            = ws.global_remote_state
        ignore_additional_tag_names    = ws.ignore_additional_tag_names
        project_id                     = tfe_project.this[ws.project].id
        queue_all_runs                 = ws.queue_all_runs
        remote_state_consumer_ids      = ws.remote_state_consumer_ids
        source_name                    = ws.source_name
        source_url                     = ws.source_url
        speculative_enabled            = ws.speculative_enabled
        ssh_key_id                     = ws.ssh_key_id
        structured_run_output_enabled  = ws.structured_run_output_enabled
        tag_names                      = ws.tag_names
        terraform_version              = ws.terraform_version
        trigger_patterns               = ws.trigger_patterns
        trigger_prefixes               = ws.trigger_prefixes
        vcs_repo                       = ws.vcs_repo
        working_directory              = ws.working_directory
      }
    ]
  ])
}

resource "tfe_variable" "workspace_variables" {
  for_each = {
    for v in local.workspace_variables : "${v.name}-${v.key}" => v
  }

  key          = each.value.key
  value        = each.value.value
  category     = each.value.category
  sensitive    = each.value.sensitive
  workspace_id = tfe_workspace.this[each.value.name].id
}

###############################
# PROJECT VARIABLES
###############################

locals {
  project_variables = flatten([
    for prj in var.projects : [
      for v in prj.variables : {
        name          = prj.name
        description   = prj.description
        global        = prj.global
        organization  = prj.organization
        priority      = prj.priority
        var_key       = v.key
        var_value     = v.value
        var_category  = v.category
        var_sensitive = v.sensitive
      }
    ]
  ])

  projects_detail = flatten([
    for prj in var.projects : [
      {
        name         = prj.name
        description  = prj.description
        global       = prj.global
        organization = prj.organization
        priority     = prj.priority
      }
    ]
  ])
}

resource "tfe_variable_set" "project_variables" {
  for_each = { for v in local.projects_detail : v.name => v }

  description  = each.value.description
  global       = each.value.global
  name         = each.value.name
  organization = each.value.organization
  priority     = each.value.priority

  depends_on = [
    tfe_project.this
  ]
}

resource "tfe_variable" "project_variables" {
  for_each = { for v in local.project_variables : "${v.name}-${v.var_key}" => v }

  category        = each.value.var_category
  key             = each.value.var_key
  sensitive       = each.value.var_sensitive
  value           = each.value.var_value
  variable_set_id = tfe_variable_set.project_variables[each.value.name].id
}

###############################
# ORGANIZATION VARIABLES
###############################

locals {
  org_variables = flatten([
    for org in var.organization : [
      for v in org.variables : {
        name                 = org.name
        var_key              = v.key
        var_value            = v.value
        var_category         = v.category
        var_sensitive        = v.sensitive
        variable_description = org.variable_description
        variable_global      = org.variable_global
        variable_priority    = org.variable_priority
      }
    ]
  ])

  first_org = length(var.organization) > 0 ? var.organization[0] : null

  org_detail = local.first_org != null ? {
    name                                                    = local.first_org.name
    email                                                   = local.first_org.email
    aggregated_commit_status_enabled                        = local.first_org.aggregated_commit_status_enabled
    allow_force_delete_workspaces                           = local.first_org.allow_force_delete_workspaces
    assessments_enforced                                    = local.first_org.assessments_enforced
    collaborator_auth_policy                                = local.first_org.collaborator_auth_policy
    cost_estimation_enabled                                 = local.first_org.cost_estimation_enabled
    send_passing_statuses_for_untriggered_speculative_plans = local.first_org.send_passing_statuses_for_untriggered_speculative_plans
    variable_description                                    = local.first_org.variable_description
    variable_global                                         = local.first_org.variable_global
    variable_priority                                       = local.first_org.variable_priority
  } : {}
}

resource "tfe_variable_set" "org_variables" {
  count = local.first_org != null ? 1 : 0

  name         = local.org_detail.name
  organization = local.org_detail.name
  description  = local.org_detail.variable_description
  global       = local.org_detail.variable_global
  priority     = local.org_detail.variable_priority

  depends_on = [
    tfe_organization.this
  ]
}

resource "tfe_variable" "org_variables" {
  for_each = { for v in local.org_variables : "${v.name}-${v.var_key}" => v }

  category        = each.value.var_category
  key             = each.value.var_key
  sensitive       = each.value.var_sensitive
  value           = each.value.var_value
  variable_set_id = tfe_variable_set.org_variables[0].id
}

###############################
# WORKSPACES VARIABLE INHERITANCE
###############################

locals {
  workspaces_variable_set_detail = flatten([
    for ws in var.workspaces : [
      {
        name                 = ws.name
        description          = ws.description
        organization         = ws.organization
        project              = ws.project
        workspace_id         = try(tfe_workspace.this[ws.name].id, null)
        variable_set_id      = try(tfe_variable_set.project_variables[ws.project].id, null)
        inherit_organization = ws.inherit.organization
        inherit_project      = ws.inherit.project
      }
    ]
  ])

  # Filter to include only workspaces where inherit_organization is true
  workspaces_inherit_organization_enabled = {
    for id, details in local.workspaces_variable_set_detail : id => details
    if details.inherit_organization
  }

  # Filter to include only workspaces where inherit_project is true
  workspaces_inherit_project_enabled = {
    for id, details in local.workspaces_variable_set_detail : id => details
    if details.inherit_project
  }
}

resource "tfe_workspace_variable_set" "link_workspace_to_org" {
  for_each = local.workspaces_inherit_organization_enabled

  variable_set_id = tfe_variable_set.org_variables[0].id
  workspace_id    = each.value.workspace_id
}

resource "tfe_workspace_variable_set" "link_workspace_to_prj" {
  for_each = local.workspaces_inherit_project_enabled

  variable_set_id = each.value.variable_set_id
  workspace_id    = each.value.workspace_id
}

###############################
# PROJECTS VARIABLE INHERITANCE
###############################

locals {
  projects_variable_set_detail = {
    for prj in flatten([
      for prj in var.projects : [
        {
          project_id           = tfe_project.this[prj.name].id
          name                 = prj.name
          description          = prj.description
          inherit_organization = prj.inherit.organization
          organization         = prj.organization
          global               = prj.global
          priority             = prj.priority
        }
      ]
    ]) : prj.name => prj
  }

  # Filter to include only projects where inherit_organization is true
  projects_inherit_organization_enabled = {
    for id, details in local.projects_variable_set_detail : id => details
    if details.inherit_organization
  }
}

resource "tfe_project_variable_set" "link_project_to_org" {
  for_each = local.projects_inherit_organization_enabled

  variable_set_id = tfe_variable_set.org_variables[0].id
  project_id      = each.value.project_id
}
