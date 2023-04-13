resource "aws_instance" "ec2_test" {
  ami           = var.my_ami
  instance_type = var.ec2_type
  key_name      = var.my_key


  tags = {
    "Name"  = "test_server_01"
    "Owner" = "swapnil"
  }


  depends_on = [
    aws_security_group.mysg1
  ]

  vpc_security_group_ids = ["${aws_security_group.mysg1.id}"]


  user_data = file("${path.module}/script.sh") # user provisioner instead



  #------------------------------------------------------------------------------------------


  provisioner "file" {
    source      = "./script.sh"    #from local machine
    destination = "/tmp/script.sh" # to ec2 instance

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "LAMP1"

    # host = "${aws_instance.ec2_test.public_ip}"   # it will create circular dependancy
      host = "${self.public_ip}" #solving , by asking resource to refer itself 
                                 # ' host = "${self.public_ip} ' 
    }

  }

  #instaed of "source file", we can directaly user "content" where we specify the content
 

 provisioner "file" {
    content =     " this is test data"
    destination = "/tmp/script.sh" 
    connection {
      type        = "ssh"                 # connection block can be made global
      user        = "ubuntu"              # by declaring this block above first provisioner block
      private_key = "LAMP1"
      host = "${self.public_ip}"  
    }

  }

  #-----------------------------------------------------------------------------------------------

  provisioner "local-exec" {
   command = "echo ${self.public_ip}"
 }

 provisioner "local-exec" {
   working_dir = "/temp"
   interpreter = [
     "/usr/bin/bash"
   ]
   command = "echo >> hi,swapnil"

   on_failure = fail
 }


   provisioner "local-exec" {
   command = "env >> env.txt "
   environment = {
     env_name = "env_name" 
    }

    on_failure = continue
 }

   provisioner "local-exec" {
   when = create                 # this will execute when any resource under this resource block is created.
   command = "echo 'at starting'"
 }

    provisioner "local-exec" {
   when = destroy               # this will execute when any resource under this resource block is deleted.
   command = "echo 'at destroy' "
 }



  #---------------------------------------------------------------------------------------------------

provisioner "remote-exec" {
  
 connection {
      type        = "ssh"                
      user        = "ubuntu"              
      private_key = "LAMP1"
      host = "${self.public_ip}"  
    }

  inline = [
    "ifconfig > /tmp/if.txt"   # give direct command in code
  ]
}


provisioner "remote-exec" {
  
  script = "./test_script.sh"       # give direct command in script file
  when = create

connection {
      type        = "ssh"                
      user        = "ubuntu"              
      private_key = "LAMP1"
      host = "${self.public_ip}"  
    }


}


} #resource ec2

