resource "aws_db_subnet_group" "subnet" {
  name       = "techlab_subnet_group_dev"
  subnet_ids = ["subnet-0ab55f479b00ad33c","subnet-0638990c98f6c1333","subnet-08e95901f8d06e800"]
  tags = {
    Name = "techlab_subnet_group_dev"
  }
}

## SG-rds
resource "aws_security_group" "rds_dev" {
  name   = "techlab_rds_dev"
  vpc_id = "vpc-0da02bce82054411a"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "techlab_rds_dev"
  }
}

resource "aws_security_group" "security_group_techlab_lambda_dev" {
  name        = "security_group_lambda_dev"
  description = "Security Group for lambda API DEV"
  vpc_id      = "vpc-0da02bce82054411a"

  ingress {
    description = "Subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Security group lambda dev"
  }
}

## SG-ec2
resource "aws_security_group" "bastion_dev" {
  name   = "techlab_ec2_dev"
  vpc_id = "vpc-0da02bce82054411a"

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "techlab_ec2_dev"
  }
}



resource "aws_db_instance" "db-techlab-dev" {
  allocated_storage    = "30"
  engine               = "postgres"
  engine_version       = "13.7"
  instance_class       = "db.t3.micro"
  name                 = "techlab_database_1"
  username             = "techlab_admin" #
  password             = "ky" #fake value will replace with jenkins credentials
  parameter_group_name = "default.postgres13"
   db_subnet_group_name   = aws_db_subnet_group.subnet.name
  vpc_security_group_ids = [aws_security_group.rds_dev.id]
  apply_immediately = true
  skip_final_snapshot  = true
  backup_retention_period = "10"
  backup_window = "04:46-05:46"
  delete_automated_backups = false
  iam_database_authentication_enabled = false
  identifier = "db-techlab-dev"
  multi_az = "false"
  port = "5432"
  publicly_accessible = false
}

# resource "aws_key_pair" "bastion" {
#   key_name   = "bastion-key"
#   public_key = "x"
# }

# Data para instancia
# data "aws_ami" "ubuntu" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#   owners = ["099720109477"] # Canonical
# }

# Modulo para ec2
# module "ec2_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "~> 3.0"
#   name = "bastion"
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = "t2.micro"
#   key_name               = aws_key_pair.bastion.key_name
#   monitoring             = false
#   associate_public_ip_address = true
#   vpc_security_group_ids = [aws_security_group.bastion_dev.id]
#   subnet_id              = "subnet-0042519f4a2cf933d"
#   user_data              = <<-EOL
#   #!/bin/bash -xe
#   apt install postgresql-client-12 python3-psycopg2 -y
#   EOL
# }
