output sg_id {
  value = aws_security_group.sg.id
}
output dependent_sg_name {
  value = aws_security_group.sg.name
}