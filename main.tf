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

resource "aws_instance" "GCSv4Nodes" {
  count = 1
  ami           = "ami-0629230e074c580f2"
  instance_type = "t2.micro"
  provisioner "local-exec" {
    command = "echo ${aws_instance.GCSv4Nodes[count.index].tags.Name} ansible_host=${aws_instance.GCSv4Nodes[count.index].public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/jkube/.ssh/KUBE20211112.pem>>inventory"
	  }

  tags = {
    Name = "Ubuntu-GCSv4-Node${count.index}"
  }
}
resource "aws_instance" "GCSv5UbuntuNodes" {
  count = 2
  ami           = "ami-06ad98dc9c4e046bd"
  instance_type = "t2.micro"
  provisioner "local-exec" {
#command = "echo ${aws_instance.GCSv5UbuntuNodes[count.index].tags.Name} ansible_host=${aws_instance.GCSv5UbuntuNodes[count.index].public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/jkube/.ssh/KUBE20211112.pem>>inventory"
    command = "echo ${self.tags.Name} ansible_host=${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/jkube/.ssh/KUBE20211112.pem>>inventory"
	  }

  tags = {
    Name = "Ubuntu-GCSv5-Node${count.index}"
  }
}
resource "aws_instance" "GCSv5CentosNodes" {
  count = 1
  ami           = "ami-000e7ce4dd68e7a11"
  instance_type = "t2.micro"
  provisioner "local-exec" {
    command = "echo ${aws_instance.GCSv5CentosNodes[count.index].tags.Name} ansible_host=${aws_instance.GCSv5CentosNodes[count.index].public_ip} ansible_user=centos ansible_ssh_private_key_file=/home/jkube/.ssh/KUBE20211112.pem>>inventory"
	  }
#;provisioner "local-exec" {
#;command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u centos -i aws_instance.  --private-key /home/jkube/.ssh/id_rsa -e /home/jkube/workspace/git/Globus/ansible/TST/globus_GCS_centosSetup.yml"
#;}


  tags = {
    Name = "Centos-GCSv5-Node${count.index}"
  }
}

