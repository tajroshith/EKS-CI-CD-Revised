vpc_cidr = "172.24.0.0/16"
public_subnet = ["172.24.0.0/19", "172.24.32.0/19", "172.24.64.0/19"]
private_subnet = ["172.24.96.0/19", "172.24.128.0/19", "172.24.160.0/19"]
enable_dns_support = true
enable_dns_hostnames = true
common-tags = {
    "Env" = "Dev"
    "Team" = "DevOps"
}
project-name = "EKS"
env = "Dev"
nodegroup_instance_type = "t3.medium"
node_group_max_size = "5"
node_group_min_size = "2"
node_group_desired_size = "2"
node_group_max_unavailable = "1"
