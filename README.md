# TFE Org Terraform module

Terraform module to manage Terraform Enterprise organization, project and workspace variables.

## Usage

[Generating user token](https://app.terraform.io/app/settings/tokens)

### Complete

```hcl
module "tfe-variables" {
  source = "../.."

  tfe_token = var.token

  organization = [
    {
      name                     = "tfelab"
      email                    = "<myemail@domain.com>"
      collaborator_auth_policy = "password"
      variable_description     = "tfelab org-level variables"
      variable_global          = false
      variable_priority        = false
      variables = [
        {
          key       = "tfe_org_name"
          value     = "tfelab"
          category  = "terraform"
          sensitive = false
        }
      ]
    }
  ]

  projects = [
    {
      name         = "ecommerce"
      description  = "ecommerce project-level variables"
      organization = "tfelab"
      global       = false
      priority     = false
      inherit = {
        organization = true
      }
      variables = [
        {
          key       = "project"
          value     = "ecommerce"
          category  = "env"
          sensitive = false
        }
      ]
    },
    {
      name         = "webhosting"
      description  = "webhosting project-level variables"
      organization = "tfelab"
      global       = false
      priority     = false
      inherit = {
        organization = true
      }
      variables = [
        {
          key       = "project"
          value     = "webhosting"
          category  = "env"
          sensitive = false
        },
        {
          key       = "project_description"
          value     = "webhosting description"
          category  = "env"
          sensitive = false
        }
      ]
    }
  ]

  workspaces = [
    {
      name         = "ecommerce-dev-aws"
      description  = "ecommerce-dev-aws description"
      organization = "tfelab"
      project      = "ecommerce"
      inherit = {
        organization = true
        project      = true
      }
      variables = [
        {
          key       = "AWS_REGION"
          value     = "us-west-2"
          category  = "env"
          sensitive = false
        }
      ]
      # # ensure that you configure the github auth token before enabling this
      # # needs to be done manually
      # # https://developer.hashicorp.com/terraform/cloud-docs/vcs/github
      # vcs_repo = {
      #   identifier     = "tfelab/test"
      #   oauth_token_id = data.tfe_oauth_client.client.oauth_token_id
      #   branch         = "main"
      # }
    },
    {
      name         = "ecommerce-sit-aws"
      description  = "ecommerce-sit-aws description"
      organization = "tfelab"
      project      = "ecommerce"
      inherit = {
        organization = true
        project      = true
      }
      variables = [
        {
          key       = "AWS_REGION"
          value     = "us-west-1"
          category  = "env"
          sensitive = false
        }
      ]
    }
  ]
}

# data "tfe_oauth_client" "client" {
#   name             = "tfelab-github"
#   organization     = "tfelab"
#   service_provider = "github"
# }
```

## Examples

- [Complete](https://github.com/tfelab/terraform-tfe-org/tree/main/examples/complete)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.12 |
| <a name="requirement_tfe"></a> [tfe](#requirement_tfe) | >= 0.58.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tfe"></a> [tfe](#provider_tfe) | >= 0.58.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [tfe_organization.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/organization) | resource |
| [tfe_project_variable_set.link_project_to_org](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project_variable_set) | resource |
| [tfe_project.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project) | resource |
| [tfe_variable_set.org_variables](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable_set) | resource |
| [tfe_variable_set.project_variables](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable_set) | resource |
| [tfe_variable_set.workspace_variables](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable_set) | resource |
| [tfe_variable.org_variables](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/tfe_variable) | resource |
| [tfe_variable.project_variables](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/tfe_variable) | resource |
| [tfe_variable.workspace_variables](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/tfe_variable) | resource |
| [tfe_workspace_variable_set.link_workspace_to_org](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_workspace_variable_set.link_workspace_to_prj](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) | resource |
| [tfe_workspace.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tfe_token"></a> [tfe_token](#input_tfe_token) | The token use in connecting to TFE | `string` | `null` | yes |
| <a name="input_organization"></a> [organization](#input_organization) | The TFE organization to create and configure | `list` | [] | no |
| <a name="input_projects"></a> [projects](#input_projects) | The TFE projects to create and configure | `list` | [] | no |
| <a name="input_workspaces"></a> [workspaces](#input_workspaces) | The TFE workspaces to create and configure | `list` | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tfe_organization"></a> [tfe_organization](#output_tfe_organization) | The name of the TFE organization |
| <a name="output_tfe_projects"></a> [tfe_project](#output_tfe_projects) | The name of the TFE projects |
| <a name="output_tfe_workspaces"></a> [tfe_workspace](#output_tfe_workspaces) | The name of the TFE workspaces |

## Authors

Module is maintained by [John Ajera](https://github.com/jajera).

## License

MIT Licensed. See [LICENSE](https://github.com/tfelab/terraform-tfe-org/tree/main/LICENSE) for full details.
