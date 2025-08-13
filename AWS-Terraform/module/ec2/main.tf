
/* -------------------------------------------------------------------------- */
/*                                  IAM role                                  */
/* -------------------------------------------------------------------------- */

resource "aws_iam_role" "ec2_role" {

  count = var.iam_instance_profile.create_new_instance_profile ? 1 : 0

  # Name of the IAM role for EC2
  name = var.iam_instance_profile.iam_role_name

  # Assume role policy
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  # Tags
   tags = merge(
    {
      Name=var.iam_instance_profile.iam_role_name
    },
    var.extra_tags
  )

}

/* -------------------------------------------------------------------------- */
/*                         IAM inline policy creation                         */
/* -------------------------------------------------------------------------- */

resource "aws_iam_policy" "ec2_policy" {
  # to create inline policy or not
  count = var.iam_instance_profile.create_new_instance_profile && var.iam_instance_profile.create_inline_policy ? 1 : 0

  # Name of the IAM policy for EC2
  name = var.iam_instance_profile.inline_iam_policy_name
  # Description of the IAM policy
  description = var.iam_instance_profile.inline_iam_policy_description

  # policy
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        # Actions to add in the policy
        Action   = var.iam_instance_profile.inline_policy_actions,
        Effect   = "Allow",
        Resource = var.iam_instance_profile.inline_policy_resource
      }
    ]
  })

 tags = merge(
    {
      Name=var.iam_instance_profile.inline_iam_policy_name
    },
    var.extra_tags
  )
}


resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  # Attach the inline policy to the role
  count = var.iam_instance_profile.create_new_instance_profile && var.iam_instance_profile.create_inline_policy ? 1 : 0

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = aws_iam_policy.ec2_policy[0].arn
}


/* -------------------------------------------------------------------------- */
/*                      IAM managed policies attachment                      */
/* -------------------------------------------------------------------------- */

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  # wheather to attach managed policy to the role or not
  count = var.iam_instance_profile.create_new_instance_profile && var.iam_instance_profile.attach_managed_policy ? length(var.iam_instance_profile.managed_policy_arns) : 0

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = var.iam_instance_profile.managed_policy_arns[count.index]
}



/* -------------------------------------------------------------------------- */
/*                             IAM instance profile                            */
/* -------------------------------------------------------------------------- */

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  count = var.iam_instance_profile.create_new_instance_profile ? 1 : 0

  # IAM instance profile name
  name = var.iam_instance_profile.custom_iam_instance_profile_name
  role = aws_iam_role.ec2_role[0].name

 tags = merge(
    {
      Name=var.iam_instance_profile.custom_iam_instance_profile_name
    },
    var.extra_tags
  )
}



/* -------------------------------------------------------------------------- */
/*                                EC2 Instance                                */
/* -------------------------------------------------------------------------- */

resource "aws_instance" "ec2" {

  # Number of Instances
  count = var.number_of_instances

  # AMI for EC2
  ami = data.aws_ami.amazon_linux.id

  # Instance Type for EC2
  instance_type = var.instance_type

  # key pair
  key_name = can(var.key_pair_name) ? var.key_pair_name : null

  # IAM instance profile
  iam_instance_profile = var.iam_instance_profile.create_new_instance_profile ? aws_iam_instance_profile.ec2_instance_profile[0].name : (var.iam_instance_profile.use_existing_instance_profile ? var.iam_instance_profile.existing_instance_profile_name : null)

  # subnet Id
  subnet_id = can(var.subnet_id) ? var.subnet_id : null

  # List of VPC Security Group Ids
  vpc_security_group_ids = var.vpc_security_group_ids

  # Root Block Device specifications
  root_block_device {
    volume_type           = var.root_block_device_details.volume_type
    volume_size           = var.root_block_device_details.volume_size
    delete_on_termination = var.root_block_device_details.delete_on_termination
  }

  # # Market Options for spot instances
  # dynamic "instance_market_options" {
  #   for_each = var.spot_instance_details

  #   content {
  #     market_type = "spot"
  #     spot_options {
  #       max_price                      = var.spot_instance_details.max_price
  #       instance_interruption_behavior = "terminate"
  #     }
  #   }
  # }

  # USERDATA script
  user_data = can(var.user_data_script) ? var.user_data_script : null

  # Tags
  tags = merge(
    {
      Name = var.ec2_instance_name
    },
    var.extra_tags
  )
}
