

resource  "tls_private_key" "this"{
algorithm="RSA"
}

module "key_pair" {
    source= "terraform-aws-modules/key-pair/aws"

  key_name="tera1"
  public_key= tls_private_key.this.public_key_openssh
}


