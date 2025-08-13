

###############################################################################
#                              Codebuild                                      #
###############################################################################



resource "aws_iam_policy" "CodeBuildBasePolicy-policy-repo" {

  description = "Policy used in trust relationship with CodeBuild"
  name        = "CodeBuildBasePolicy-${var.codebuild_repo_policy_name}"
  path        = "/service-role/"

  policy = <<-EOF
    {
      "Statement": [
        {
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.codebuild_repo_project_name}",
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.codebuild_repo_project_name}:*"
          ]
        },
        {
          "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:s3:::${var.codebuild_codepipeline_artifact_store}",
            "arn:aws:s3:::${var.codebuild_codepipeline_artifact_store}/*"
          ]
        },
        {
          "Action": [
            "s3:PutObject",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:s3:::${var.codebuild_repo_artifacts_location}",
            "arn:aws:s3:::${var.codebuild_repo_artifacts_location}/*"
          ]
        },
        {
          "Action": [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases",
            "codebuild:BatchPutCodeCoverages"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/${var.codebuild_repo_project_name}-*"
          ]
        }
      ],
      "Version": "2012-10-17"
    }
  EOF

  tags = {
    Name             = "CodeBuildBasePolicy-${var.codebuild_repo_policy_name}"
    TerraformManaged = true
  }
}

resource "aws_iam_role" "codebuild-service-role" {

  
  assume_role_policy = <<-EOF
    {
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": "codebuild.amazonaws.com"
          }
        }
      ],
      "Version": "2012-10-17"
    }
  EOF

  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/CloudFrontFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess",
    aws_iam_policy.CodeBuildBasePolicy-policy-repo.arn
  ]
  max_session_duration = 3600
  name                 = var.codebuild_repo_role_name
  path                 = "/service-role/"

  tags = {
    Name             = var.codebuild_repo_role_name
    TerraformManaged = true
  }
}

resource "aws_codebuild_project" "this" {

  name               = var.codebuild_repo_project_name
  description        = var.codebuild_repo_project_description
  service_role       = aws_iam_role.codebuild-service-role.arn
  source_version     = var.codebuild_repo_source_version
  project_visibility = "PRIVATE"
  depends_on         = [aws_iam_role.codebuild-service-role]

  source {
    buildspec           = file("${path.module}/${var.buildspec_file_name}")
    report_build_status = false
    type                = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.environment_variables["AWS_DEFAULT_REGION"]
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.environment_variables["AWS_ACCOUNT_ID"]
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.environment_variables["IMAGE_REPO_NAME"]
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = var.environment_variables["IMAGE_TAG"]
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = var.environment_variables["CONTAINER_NAME"]
    }

    environment_variable {
      name  = "SECRET_NAME"
      value = var.environment_variables["SECRET_NAME"]
    }
    environment_variable {
      name = "PARAMETER_STORE_NAME"
      value = var.environment_variables["PARAMETER_STORE_NAME"]
    }

    environment_variable {
      name  = "DOCKER_PLATFORM"
      value = var.environment_variables["DOCKER_PLATFORM"]
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  tags = merge(
    {
      "Name"             = var.codebuild_repo_project_name
      "TerraformManaged" = true
    },
    var.extra_tags
  )
}

# resource "aws_cloudwatch_log_group" "cloudwatch" {

#   count             = var.create_codepipeline ? 1 : 0
#   name              = var.codebuild_repo_project_name
#   retention_in_days = 7
#   tags = merge(
#     {
#       "Name"             = var.codebuild_repo_project_name
#       "Environment"      = var.tags.environment
#       "Project"          = var.tags.project
#       "TerraformManaged" = true
#     },
#     var.extra_tags
#   )
# }


###############################################################################
#                                Codepipeline v2                              #
###############################################################################

resource "aws_iam_policy" "codepipeline-iam-policy" {

  description = "Policy used in trust relationship with CodePipeline"
  name        = var.codepipeline_policy_name
  path        = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "iam:PassRole",
          ]
          Condition = {
            StringEqualsIfExists = {
              "iam:PassedToService" = [
                "cloudformation.amazonaws.com",
                "elasticbeanstalk.amazonaws.com",
                "ec2.amazonaws.com",
                "ecs-tasks.amazonaws.com",
              ]
            }
          }
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "codecommit:CancelUploadArchive",
            "codecommit:GetBranch",
            "codecommit:GetCommit",
            "codecommit:GetRepository",
            "codecommit:GetUploadArchiveStatus",
            "codecommit:UploadArchive",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetApplication",
            "codedeploy:GetApplicationRevision",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:RegisterApplicationRevision",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "codestar-connections:UseConnection",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "elasticbeanstalk:*",
            "ec2:*",
            "elasticloadbalancing:*",
            "autoscaling:*",
            "cloudwatch:*",
            "s3:*",
            "sns:*",
            "cloudformation:*",
            "rds:*",
            "sqs:*",
            "ecs:*",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "lambda:InvokeFunction",
            "lambda:ListFunctions",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "opsworks:CreateDeployment",
            "opsworks:DescribeApps",
            "opsworks:DescribeCommands",
            "opsworks:DescribeDeployments",
            "opsworks:DescribeInstances",
            "opsworks:DescribeStacks",
            "opsworks:UpdateApp",
            "opsworks:UpdateStack",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "cloudformation:CreateStack",
            "cloudformation:DeleteStack",
            "cloudformation:DescribeStacks",
            "cloudformation:UpdateStack",
            "cloudformation:CreateChangeSet",
            "cloudformation:DeleteChangeSet",
            "cloudformation:DescribeChangeSet",
            "cloudformation:ExecuteChangeSet",
            "cloudformation:SetStackPolicy",
            "cloudformation:ValidateTemplate",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild",
            "codebuild:BatchGetBuildBatches",
            "codebuild:StartBuildBatch",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "devicefarm:ListProjects",
            "devicefarm:ListDevicePools",
            "devicefarm:GetRun",
            "devicefarm:GetUpload",
            "devicefarm:CreateUpload",
            "devicefarm:ScheduleRun",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "servicecatalog:ListProvisioningArtifacts",
            "servicecatalog:CreateProvisioningArtifact",
            "servicecatalog:DescribeProvisioningArtifact",
            "servicecatalog:DeleteProvisioningArtifact",
            "servicecatalog:UpdateProduct",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "cloudformation:ValidateTemplate",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "ecr:DescribeImages",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "states:DescribeExecution",
            "states:DescribeStateMachine",
            "states:StartExecution",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
        {
          Action = [
            "appconfig:StartDeployment",
            "appconfig:StopDeployment",
            "appconfig:GetDeployment",
          ]
          Effect     = "Allow"
          "Resource" = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = {
    Name             = var.codepipeline_policy_name
    TerraformManaged = true
  }
}

resource "aws_iam_role" "codepipeline-iam-role" {

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codepipeline.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
    aws_iam_policy.codepipeline-iam-policy.arn
  ]
  max_session_duration = 3600
  name                 = var.codepipeline_role_name
  depends_on           = [aws_iam_policy.codepipeline-iam-policy]
  path                 = "/service-role/"
  tags = {
    Name             = var.codepipeline_role_name
    TerraformManaged = true
  }
}

