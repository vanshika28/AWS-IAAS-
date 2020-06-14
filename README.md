# Terraform
Terraform by HashiCorp, an AWS Partner Network (APN) Advanced Technology Partner and member of the AWS DevOps Competency, is an “infrastructure as code” tool similar to AWS CloudFormation that allows you to create, update, and version your Amazon Web Services (AWS) infrastructure.

![](https://github.com/vanshika28/Terraform/blob/master/teraf/images/CloudFormation_vs_Terraform5.png)

PROJECT1
:Have created/launch Application using Terraform

Launch EC2 instance. In this Ec2 instance used the key and security group which we have created.Launch one Volume (EBS) and mount that volume into /var/www/html Developer have uploded the code into github Copy the github repo code into /var/www/html Created S3 bucket, and copy/deployed the images from github repo into the s3 bucket and change the permission to public readable.Created a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to  update in code in /var/www/html
