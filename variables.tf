variable "name" {
  description = "Prefixe de nommage, par exemple novasphere-dev-cel"
  type        = string

  validation {
    condition     = length(var.name) <= 28
    error_message = "name doit faire 28 caracteres au plus : un nom d'ALB est limite a 32."
  }
}

variable "vpc_id" {
  description = "VPC dans lequel deployer la pile"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets publics, un par zone de disponibilite"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Un ALB exige au moins deux subnets dans deux zones distinctes."
  }
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "user_data_base64" {
  description = "Script d'amorcage deja encode en base64"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Profil d'instance donnant acces a Parameter Store"
  type        = string
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "tags" {
  type    = map(string)
  default = {}
}
