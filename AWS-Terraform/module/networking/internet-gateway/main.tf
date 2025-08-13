resource "aws_internet_gateway" "ig" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = var.ig-name
      
    },
    var.extra_tags
  )
}