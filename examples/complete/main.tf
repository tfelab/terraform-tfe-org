module "tfe-variables" {
  source = "../.."

  tfe_token = var.token

  organization = [
    {
      name                     = "platformfuzz"
      email                    = "<myemail@domain.com>"
      collaborator_auth_policy = "password"
      variable_description     = "platformfuzz org-level variables"
      variable_global          = false
      variable_priority        = false
      variables = [
        {
          key       = "tfe_org_name"
          value     = "platformfuzz"
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
      organization = "platformfuzz"
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
      organization = "platformfuzz"
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
      organization = "platformfuzz"
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
      #   identifier     = "platformfuzz/rpm-builder"
      #   oauth_token_id = data.tfe_oauth_client.client.oauth_token_id
      #   branch         = "main"
      # }
    },
    {
      name         = "ecommerce-sit-aws"
      description  = "ecommerce-sit-aws description"
      organization = "platformfuzz"
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
#   organization     = "platformfuzz"
#   service_provider = "github"
# }
