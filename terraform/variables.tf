variable "aws_region" {
  description = "AWS region for the S3 bucket and provider operation"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name for the S3 bucket"
  type        = string
  default     = "secure-cloud-portfolio"
}

variable "github_owner" {
  description = "Github username or organization that owns the repository"
  type = string
}

variable "github_owner_id" {
  description = "Immutable numeric ID of the GitHub repository owner"
  type = string
}

variable "github_repository" {
  description = "Github repository name"
  type = string 
  default = "secure-cloud-portfolio"

}

variable "github_repository_id" {
  description = "Immutable numeric ID of the GitHub repository"
  type = string
}

variable "github_oidc_provider_arn" {
  description = "Existing Github OIDC provier ARN, or an empty string to create one"
  type = string 
  default = ""
}