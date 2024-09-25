resource "aws_security_group" "bastion" {
  name = "${var.project_name}-bastion-sg"
  vpc_id = module.vpc_ma.vpc_id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
    from_port = "22"
    to_port = "22"
  }

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "28282"
    to_port = "28282"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "80"
    to_port = "80"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "443"
    to_port = "443"
  }

  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "keypair" {
  key_name = "${var.project_name}-keypair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "keypair" {
  content = tls_private_key.rsa.private_key_pem
  filename = "./temp/keypair.pem"
}


resource "aws_iam_role" "bastion" {
  name = "${var.project_name}-bastion-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project_name}-bastion-role"
  role = aws_iam_role.bastion.name
}

resource "aws_instance" "bastion" {
  subnet_id = module.vpc_ma.public_subnets[0]
  security_groups = [aws_security_group.bastion.id]
  ami = data.aws_ami.al2023.id
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  key_name = aws_key_pair.keypair.key_name

  instance_type = "t3.small"
  tags = {
    Name = "${var.project_name}-bastion-ec2"
  }

  lifecycle {
    ignore_changes = [security_groups]
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
}

output "bastion_ip" {
  value = aws_eip.bastion.public_ip
}
