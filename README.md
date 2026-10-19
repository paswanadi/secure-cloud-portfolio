# Secure AWS Portfolio Deployment Pipeline

A cloud-engineering portfolio served through Amazon CloudFront from a private Amazon S3 origin. Terraform defines the infrastructure, and GitHub Actions deploys `index.html` through OpenID Connect without stored AWS access keys.

## Architecture

```text
Developer push to main
        |
        v
GitHub Actions OIDC
        |
        v
IAM deployment role ---> private S3 bucket
                              |
                              v
                    CloudFront OAC and HTTPS
                              |
                              v
                           Visitor
```

## Security decisions

- S3 Block Public Access remains enabled.
- The bucket policy grants `s3:GetObject` only to the CloudFront service principal for this distribution.
- The GitHub role trusts the repository's immutable owner and repository IDs on `refs/heads/main`.
- The workflow receives permission only to upload `index.html`.
- No AWS access key is stored in GitHub.

## Deploy infrastructure

1. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars` and replace the placeholders.
2. Run `terraform -chdir=terraform init`.
3. Run `terraform -chdir=terraform validate`.
4. Run `terraform -chdir=terraform apply`.
5. Add the Terraform outputs to the GitHub repository variables used by the workflow.

## Demonstrate the project

1. Open the direct S3 object URL and show that access is denied.
2. Open the CloudFront URL and show the live portfolio over HTTPS.
3. Change visible text in `index.html`, commit it, and push to `main`.
4. Show the successful GitHub Actions run and the updated live page.

## Clean up

Run `terraform -chdir=terraform destroy` and confirm the destroy plan.