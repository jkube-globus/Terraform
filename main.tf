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

#GCsV4 Ubuntu AMI
data "aws_ami" "GCSv4_ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
resource "aws_instance" "GCSv4Nodes" {
  count = 1
  ami           = data.aws_ami.GCSv4_ubuntu.id
  key_name = "KUBE20211112"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-061065abfa8528d29"]
  provisioner "local-exec" {
    command = "echo ${aws_instance.GCSv4Nodes[count.index].tags.Name} ansible_host=${aws_instance.GCSv4Nodes[count.index].public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/jkube/.ssh/KUBE20211112.pem>>inventory"
	  }

  tags = {
    Name = "Ubuntu-GCSv4-Node${count.index}"
  }
}
resource "aws_instance" "GCSv5UbuntuNodes" {
  count = 2
  ami           = "ami-06ad98dc9c4e046bd" #ami-06ad98dc9c4e046bd   2022-08-10T20:12:56.000Z
  key_name = "KUBE20211112"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-061065abfa8528d29"]
  provisioner "local-exec" {
#command = "echo ${aws_instance.GCSv5UbuntuNodes[count.index].tags.Name} ansible_host=${aws_instance.GCSv5UbuntuNodes[count.index].public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/jkube/.ssh/KUBE20211112.pem>>inventory"
    command = "echo ${self.tags.Name} ansible_host=${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/jkube/.ssh/KUBE20211112.pem>>inventory"
	  }

  tags = {
    Name = "Ubuntu-GCSv5-Node${count.index}"
  }
}
resource "aws_instance" "GCSv5Rocky8Nodes" {
  count = 1
  ami           = "Rocky-8-ec2-8.6-20220515.0.x86_64-d6577ceb-8ea8-4e0e-84c6-f098fc302e82"
  key_name = "KUBE20211112"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-061065abfa8528d29"]
  provisioner "local-exec" {
    command = "echo ${aws_instance.GCSv5Rocky8Nodes[count.index].tags.Name} ansible_host=${aws_instance.GCSv5Rocky8Nodes[count.index].public_ip} ansible_user=rocky ansible_ssh_private_key_file=/home/jkube/.ssh/KUBE20211112.pem>>inventory"
	  }
#;provisioner "local-exec" {
#;command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u centos -i aws_instance.  --private-key /home/jkube/.ssh/id_rsa -e /home/jkube/workspace/git/Globus/ansible/TST/globus_GCS_centosSetup.yml"
#;}


  tags = {
    Name = "Rocky8-GCSv5-Node${count.index}"
  }
}

resource "null_resource" "nullremote2" {
depends_on = [aws_instance.GCSv4Nodes,aws_instance.GCSv5UbuntuNodes,aws_instance.GCSv5Rocky8Nodes]  
  provisioner "remote-exec" {
    connection {
      host = aws_instance.GCSv4Nodes[0].public_dns
      user = "ubuntu"
      private_key = file("/home/jkube/.ssh/KUBE20211112.pem")
    }
    inline = ["echo 'GCSv4Ubuntu node online!'"]
  }
  provisioner "remote-exec" {
    connection {
      host = aws_instance.GCSv5UbuntuNodes[1].public_dns
      user = "ubuntu"
      private_key = file("/home/jkube/.ssh/KUBE20211112.pem")
    }
    inline = ["echo 'GCSv5Ubuntu nodes online!'"]
  }
  provisioner "remote-exec" {
    connection {
      host = aws_instance.GCSv5Rocky8Nodes[0].public_dns
      user = "rocky"
      private_key = file("/home/jkube/.ssh/KUBE20211112.pem")
    }
    inline = ["echo 'GCSv5Rocky8 node online!'"]
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory /home/jkube/workspace/git/Globus/ansible/TST/globus_GCS_allDistros.yml"
  }
}
