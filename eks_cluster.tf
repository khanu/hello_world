# VPC
resource "aws_vpc" "eks_vpc" {
    cidr_block = "10.0.0.0/16"
}



# Subnets 
resource "aws_subnet" "eks_subnet" {
  count = 2

  cidr_block              = "10.0.${count.index}.0/24"
  vpc_id                  = aws_vpc.eks_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = "${var.zones[count.index]}"
  tags = {
	Name = "subnet${count.index+1}"
  }
}



# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
}



# Route Table
resource "aws_route_table" "eks_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}



# Route table attachment
resource "aws_route_table_association" "eks_route_table_assoc" {
  count = 2

  subnet_id      = aws_subnet.eks_subnet.*.id[count.index]
  route_table_id = aws_route_table.eks_route_table.id
}




# IAM Role for k8s clusters to call other AWS services
resource "aws_iam_role" "eks_cluster_role" {
    name = "eks_cluster_role"
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}



# IAM Policy Attachment resource which attaches a managed AWS policy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_role_EKSClusterPolicy_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = "${aws_iam_role.eks_cluster_role.name}"

}
resource "aws_iam_role_policy_attachment" "eks_cluster_role_KSVPCResourceController_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    role = "${aws_iam_role.eks_cluster_role.name}"

}

# Security Group
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks_cluster_sg"
  vpc_id      = aws_vpc.eks_vpc.id

# Egress allows Outbound traffic from the EKS cluster to the  Internet 

  egress {                   # Outbound Rule
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Ingress allows Inbound traffic to EKS cluster from the  Internet 

  ingress {                  # Inbound Rule
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_eks_cluster" "helloworld_cluster" {
    name = "helloworld_cluster"
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
        subnet_ids = aws_subnet.eks_subnet.*.id
    }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
    depends_on = [
        aws_iam_role_policy_attachment.eks_cluster_role_EKSClusterPolicy_attachment,
        aws_iam_role_policy_attachment.eks_cluster_role_KSVPCResourceController_attachment,
    ]
}

output "endpoint" {
  value = aws_eks_cluster.helloworld_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.helloworld_cluster.certificate_authority[0].data
    
}