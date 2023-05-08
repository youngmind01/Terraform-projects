variable "subnet_prefix" {
  description = "List of subnet prefixes"
  type = list(string)
  default = [ "10.0.1.0/24", "10.0.2.0/24" ]
}