resource "aws_eip" "elastic-ip" {
  domain = var.domain
  tags = merge(
    {
      Name = var.eip-name
    
    },
    var.extra_tags
  )
}