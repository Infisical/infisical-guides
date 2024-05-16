resource "aws_iam_role" "ssm_instance_role" {
  name = "ssm-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ssm_instance_role.name
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_instance_role.name
}

resource "aws_instance" "bastion_host" {
  instance_type = "t2.micro"
  ami = "ami-033a1ebf088e56e81"
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  user_data = <<-EOF
              #!/bin/bash 
              sudo yum update -y
              sudo yum install -y haproxy
              sudo amazon-linux-extras install -y postgresql10
              sudo systemctl enable haproxy
              sudo systemctl start haproxy
              EOF
  tags = {
    Name = "Bastion host"
  }
}

// Create user group to allow access to ssm 
resource "aws_iam_group" "internal_group" {
  name = "internal-access-via-ssm"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "internal_group_policy" {
  name        = "UserStartSSMSessionPolicy"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:StartSession"
            ],
            "Resource": [
                aws_instance.bastion_host.arn
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:StartSession"
            ],
            "Resource": [
                "arn:aws:ssm:us-east-1::document/AWS-StartPortForwardingSession"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:TerminateSession"
            ],
            "Resource": [
                "arn:aws:ssm:*:*:session/$${aws:username}-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeSessions"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
})
}

resource "aws_iam_group_policy_attachment" "attach_internal_access_policy_group" {
  group      = aws_iam_group.internal_group.name
  policy_arn = aws_iam_policy.internal_group_policy.arn
}