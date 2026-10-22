terraform  {
    required_version = "= 1.15.8"

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "6.69.1"
        }
    }
}

provider "aws" { 
    region = var.aws_region
}


data "aws_caller_identity" "current" {}
 
 locals{
    bucket_name = "${var.project_name}-${data.aws_caller_identity.current.account_id}"
    origin_id = "${var.project_name}-s3-origin"
}

resource "aws_s3_bucket" "site" {
    bucket = local.bucket_name 
    force_destroy = true

    tags = {
        Name = var.project_name
        ManagedBy = "Terraform"
        
    }
}

resource "aws_s3_bucket_public_access_block" "site" {
    bucket = aws_s3_bucket.site.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "site" {
    name = "${var.project_name}-oac"
    description = "OAC for the private portfolio s3 bucket"
    origin_access_control_origin_type = "s3"
    signing_behavior = "always"
    signing_protocol = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {
    enabled = true
    is_ipv6_enabled = true
    default_root_object = "index.html"
    price_class = "PriceClass_100"

    origin {
        domain_name = aws_s3_bucket.site.bucket_regional_domain_name
        origin_id = local.origin_id

        origin_access_control_id = aws_cloudfront_origin_access_control.site.id
    }

    default_cache_behavior {
        target_origin_id = local.origin_id
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        compress = true
        min_ttl = 0
        default_ttl = 0
        max_ttl = 0

        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    tags = {
        Name = var.project_name
        ManagedBy = "Terraform"
    }


}

data "aws_iam_policy_document" "cloudfront_read" {
    statement {
        sid = "AllowCloudFrontServicePrincipalReadOnly"
        effect = "Allow"
        actions = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.site.arn}/*"]
        principals {
            type = "Service"
            identifiers = ["cloudfront.amazonaws.com"]
        }
        condition {
            test = "StringEquals"
            variable = "AWS:SourceArn"
            values = [aws_cloudfront_distribution.site.arn]
        }
    }
}

resource "aws_s3_bucket_policy" "cloudfront_read" {
    bucket = aws_s3_bucket.site.id
    policy = data.aws_iam_policy_document.cloudfront_read.json
}

resource "aws_iam_openid_connect_provider" "github" {
    count = var.github_oidc_provider_arn == "" ? 1 : 0
    url = "https://token.actions.githubusercontent.com"
    client_id_list = ["sts.amazonaws.com"]
    
    tags = {
        Name = "GitHub OIDC Provider"
        ManagedBy = "Terraform"
    }
}