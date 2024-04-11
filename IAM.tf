resource "aws_iam_policy" "hapolicy" {
  name        = "ha-fortigate"
  path        = "/"
  description = "ha-fortigate"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:DetachNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:ReplaceRoute",
          "ec2:UnassignPrivateIpAddresses",
          "ec2:AssociateAddress",
          "ec2:AssignPrivateIpAddresses"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "HA-FortiOS"
  assume_role_policy = jsonencode ({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
       },
      ]
    })
  }
  
  
  resource "aws_iam_policy_attachment" "ec2_policy_role" {
    name  = "ec2_attachment"
    roles = [aws_iam_role.ec2_role.name]
    policy_arn = aws_iam_policy.hapolicy.arn
   }
   
  resource "aws_iam_instance_profile" "ec2_profile" {
    name = "ec2_profile"
    role = aws_iam_role.ec2_role.name
   }