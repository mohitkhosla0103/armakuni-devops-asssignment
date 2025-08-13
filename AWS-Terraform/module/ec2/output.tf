/* ------------------------------- instance id ------------------------------ */

output "EC2_instance_id" {
  value = aws_instance.ec2[*].id
}

/* ------------------------------ instance arn ------------------------------ */

output "EC2_instance_arn" {
  value = aws_instance.ec2[*].arn
}