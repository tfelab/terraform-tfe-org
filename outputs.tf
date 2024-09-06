output "tfe_organization" {
  value = tfe_organization.this.name
  description = "The name of the TFE organization"
}

output "tfe_projects" {
  value = [for prj in tfe_project.this : prj.name]
  description = "The names of the TFE projects"
}

output "tfe_workspaces" {
  value = [for ws in tfe_workspace.this : ws.name]
  description = "The names of the TFE workspaces"
}
