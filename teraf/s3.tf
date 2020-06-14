provider "aws"{
region="ap-south-1"
profile="Garg"
}
resource "aws_s3_bucket" "nonu1" {
bucket="nonu1"
acl ="public-read"

provisioner "local-exec" {
    command = "git clone https://github.com/vanshika28/Web-Image.git  Desktop/Image/I3"
  }


}

resource "aws_s3_bucket_object" "vg-object" {
   bucket = aws_s3_bucket.nonu1.bucket
 key    = "vanshika1.png"
acl="public-read"
  source = "Desktop/Image/I3/vanshika1.png"

}


