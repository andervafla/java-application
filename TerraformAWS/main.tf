terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" 
}

variable "key_path" {
  description = "The path to the SSH key"
  type        = string
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("terraformAWS/pub-key/my_ssh_key.pub") 
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_subnet" "frontend_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "backend_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_route_table_association" "frontend_association" {
  subnet_id      = aws_subnet.frontend_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "backend_association" {
  subnet_id      = aws_subnet.backend_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}


resource "aws_security_group" "frontend_sg" {
  vpc_id      = aws_vpc.my_vpc.id
  name        = "allow_http_ssh"
  description = "Allow HTTP, SSH, and private network traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.2.0/24"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "backend_sg" {
  vpc_id      = aws_vpc.my_vpc.id
  name        = "allow_backend_ssh"
  description = "Allow backend, SSH, and private network traffic"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]  
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.1.0/24"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "frontend" {
  ami                    = "ami-0e86e20dae9224db8" 
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_key.key_name  
  subnet_id              = aws_subnet.frontend_subnet.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "MyFrontendInstance"
  }
}

resource "aws_instance" "backend" {
  ami                    = "ami-0e86e20dae9224db8" 
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_key.key_name  
  subnet_id              = aws_subnet.backend_subnet.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "MyBackendInstance"
  }
}

output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_public_ip" {
  value = aws_instance.backend.public_ip
}
