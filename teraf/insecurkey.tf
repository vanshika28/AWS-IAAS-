provider "aws"{
profile="Garg"
region="ap-south-1"
}
resource "aws_key_pair" "deployer" {
  key_name   = "vgos1"
  public_key = file("C:/Internship peackok/t/pass1.pem")
}
resource "aws_instance" "web" {
  ami           = "ami-0ca845a6eb3903743"
  instance_type = "t2.micro"

  tags = {
    Name = "Vgwebos1"
  }
key_name ="vgos1"
security_groups=["launch-wizard-5"]
}
