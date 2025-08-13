resource "aws_route_table" "rt" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name          = var.rt-name
    
    },
    var.extra_tags
  )
}

resource "aws_route_table_association" "rt-association" {
  for_each = { for idx, subnet_id in var.subnet_ids : idx => subnet_id }

  subnet_id      = each.value
  route_table_id = aws_route_table.rt.id
}

