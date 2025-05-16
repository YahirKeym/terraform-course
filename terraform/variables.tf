variable "aws_region" {
    type = string
    default = "us-east-1"
}

variable "project_name" {
    type = string
    default = "nestjs-app"
}

variable "ami_id" {
    type = string
    default = "ami-0953476d60561c955"
}

variable "key_name" {
    type = string
    default = "test-fvm"
}

variable "repository_url" {
    type = string
    default = "https://github.com/YahirKeym/terraform-course.git"
}
    