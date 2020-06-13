provider "aws"{
profile="Garg"
region="ap-south-1"
}


resource "aws_security_group" "security1tera" {
  name        = "security1tera"
  description = "Security for instance"
  vpc_id      = "vpc-68f0ed00"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0ca845a6eb3903743"
  instance_type = "t2.micro"

key_name ="os1"


security_groups=["${aws_security_group.security1tera.name}"]



connection{
type="ssh"
user ="ec2-user"
private_key=file("C:/eautomation/key/os1.pem")
host=aws_instance.web.public_ip
}

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd php -y",
          "sudo yum install git -y ",
        "sudo systemctl restart httpd",
       "sudo systemctl enable httpd"
      
    ]
  }
  tags = {
    Name = "Vgwebos1"
  }
}

resource "aws_ebs_volume" "e1" {
  availability_zone = aws_instance.web.availability_zone
  size              = 1

  tags = {
    Name = "H1"
  }

}

resource "aws_volume_attachment" "attach1" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.e1.id}"
  instance_id = "${aws_instance.web.id}"
 force_detach= true
}
output "myos_ip" {
  value = aws_instance.web.public_ip
}

resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.attach1,
  ]

connection{
type="ssh"
user ="ec2-user"
private_key=file("C:/eautomation/key/os1.pem")
host=aws_instance.web.public_ip
}

  provisioner "remote-exec" {
    inline = [
       "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf  /var/www/html/*",
      "sudo git clone  https://github.com/vanshika28/Html3.git /var/www/html/"

    ]
  }
}

resource "null_resource" "nulllocal2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.web.public_ip} > publicip.txt"
  	}
}



