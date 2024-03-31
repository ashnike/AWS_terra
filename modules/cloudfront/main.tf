resource "aws_cloudfront_distribution" "web_distribution" {
  origin {
    domain_name = var.alb_dns_name
    origin_id   = "LoadBalancerOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  enabled             = true
  comment             = "Some comment"
  
  # Viewer certificate for HTTPS
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Restrictions block
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "IN"]
    }
  }

  # Default cache behavior settings
  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "LoadBalancerOrigin"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all" 

    # Adjust TTL settings as needed
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }
  
}
