variable "public-cidr-block" {
  default = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

variable "private-cidr-block" {
  default = ["10.10.4.0/24", "10.10.5.0/24", "10.10.6.0/24"]
}

variable "db-cidr-block" {
  default = ["10.10.7.0/24", "10.10.8.0/24", "10.10.9.0/24"]
}