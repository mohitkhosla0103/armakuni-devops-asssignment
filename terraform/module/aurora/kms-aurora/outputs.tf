output "primary_region_key" {
    value = aws_kms_key.aurora_multi_region_key
}

output "secondary_region_key" {
    value = aws_kms_replica_key.aurora_multi_region_replica
}
