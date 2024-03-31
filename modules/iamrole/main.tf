resource "aws_iam_policy" "s3-access-webapp-policy" {
  name        = var.iam_policy_name
  description = "An example inline policy"
  policy = file("${path.module}/ec2.json")
}

resource "aws_iam_role" "s3-access-webapp-role" {
  name               = var.role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "example_attachment" {
  role       = aws_iam_role.s3-access-webapp-role.name
  policy_arn = aws_iam_policy.s3-access-webapp-policy.arn
}

# Roles for ssm
resource "aws_iam_role_policy_attachment" "ec2_ssm_attachment" {
  role       = aws_iam_role.s3-access-webapp-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_attachment" {
  role       = aws_iam_role.s3-access-webapp-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an IAM instance profile
resource "aws_iam_instance_profile" "s3-access-profile" {
  name = var.instance_profile_name
  role = aws_iam_role.s3-access-webapp-role.name
}