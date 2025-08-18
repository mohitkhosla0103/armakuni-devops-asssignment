resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket
  
     tags = merge(
    {
      Name =var.bucket
     },
    var.extra_tags
  ) 
  
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.bucket_versioning
  }
}
# resource "aws_s3_bucket_policy" "s3_policy" {
# bucket = aws_s3_bucket.bucket.id
#   policy =var.bucket_policy

# }
