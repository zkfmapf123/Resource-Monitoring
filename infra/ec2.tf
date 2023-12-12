################################## IAM ##################################
resource "aws_iam_role" "ins-to-s3-role" {
  name = "ins-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : ["ec2.amazonaws.com"]
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_policy" "fluentbit-s3-access" {
  name = "fluentbit-s3-access"
  path = "/"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "${aws_s3_bucket.fluentbit-logs.arn}",
          "${aws_s3_bucket.fluentbit-logs.arn}/*"
        ],
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ins-to-s3-role.name
  policy_arn = aws_iam_policy.fluentbit-s3-access.arn
}

resource "aws_iam_instance_profile" "ins-profile" {
  name = aws_iam_role.ins-to-s3-role.name
  role = aws_iam_role.ins-to-s3-role.name
}

################################# Instance SG ##################################
resource "aws_security_group" "ins-sg" {
  vpc_id      = local.vpc_id
  name        = "inst-sg"
  description = "description"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "default-ins-sg"
  }
}

################################## Instance ##################################
module "default-public-ins" {
  source = "zkfmapf123/simpleEC2/lee"

  instance_name      = "fluentbit-ins"
  instance_region    = local.subnet_az
  instance_subnet_id = local.subnet_id
  instance_sg_ids    = [aws_security_group.ins-sg.id]

  #   instance_ami  = "ami-086cae3329a3f7d75" ## Linux amazon 2
  #   instance_type = "t2.micro"              ## t2.micro

  instance_iam = aws_iam_instance_profile.ins-profile.id

  instance_ip_attr = {
    is_public_ip  = true
    is_eip        = true
    is_private_ip = false
    private_ip    = ""
  }

  # instance_root_device = {
  #     size =20
  #     type = "gp3"
  # }

  instance_key_attr = {
    is_alloc_key_pair = false
    is_use_key_path   = true
    key_name          = ""
    key_path          = "~/.ssh/id_rsa.pub"
  }

  instance_tags = {
    "Monitoring" : true,
    "MadeBy" : "terraform"
    "Name" : "fluentbit-ins"
  }

  #   user_data_file = "./user_data.sh"
}
