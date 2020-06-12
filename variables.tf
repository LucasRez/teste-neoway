variable "region" {
   type        = string
   description = "Region where we will create our resources"
   default     = "us-east-1"
}

variable "public_key_path" {
  type        = string
  description = "Path to the ssh public key for the ec2 instances"
}

variable "cluster_name" {
  description = "The name to use to create the cluster and the resources. Only alphanumeric characters and dash allowed (e.g. 'my-cluster')"
  default     = "yawoen-ecs-cluster"
}

variable "instance_type" {
  default = "t2.micro"
}
