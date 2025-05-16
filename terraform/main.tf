provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.project_name}-public-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_a_association" {
  subnet_id = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_association" {
  subnet_id = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "app_sg" {
    name = "${var.project_name}-sg"
    description = "Security group for the application"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = "${var.project_name}-sg"
    }
}

resource "aws_instance" "app" {
    ami = var.ami_id
    instance_type = "t2.micro"
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.app_sg.id]
    subnet_id = aws_subnet.public_a.id

    tags = {
        Name = "${var.project_name}-instance"
    }

      user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nodejs npm git
              npm install -g pm2
              
              # Clone the repository
              git clone ${var.repository_url} /app
              cd /app/api
              
              # Install dependencies
              npm install
              
              # Start the application
              npm run build
              pm2 start dist/main.js --name nestjs-app
              EOF
}


