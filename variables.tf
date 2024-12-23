variable "region" {
  default = "ap-south-1"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "ami_id" {
  description = "Ubuntu Server 24.04 LTS"
  default     = "ami-053b12d3152c0cc71"
}
variable "domain_name" {
  description = "Domain name for Route 53"
  default     = "saamadev.com"
}
variable "subnets" {
  type        = list(string)
  description = "Public subnets"
}
