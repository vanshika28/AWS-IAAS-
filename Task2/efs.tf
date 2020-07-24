provider "aws" {
  
  profile = "default"
  region="us-east-1"
}

resource "aws_security_group" "securegrpnfs" {
  name        = "securegrpnfs"
  description = "Security for instance"
  vpc_id      = "vpc-7e869904"

  ingress {
    description = "NFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
  description = "Http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
  description = "ssh"
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
  ami           = "ami-0e9089763828757e1"
  instance_type = "t2.micro"
key_name ="awstu"
security_groups=["${aws_security_group.securegrpnfs.name}"]

connection{
type="ssh"
user ="ec2-user"
private_key=file("C:/eautomation/key/awstu.pem")
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
    Name = "Nfserver"
  }
}


resource "aws_efs_file_system" "filestorage" {
  creation_token = "Efs"
    tags = {
    Name = "EFS_Storage"
    
  }
}


resource "aws_efs_mount_target" "mount" {
  depends_on =  [ aws_efs_file_system.filestorage,]
  file_system_id = aws_efs_file_system.filestorage.id
  subnet_id      = aws_instance.web.subnet_id
  security_groups = ["${aws_security_group.securegrpnfs.id}"]
}

resource "null_resource" "nullremote3"  {

depends_on = [
    aws_efs_mount_target.mount,
  ]

connection{
type="ssh"
user ="ec2-user"
private_key=file("C:/eautomation/key/awstu.pem")
host=aws_instance.web.public_ip
}

  provisioner "remote-exec" {
    inline = [
       "sudo mount -t nfs4 ${aws_efs_mount_target.mount.ip_address}:/ /var/www/html/",
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

resource "aws_s3_bucket" "nonu1" {
depends_on=[
	null_resource.nullremote3,
]
bucket="nonu1"
acl ="public-read"

provisioner "local-exec" {
    command = "git clone https://github.com/vanshika28/Web-Image.git  Desktop/Image/I36"
  }


}

resource "aws_s3_bucket_object" "vg-object" {
   bucket = aws_s3_bucket.nonu1.bucket
 key    = "vanshika1.png"
acl="public-read"
  source = "Desktop/Image/I36/vanshika1.png"

}


resource "aws_cloudfront_distribution" "s3cloudfront" {


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.nonu1.bucket}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    

  }



  is_ipv6_enabled     = true
  origin {
  
    domain_name = "${aws_s3_bucket.nonu1.bucket_regional_domain_name}"
    origin_id   = "${aws_s3_bucket.nonu1.bucket}"

custom_origin_config {
            http_port = 80
            https_port = 80
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        }

  }
 default_root_object = "index.html"
    enabled = true

  custom_error_response {
        error_caching_min_ttl = 3000
        error_code = 404
        response_code = 200
        response_page_path = "/index.html"
    }


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
connection {
   type="ssh"
user ="ec2-user"
port=22
private_key=file("C:/eautomation/key/awstu.pem")
host=aws_instance.web.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo -i << EOF",
                           "echo \"<img src='http://${self.domain_name}/${aws_s3_bucket_object.vg-object.key}' width='500' height='500'>\" >> /var/www/html/index.html",
"EOF",
    ]
  }
}
output "cloudfront_ip_addr" {
  value = aws_cloudfront_distribution.s3cloudfront.domain_name
}
