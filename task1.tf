provider "aws" {
	region = "ap-south-1"
	profile = "shrey2"
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "my_key12"
  public_key = tls_private_key.this.public_key_openssh
}


resource "aws_security_group" "web_secure1" {
  name        = "web_secure1"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-1559457d"

  ingress {
    
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_secure1"
  }
}


resource "aws_instance" "web" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name = "key12"
  security_groups = [ "launch-wizard-1" ]
  
 tags={
  Name ="shreyos"
}
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/gupta/Downloads/key12.pem")
    host     = aws_instance.web.public_ip
  } 
 provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  html git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
]
}	
  
}
resource "aws_ebs_volume" "esb11" {
  availability_zone = aws_instance.web.availability_zone
  size              = 1
  tags = {
    Name = "shreyebs"
  }
}

resource "aws_volume_attachment" "ebs_att1" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.esb11.id
  instance_id = aws_instance.web.id
  force_detach = true
}
output "myos_ip" {
  value = aws_instance.web.public_ip
}

resource "null_resource" "nullremote3"  {
 
depends_on = [aws_volume_attachment.ebs_att1]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/gupta/Downloads/key12.pem")
    host     = aws_instance.web.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/shrey285001/terraform.git /var/www/html/"
    ]
  }
} 

resource "aws_s3_bucket" "terra_s3"{
	bucket="hero11"
        acl   ="public-read"
}

resource"aws_s3_bucket_object""object"{
depends_on=[aws_s3_bucket.terra_s3]
bucket=aws_s3_bucket.terra_s3.bucket
key= "shrey.jpg"
source="C:/Users/gupta/Downloads/shrey.jpg"
acl="public-read"
}



resource "aws_cloudfront_distribution" "cloudfront2" {
 origin {
       domain_name= "terra1.s3.amazonaws.com"
	origin_id =  "s3-terra1"
  
       custom_origin_config{
                 http_port =80
 		 https_port=80
                 origin_protocol_policy="match-viewer"
		 origin_ssl_protocols =["TLSv1","TLSv1.1","TLSv1.2"]
}
}
 enabled =true
 
 default_cache_behavior{
   allowed_methods=["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
   cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-terra1"
   
     forwarded_values  {
         query_string = false 
     
     cookies {
          forward="none"
}
}
viewer_protocol_policy ="allow-all"
min_ttl=0
default_ttl=3600
max_ttl=86400
}
restrictions{
     geo_restriction{
     restriction_type="none"
}
}
viewer_certificate{
 cloudfront_default_certificate=true
}
}

resource "null_resource" "nulllocal1"  {
depends_on = [
    null_resource.nullremote3,
    aws_cloudfront_distribution.cloudfront2
  ]

	provisioner "local-exec" {
	    command = "start  http://${aws_instance.web.public_ip}.index1.html"
  	}
}


output "myout1"{
 value = aws_instance.web.public_ip
}