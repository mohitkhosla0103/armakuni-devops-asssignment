## data for ecs auto scalling group

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"     # Amazon linux 2023 ECS Optimized
    values = ["al2023-ami-ecs-hvm-2023.0.20231204-kernel-6.1-x86_64"]  
  }
}

