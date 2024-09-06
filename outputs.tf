output "tfe_organization" {
  value = tfe_organization.this.name
}

output "tfe_projects" {
  value = [for prj in tfe_project.this : prj.name]
}

output "tfe_workspaces" {
  value = [for ws in tfe_workspace.this : ws.name]
}
