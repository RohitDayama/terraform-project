variable "instance_type" {}
variable "instance_name" {}
variable "cidr_block" {}
variable "vpc_name" {}
variable "igw_name" {}
variable "public_subnet_cidr" {}
variable "subnet_name" {}
variable "ami_image" {}
variable "public_subnet_cidr-2" {}
variable "subnet_name-1" {}
variable "av_1" {}
variable "av_2" {}
variable "map_public_ip_on_launch" {
  description = "It will map the public ip while launching resources"
  type        = bool
  default     = null
}
