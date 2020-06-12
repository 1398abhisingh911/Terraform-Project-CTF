provider "aws" {
  region = "ap-south-1"
}


resource "aws_instance" "web" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "day3"
  security_groups = [ "launch-wizard-30" ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/196AKS/Desktop/Cloud Intern/Terraform/Docker/day3.pem")
    host     = aws_instance.web.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd docker git -y",
      "sudo mkdir /home/ec2-user/a",
      "sudo systemctl restart docker",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose>/dev/null",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose",

    ]
  }

  tags = {
    Name = "lwos1"
  }

}


resource "aws_ebs_volume" "esb1" {
  availability_zone = aws_instance.web.availability_zone
  size              = 1
  tags = {
    Name = "lwebs"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.esb1.id}"
  instance_id = "${aws_instance.web.id}"
  force_detach = true
}


output "myos_ip" {
  value = aws_instance.web.public_ip
}


resource "null_resource" "nulllocal2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.web.public_ip}:8000 > publicip.txt"
  	}
}



resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/196AKS/Desktop/Cloud Intern/Terraform/Docker/day3.pem")
    host     = aws_instance.web.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh   /home/ec2-user/a",
      "sudo rm -rf /home/ec2-user/a/*",
      "sudo git clone https://github.com/CTFd/CTFd.git /home/ec2-user/a",
      "sudo docker-compose -f /home/ec2-user/a/docker-compose.yml up"
    ]
  }
}




