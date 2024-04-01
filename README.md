# AWS Infrastructure Provisioning for the Deployment of a Web Application.

## Objective:

To Deploy ask a web application using Infrastructure as Code (IaC) principles on AWS. The web application is packaged as a Docker image.

1. Utilize an S3 bucket to store files uploaded by users.
2. Ensure the web application is behind a CloudFront CDN for improved performance.
3. Implement auto-scaling to handle varying workloads efficiently.

## Instructions:

### Docker Image

- We will use a docker image from the [dockerhub-registry](https://hub.docker.com/repository/docker/ashniike/aws_s3_webapp/general) `ashniike/aws_s3_webapp`.

### Environment Variables

We will configure the Docker container with the following environment variables at runtime to specify which bucket to access.

- **S3_BUCKET_NAME:** [Your S3 Bucket Name]
- **AWS_REGION:** [Your AWS Region]

Pass the Environment variables to the container at runtime.
```
docker run -e S3_BUCKET_NAME=" " -e AWS_REGION=" " -p 8000:8000 ashniike/aws_s3_webapp:latest
```

### For better security practice, we will use the IAM role instead of Access ID and Secret Key.

Make sure the IAM role has the necessary permissions for S3 operations (e.g., `s3:GetObject`, `s3:PutObject`, etc.) on the specified bucket as given in [ec2.json](https://github.com/ashnike/AWS_terra/blob/main/modules/iamrole/ec2.json).


### Infrastructure as Code (IaC)

Write Terraform scripts to:

1. Clone the following Repository.
```
git clone https://github.com/ashnike/AWS_terra.git
```
2. Enter the **environments/backend** directory, initialize the following directory using `terraform init `, and execute the following commands to configure the backend to maintain a remote state file in the s3 bucket and dynamo locking using dynamotb table.
```
terraform plan
```
The above command is used to create an execution plan that outlines the changes Terraform will make to your infrastructure to bring it in line with your configuration files. Running Terraform plan scans the current directory for Terraform configuration files and state data, and then compares the current state to the desired state described in the configuration files.
```
terraform apply
```
The Terraform apply is a command used in Terraform to apply the changes defined in your configuration files to your infrastructure. 
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
4. Configure the name  and the region of the s3-bucket in the [variables](https://github.com/ashnike/AWS_terra/blob/main/modules/s3/variables.tf) file in the s3 module.
5. Do the same changes in this [policy](https://github.com/ashnike/AWS_terra/blob/main/modules/iamrole/ec2.json). Also, do the same in the [nginx script](https://github.com/ashnike/AWS_terra/blob/main/modules/asg/nginx.sh).
6. Initialize the Terraform parent directory using the following command so that Terraform reads the configuration files in the current directory and downloads any necessary plugins for the providers specified in the configuration.
```
terraform init
```
Followed by the `Terraform plan` to do a dry run to see what changes would be applied.
7. Execute the provisioning of the modules at the root main.tf file using the following commands from the parent directory.
```
terraform apply
```
Confirm the destruction by typing **yes** when prompted.
8. The nameservers will be generated in the [nameservers.txt](https://github.com/ashnike/AWS_terra/blob/main/nameservers.txt) file.

9. Copy these nameservers as new nameservers records in your hosting provider's domain name records.
10. To destroy the provisioned infrastructure and clean up resources. Run the following command to destroy the Infrastructure.
```
terraform destroy
```
Confirm the destruction by typing **yes** when prompted. Wait for Terraform to remove all resources. 

