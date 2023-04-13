variable "username" {
    type=string
}
variable "age" {
    type=number
}

output "u_name" {
  value = "Hello,  ${var.username}"
}
output "u_age" {
  value = "your age,  ${var.age}"
}
