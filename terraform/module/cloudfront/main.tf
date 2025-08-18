
# AWS CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "my_oai" {
  comment = "OAI for my CloudFront distribution"
}

# AWS CloudFront distribution
resource "aws_cloudfront_distribution" "my_distribution" {

  enabled = true

  default_cache_behavior {
    target_origin_id  = "S3BucketOrigin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods   = ["GET", "HEAD", "OPTIONS"]
    cached_methods    = ["GET", "HEAD", "OPTIONS"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # Viewer certificate for HTTPS
  viewer_certificate {
    cloudfront_default_certificate = true
    # acm_certificate_arn = var.cloudfront_acm_cert_arn
    # ssl_support_method  = "sni-only"
    # minimum_protocol_version = "TLSv1.2_2018"
  }

  # CloudFront Origin Access Identity association
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Additional settings if needed

  # Origin Access Identity association
  origin {
    domain_name = var.bucket_domain_name
    origin_id   = "S3BucketOrigin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.my_oai.cloudfront_access_identity_path
    }
  }
     tags = merge(
    {
      
     
    },
    var.extra_tags
  )
}

