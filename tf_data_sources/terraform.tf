
#this file will contain all the config related to  terraform itself.data "

#specifying the terraform version

terraform {

  required_version = "1.1.8" # terraform's binary version

   required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.15.1"
    }
  }
 
   
}






# can not use variables in this file.
# this is very first block to get executed
# all values needed to be hard coded. 
