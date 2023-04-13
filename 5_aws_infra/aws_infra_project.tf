provider "aws" {
  access_key = ""
  secret_key = ""
  region = "ap-south-1"
}


#creating vpc

resource "aws_vpc" "test_vpc" {
  
  tags = {
    "Name" = "test_vpc"
  }

  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
}

#---------------------------------------------------------------

#creating public and private subnet

resource "aws_subnet" "subnet_public_1" {
  tags = {
    "Name" = "subnet_public_1"
  }

  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true  # auto assign public ip
  depends_on = [aws_vpc.test_vpc]
}


resource "aws_subnet" "subnet_private_1" {
  tags = {
    "Name" = "subnet_private_1"
  }
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "10.0.2.0/24"
  depends_on = [aws_vpc.test_vpc]
}


#---------------------------------------------------------------

#creating route table and associations

resource "aws_route_table" "test_rt" {
  tags = {
    "Name" = "test_rt"
  }
    vpc_id = aws_vpc.test_vpc.id
    depends_on = [aws_vpc.test_vpc.id]
    
}


#associate subnet with routing table
resource "aws_route_table_association" "test_rt_asso" {

  route_table_id = aws_route_table.test_rt.id
  subnet_id = aws_subnet.subnet_public_1.id
  depends_on = [aws_subnet.subnet_public_1]

}


#---------------------------------------------------------------

#creating internet gateway and add default rt to igw

resource "aws_internet_gateway" "test_igw" {
  tags = {
    "Name" = "test_igw"
  }
  
  vpc_id = aws_vpc.test_vpc.id
  depends_on = [aws_vpc.test_vpc]

}


#add default rt to point to igw

resource "aws_route" "default_route" {

  route_table_id = aws_route_table.test_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.test_igw.id

}


#---------------------------------------------------------------

#creating security group


resource "aws_security_group" "test_sg" {
  tags = {
    "Name" = "test_sg"
  }
  
  Name = "test_sg"
  description = "allow traffic rule"
  vpc_id = aws_vpc.test_vpc.id

   ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }


depends_on = [aws_vpc.test_vpc.id]

}


#---------------------------------------------------------------
#***************************************************************
#---------------------------------------------------------------


#create rsa key for login to ec2 (not needed if we have aws gen pem file)

resource "tls_private_key" "web_key" {
  algorithm = "RSA"                            #creating private key
}

resource "aws_key_pair" "app_key" {            #saving public key from generated key
  key_name = tls_private_key.web_key.id           # pub key will go to ec2
  public_key = tls_private_key.web_key.public_key_openssh
}


resource "local_file" "web_key" {              #save the private key to local system
  content = tls_private_key.web_key.private_key_pem
  filename = "web_key.pem"
}


#---------------------------------------------------------------
#***************************************************************
#---------------------------------------------------------------


#creating instance in the vpc

resource "aws_instance" "test_ec2_" {

tags = {
  "Name" = "test_ec2_"
  "Owner" = "swapnil"
}
  ami = "ami-0cfedf42e63bba657"
  instance_type = "t2.micro"

  key_name = "web_key"

count = 1
subnet_id = aws_subnet.subnet_public_1.id
security_groups = [aws_security_group.test_sg.id]


provisioner "remote-exec" {

    connection {
      type = "ssh"
      user = "ec2-ubuntu"
      private_key = tls_private_key.web_key.public_key_pem
      host = "${aws_instance.test_ec2_[0].public_ip}"

      #host = self.test_ec2_[0].public_ip  # count=1
    }
inline = [
  "sudo yum update",
  "sudo yum install httpd php git -y",
  "sudo systemctl restart httpd",
  "sudo systemctl enable httpd"
]

  
}#provisioner

}#ec2


#---------------------------------------------------------------
#***************************************************************
#---------------------------------------------------------------

#creating redundant ebs and attach to ec2 {create, attach, format and mount}


resource "aws_ebs_volume" "test_ebs_1" {
  availability_zone = "${aws_instance.test_ec2_[0].availability_zone}"
  size = 1 #in gb

  tags = {
    "Name" = "test_ebs_vol"
  }
}


#attach redundant ebs to ec2

resource "aws_volume_attachment" "attach_ebs" {
  
  depends_on = [aws_ebs_volume.test_ebs_1]
  
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.test_ebs_1.id
  instance_id = "${aws_instance.test_ec2_[0].id}"
  force_detach = true

}

