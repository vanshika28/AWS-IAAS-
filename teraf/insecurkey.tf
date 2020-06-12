provider "aws"{
profile="Garg"
region="ap-south-1"
}


resource "aws_key_pair" "deployer" {
  key_name   = "vgos1"
  public_key = file("C:/Internship peackok/t/pass1.pem")
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

  tags = {
    Name = "Vgwebos1"
  }
key_name ="vgos1"
security_groups=["${aws_security_group.security1tera.name}"]
}
