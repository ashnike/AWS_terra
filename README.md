# AWS Infrastructure Provisioning for the Deployment of a Web Application.

## Objective:

To Deploy ask a web application using Infrastructure as Code (IaC) principles on AWS. The web application is packaged as a Docker image.

1. Utilize an S3 bucket to store files uploaded by users.
2. Ensure the web application is behind a CloudFront CDN for improved performance.
3. Implement auto-scaling to handle varying workloads efficiently.

## Instructions:

### Docker Image

- We will use a docker image from the docker hub registry `ashniike/aws_s3_webapp`.

### Environment Variables

We will configure the Docker container with the following environment variables at runtime to specify which bucket to access.

- **S3_BUCKET_NAME:** [Your S3 Bucket Name]
- **AWS_REGION:** [Your AWS Region]

Pass the Environment variables to the container at runtime.
```
docker run -e S3_BUCKET_NAME=" " -e AWS_REGION=" " -p 8000:8000 ashniike/aws_s3_webapp:latest
```

### We will use the IAM role instead of Access ID and Access Key for better security practices.

Make sure the IAM role has the necessary permissions for S3 operations (e.g., `s3:GetObject`, `s3:PutObject`, etc.) on the specified bucket as given in [ec2.json](https://github.com/ashnike/AWS_terra/blob/main/modules/iamrole/ec2.json).


### Infrastructure as Code (IaC)

Write Terraform scripts to:

1. Clone the following Repository.
```
git clone https://github.com/ashnike/AWS_terra.git
```
2. Enter the **environments/backend** directory and execute the following command to configure the backend to maintain a remote state file in the s3 bucket and dynamo locking using dynamotb table.
```
terraform apply
```
3. Return to the parent directory, and configure the backend.tf file with resources created in the *environments/backend**.
```
terraform {
  backend "s3" {
    bucket         = "s3-bucket-name"
    key            = "folder/terraform.tfstate"
    region         = "AWS_REGION"
    dynamodb_table = "dynamodb_table_name"
  }
}
```
5. Configure the name  and the region of the s3-bucket in the [variables](https://github.com/ashnike/AWS_terra/blob/main/modules/s3/variables.tf) file in the s3 module.
6. Do the same changes in this [policy](https://github.com/ashnike/AWS_terra/blob/main/modules/iamrole/ec2.json). Also, do the same in the [nginx script](https://github.com/ashnike/AWS_terra/blob/main/modules/asg/nginx.sh).

4. Execute the modules using the root main.tf file using the following command from the parent directory.
```
terraform apply
```
3. The nameservers will be generated in the [nameservers.txt](https://github.com/ashnike/AWS_terra/blob/main/nameservers.txt) file.

4. Copy these nameservers as new nameservers records in your hosting provider's domain name records.


