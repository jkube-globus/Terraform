terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_spot_instance_request" "GCSv4Nodes" {
  count = 1
  ami           = "ami-0629230e074c580f2"
  instance_type = "t2.micro"
  spot_type = "persistent"
  instance_interruption_behavior = "stop"
  tags = {
    Name = "Ubuntu-GCSv4-Node${count.index}"
  }
}

resource "aws_spot_instance_request" "GCSv5UbuntuNodes" {
  count = 2
  ami           = "ami-06ad98dc9c4e046bd"
  instance_type = "t2.micro"
  spot_type = "persistent"
  instance_interruption_behavior = "stop"
  tags = {
    Name = "Ubuntu-GCSv5-Node${count.index}"
  }
}

resource "aws_spot_instance_request" "GCSv5CentosNodes" {
  count = 1
  ami           = "ami-000e7ce4dd68e7a11"
  instance_type = "t2.micro"
  spot_type = "persistent"
  instance_interruption_behavior = "stop"
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u centos -i  --private-key /home/jkube/.ssh/id_rsa -e /home/jkube/workspace/git/Globus/ansible/TST/globus_GCS_centosSetup.yml"
  }
  tags = {
    Name = "Centos-GCSv5-Node${count.index}"
  }
}
