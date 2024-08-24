#tofu configuration

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "backend_region" {
  description = "The region of the S3 bucket"
  type        = string
}

variable "remote_statefile_path" {
  description = "The path to the remote state file"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

#data blocks

variable "ami_owner" {
  description = "The owner of the AMI"
  type        = string
}

variable "ami_name" {
  description = "The name of the AMI"
  type        = string
}

variable "ami_virtualization_type" {
  description = "The virtualization type of the AMI"
  type        = string
}

variable "ami_architecture" {
  description = "The architecture of the AMI"
  type        = string
}

#vpc configuration

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "subnet_public_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
}

variable "subnet_private_a_cidr" {
  description = "The CIDR block for the private subnet A"
  type        = string
}

variable "subnet_private_b_cidr" {
  description = "The CIDR block for the private subnet B"
  type        = string
} 

variable "subnet_private_c_cidr" {
  description = "The CIDR block for the private subnet C"
  type        = string
} 

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
} 

variable "common_tags" {
  description = "The common tags for all resources"
  type        = map(string)
} 

variable "public_subnet_tags" {
  description = "The tags for the public subnet"
  type        = map(string)
} 

variable "private_subnet_tags" {
  description = "The tags for the private subnet"
  type        = map(string)
} 

#ec2 configuration

variable "instance_type" {
  description = "The instance type"
  type        = string
}

variable "bastion_role" {
  description = "The role of the bastion"
  type        = object({
    name = string
    color = string
  })
}

variable "bastion_key_name" {
  description = "The name of the bastion key pair"
  type        = string
}

variable "worker_role" {
  description = "The role of the worker"
  type        = object({
    name = string
    color = string
  })
}

variable "worker_key_name" {
  description = "The name of the worker key pair"
  type        = string 
}

variable "worker_1_ip" {
  description = "The public IP address of worker 1"
  type        = string
}

variable "worker_2_ip" {
  description = "The public IP address of worker 2"
  type        = string
}

variable "worker_3_ip" {
  description = "The public IP address of worker 3"
  type        = string
}