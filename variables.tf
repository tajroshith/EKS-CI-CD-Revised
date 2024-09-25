variable "vpc_cidr" {
  type        = string
  description = "CIDR Block for VPC"
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable / Disable DNS Hostnames"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable / Disable DNS Service for VPC"
  default     = true
}

variable "public_subnet" {
  type        = list(string)
  description = "CIDR Block for Public Subnets"
  default     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
}

variable "private_subnet" {
  type        = list(string)
  description = "CIDR Block for Private Subnets"
  default     = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]
}

variable "common-tags" {
  type        = map(string)
  description = "Tags for resources"
  default = {
    "Team" = "DevOps"
  }
}

variable "project-name" {
  type        = string
  description = "Current project name"
  default     = "EKS"
}

variable "env" {
  type        = string
  description = "Project Environment"
  default     = "Dev"
}

variable "map_public_ip_on_launch_public" {
  type        = bool
  description = "Assign Public IP on Launch to Instances on Public Subnets"
  default     = true
}

variable "map_public_ip_on_launch_private" {
  type        = bool
  description = "Assign Public IP on Launch to Instances on Private Subnets"
  default     = true
}

variable "node_group_policies" {
  type        = set(string)
  description = "Set of Policies for the node group"
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}

variable "node_group_desired_size" {
  type    = number
  default = 5
}

variable "node_group_min_size" {
  type    = number
  default = 2
}

variable "node_group_max_size" {
  type    = number
  default = 2
}

variable "nodegroup_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_group_max_unavailable" {
  type = number
  default = 1
}