#Formate the ebs volm and Mount it on ec2
                                             #as there is no resource to do this, we need 
                                             #to create a null resource
resource "null_resource" "null_mount" {
    depends_on = [
      aws_volume_attachment.attach_ebs
    ]

    connection {                  #get connected to ec2
      type = "ssh"
      user = "ec2-ubuntu"
      private_key = tls_private_key.web_key.public_key_pem
      host = aws_instance.test_ec2_[0].public_ip

      #host = self.test_ec2_[0].public_ip  # count=1
    }

                                 # execute mouting commands on ec2
    provisioner "remote-exec" {
      inline = [
        "sudo mkfs.ext4 /dev/xvdh",
        "sudo mount /dev/xvdh /var/www/html",
        "sudo rm -rf /var/www/html/*",
        "sudo git clone ---- web address of git repo ----"   
      ]
    }

} #  null_1



#---------------------------------------------------------------
#***************************************************************
#---------------------------------------------------------------



# s3

# Creating s3 bucket to store static content of our appl

locals {
  s3_origin_id = "s3_origin"
}

resource "aws_s3_bucket" "test_s3_buck" {
  bucket = "mytestprojecttestbucket"
  acl = "public-read-write"

  region = "ap-south-1"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "mytestprojecttestbucket"
    Environment = " Test"
  }

    provisioner "local-exec" {
    command = "git clone -- url to static content --     local name (demo1.png)"
    }

}

# allow public access to s3 bucket

resource "aws_s3_bucket_public_access_block" "test_pub_storage" {
  
  depends_on = [aws_s3_bucket.test_s3_buck]

  bucket = "mytestprojecttestbucket"
  block_public_acls = false
  block_public_policy = false
  
}





#upload object to s3

resource "aws_s3_bucket_object" "object_1" {
  
   depends_on = [aws_s3_bucket.test_s3_buck]
   bucket = "mytestprojecttestbucket"

   acl = "public-read-write"
   key = "image _name _which is stored in git hub"
   source = "path of image in repo , not url , web/demo1.png"
   
}



#---------------------------------------------------------------
#***************************************************************
#---------------------------------------------------------------




# CREATE CLOUD FRONT DISTRUBUTION


resource "aws_cloudfront_distribution" "terra_cloudfront" {
  
  depends_on = [
    aws_s3_bucket_object.object_1
  ]


  origin {
    domain_name = aws_s3_bucket.test_s3_buck.bucket
    origin_id = local.s3_origin_id                        #local bolck
  }
  
  enabled = true

  
    default_cache_behavior {
        allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = local.s3_origin_id
  
   forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }

   }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400


  }


    restrictions {
        geo_restriction {
        restriction_type = "whitelist"
        locations        = ["US", "CA", "GB", "DE"]
        }
    }


    viewer_certificate {
        cloudfront_default_certificate = true
    }

}



#update the CDN image url to your website code

resource "null_resource" "write_image" {
  depends_on = [
    aws_cloudfront_distribution.terra_cloudfront
  ]

  connection {
     type = "ssh"
      user = "ec2-ubuntu"
      private_key = tls_private_key.web_key.public_key_pem
      host = aws_instance.test_ec2_[0].public_ip

      #host = self.test_ec2_[0].public_ip  # count=1
  }

  provisioner "remote-exec" {
    
    inline = [
      "sudo su << EOF",
              "echo \"<img src='http://${aws_cloudfront_distribution.terra_cloudfront.domain_name}/${aws_s3_bucket_object.object_1.key}' width='300', height='400'>\" >>/var/www/html/.index.html",
              "echo \"</body>\" >> /var/www/html/index.html",
              "echo \"</html>\" >> /var/www/html/index.html",
              "EOF",
    ]
  }
}


# success masaage and storing the result in file

resource "null_resource" "result" {
  depends_on = [
    null_resource.null_mount
  ]

  provisioner "local-exec" {
    command = "echo the web site have been deployed"
  }
}


#---------------------------------------------------------------
#***************************************************************
#---------------------------------------------------------------


#opening the web site at our local browser


resource "null_resource" "running_app" {
  depends_on = [
    null_resource.write_image
  ]

  provisioner "local-exec" {
    command = "start_chrome ${aws_instance.test_ec2_[0].public_ip}"
  }
}