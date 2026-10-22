output "aws_region" {
    value = var.aws_region 
    description = "AWS region used by the deployment workflow"
}

output "bucket_name" {
    value = aws_s3_bucket.site.id
    description = "Private S3 bucket name used populated by Github Actions"

}

output "direct_s3_object_url" {
    value = "https://${aws_s3_bucket.site.bucket_regional_domain_name}/index.html"
    description = "Direct S3 object URL for the private S3 bucket"
}