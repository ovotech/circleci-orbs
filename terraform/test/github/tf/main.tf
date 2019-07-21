resource "random_string" "my_string" {
  length = 4
}

variable "example" {
  default = ""
}
