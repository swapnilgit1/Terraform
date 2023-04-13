my_key   = "LAMP1"
ec2_type = "t2.large"
my_ami   = "ami-0cfedf42e63bba657"



# for developer environment

# > terraform plan --var-file dev-terraform.tfvars 



# COMMANDS RELATED TO WORKSPACE

# > terraform workspace list
# > terraform workspace new <new workspace name> , IT ALSO SWITCHES TO NEW WORKSPACE
# > terraform workspace show
# > terraform workspace select <wksp name>     , to switch workspace
# > terraform workspace --help


# GO TO RESPECTIVE ENVIRONMENT AND THEN EXECUTE PALN/APPLY COMMAND



# this approch will not overwrite the tfstate file , it will maintain the
# seperate tfstate file for each workspace/ environment. 