resource "aws_iam_role" "cluster_role" {
  name               = "${var.project-name}-${var.env}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cluster-role-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_iam_role" "worker_role" {
  name               = "${var.project-name}-${var.env}-worker-role"
  assume_role_policy = data.aws_iam_policy_document.worker_assume_role.json
}

resource "aws_iam_role_policy_attachment" "worker-role-attachment" {
  for_each   = var.node_group_policies
  policy_arn = each.value
  role       = aws_iam_role.worker_role.name
}

resource "aws_eks_cluster" "wp-eks-cluster" {
  name     = "${var.project-name}-${var.env}-wp-cluster"
  role_arn = aws_iam_role.cluster_role.arn
  version  = "1.30"
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = flatten([aws_subnet.wp-public-subnet[*].id, aws_subnet.wp-private-subnet[*].id])
  }
  tags = merge(var.common-tags, {
    "Name" = "${var.project-name}-${var.env}-wp-cluster"
  })
  depends_on = [aws_iam_role_policy_attachment.cluster-role-attachment]
}

resource "aws_eks_node_group" "wp-eks-node-group" {
  cluster_name    = aws_eks_cluster.wp-eks-cluster.name
  node_group_name = "${var.project-name}-${var.env}-node-group"
  node_role_arn   = aws_iam_role.worker_role.arn
  subnet_ids      = aws_subnet.wp-private-subnet[*].id
  scaling_config {
    desired_size = var.node_group_desired_size
    min_size     = var.node_group_min_size
    max_size     = var.node_group_max_size
  }

  update_config {
    max_unavailable = var.node_group_max_unavailable
  }
  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  instance_types = [var.nodegroup_instance_type]
  disk_size      = 20
  depends_on     = [aws_iam_role_policy_attachment.worker-role-attachment]
  tags = merge(var.common-tags, {
    "Name" = "${var.project-name}-${var.env}-wp-node-group"
  })
}