output "s3_id" {
  value = aws_s3_bucket.bucket.id
}

output "s3_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "s3_domain_name" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}