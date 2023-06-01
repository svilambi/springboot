terraform {
	backend "s3"{
		bucket = "terraform-java-demo"
		key = "state/terraform.tfstate"
		region = "us-east-2"
	}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}

provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.aws_region
}

resource "aws_instance" "linux-server" {
  count					 	  = var.instance_count
  ami                         = "ami-024e6efaf93d85776"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet1-public.id
  vpc_security_group_ids      = [aws_security_group.allow_8888.id]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = "ubuntu-ec2"
  private_ip				  = "10.1.1.55"
  
  // Userdata
  user_data = <<EOF
#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2 
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>AWS Virtual Machine deployed with Terraform</h1>" | sudo tee /var/www/html/index.html
curl -sL https://get.docker.com | bash
docker pull svilambi/demo:06
docker run -dit -p 8888:8888 svilambi/demo:06
EOF
  
    # root disk
  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }
  
  tags = {
    Name = "demo"
  }

}

resource "aws_vpc" "default" {
    cidr_block = "10.1.0.0/16"
    enable_dns_hostnames = true
    tags = {
        Name = "terraform-aws-testing"
	Owner = "aws_terraform"
	environment = "dev"
    }
}

resource "aws_subnet" "subnet1-public" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "10.1.1.0/24"
    availability_zone = var.aws_region_az

    tags = {
        Name = "Terraform_Public_Subnet1-testing"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
	tags = {
        Name = "terraform-aws-igw"
    }
}




resource "aws_route_table" "terraform-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags = {
        Name = "Terraform_Main_Rtable-testing"
    }
}

resource "aws_route_table_association" "terraform-public" {
    subnet_id = "${aws_subnet.subnet1-public.id}"
    route_table_id = "${aws_route_table.terraform-public.id}"
}

resource "aws_security_group" "allow_8888" {
  name        = "allow_8888"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
	description = "Allow only 8888 port"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
	description = "Allow only 80 port"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
	description = "Allow only 22 port for ssh"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}

output "vm_linux_server_instance_id" {
  value = "${element(aws_instance.linux-server.*.id,0)}"
}

output "vm_linux_server_instance_public_dns" {
  value = "${element(aws_instance.linux-server.*.public_dns,0)}"
}

output "vm_linux_server_instance_public_ip" {
  value = "${element(aws_instance.linux-server.*.public_ip,0)}"
}
