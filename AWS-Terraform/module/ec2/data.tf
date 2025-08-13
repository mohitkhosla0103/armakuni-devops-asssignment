
# Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.20250107.0-kernel-6.1-x86_64"]
  }

}
