
variable "tags" {
  description = "Tags to be applied to resources (inclusive)"
  type = object({
   
  })
}

variable "extra_tags" {
  description = "extra tags to be applied to resources (in addition to the tags above)"
  type        = map(string)
  default     = {}
}
###############################################################################
#                                  Codebuild                                  #
###############################################################################


variable "codebuild_repo_policy_name" {
  type    = string
  default = "aws-codebuild-repo-policy"
}

variable "codebuild_codepipeline_artifact_store" {
  type    = string
  default = ""
}

variable "codebuild_repo_artifacts_location" {
  type = string

}

variable "codebuild_repo_role_name" {
  type    = string
  default = "aws-codebuild-repo-role"
}

variable "codebuild_repo_project_name" {
  type = string

}

variable "codebuild_repo_project_description" {
  type = string
}

variable "codebuild_repo_source_version" {
  type = string

}

variable "buildspec_file_name" {
  type = string
}

variable "codebuild_repo_source_location" {
  type = string

}

variable "codebuild_repo_artifacts_name" {
  type    = string
  default = "aws-repo-artifacts"
}

variable "branch_event_type" {
  type    = string
  default = "PUSH"
}

variable "branch_head_ref" {
  type    = string
  default = "refs/heads/develop"
}

variable "environment_variables" {
  type = map(string)
}

###############################################################################
#                                 Deploy                                      #
###############################################################################



# variable "ecs_listener_arns" {
#   type = string
# }

variable "ecs_service_cluster_name" {
  type = string
}

variable "deployment_timeout" {
  type    = number
  default = 8
}



###############################################################################
#                              Codepipeline                                   #
###############################################################################


variable "codepipeline_name" {
  type    = string
  default = "aws-codepipeline-name"
}

variable "codepipeline_policy_name" {
  type    = string
  default = "aws-codepipeline-policy"
}

variable "codepipeline_role_name" {
  type    = string
  default = "aws-codepipeline-role"
}

variable "remote_party_owner" {
  type    = string
  default = "ThirdParty"
}

variable "source_version_provider" {
  type    = string
  default = "GitHub"
}

variable "connection_arn" {
  type    = string
}

variable "remote_repo_name" {
  description = "Name of the remote repository"
  type        = string

}

variable "remote_file_path" {
  description = "File paths of the remote repository"
  type        = string
}

variable "remote_branch" {
  description = "Branch of the remote repository"
  type        = string
  default     = "main"
}

variable "definition_file_name" {
  description = "Image definition file name"
  type        = string
  default     = "imagedefinition.json"
}

variable "codepi" {
  description = "Image definition file name"
  type        = string
  default     = "imagedefinition.json"
}
variable "ecs_region" {
  type = string
}
variable "ecs_service_name" {
  type = string

}