resource "aws_codepipeline" "this" {

  name       = var.codepipeline_name
  depends_on = [aws_iam_role.codepipeline-iam-role]
  role_arn   = aws_iam_role.codepipeline-iam-role.arn



  # trigger {
  #   provider_type = "CodeStarSourceConnection"
  #   git_configuration {
  #     source_action_name = "Source"
  #     push {
  #       branches {
  #         includes = [var.remote_branch]
  #       }
  #       dynamic "file_paths" {
  #         for_each = var.remote_file_path != "" ? [1] : []
  #         content {
  #           includes = [var.remote_file_path]

  #         }
  #       }
  #     }
  #   }
  # }

  artifact_store {
    location = var.codebuild_codepipeline_artifact_store
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      output_artifacts = ["SourceArtifact"]
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      run_order        = 1
      version          = "1"
      region           = var.ecs_region
      configuration = {
        ConnectionArn    = var.connection_arn
        FullRepositoryId = var.remote_repo_name
        BranchName       = var.remote_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 2
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.this.name # Mention secondary codebuild here
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "ClusterName"       = var.ecs_service_cluster_name
        "DeploymentTimeout" = var.deployment_timeout
        "FileName"          = var.definition_file_name
        "ServiceName"       = var.ecs_service_name
      }
      input_artifacts = ["BuildArtifact"]
      name            = "Deploy"
      namespace       = "DeployVariables"
      owner           = "AWS"
      provider        = "ECS"
      region          = var.ecs_region
      run_order       = 3
      version         = "1"
    }
  }

  tags = merge(
    {
      "Name"             = var.codepipeline_name
      "TerraformManaged" = true
    },
    var.extra_tags
  )

}

# resource "aws_cloudwatch_log_group" "aws_codebuild_codepipeline-cloudwatch" {

#   count             = var.create_codepipeline ? 1 : 0
#   name              = var.codepipeline_name
#   retention_in_days = 7
#   tags = merge(
#     {
#       "Name"             = var.codepipeline_name
#       "Environment"      = var.tags.environment
#       "Project"          = var.tags.project
#       "TerraformManaged" = true
#     },
#     var.extra_tags
#   )
# }
