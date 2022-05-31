variable "filetemp" {
  type = string
}
# variable "inbound_port_ranges" {
#   type    = list(string)
# }

# variable "db_name" {
#   type = string
# }

# variable "db_username" {
#   type = string
# }

# variable "db_password" {
#   sensitive = true
#   type      = string
# }

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  sensitive = true
  type      = string
}