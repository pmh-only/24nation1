module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-eks-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = false

  vpc_id                   = module.vpc_prod.vpc_id
  subnet_ids               = module.vpc_prod.private_subnets
  control_plane_subnet_ids = module.vpc_prod.intra_subnets

  node_security_group_tags = {
    "karpenter.sh/discovery" = "${var.project_name}-eks-cluster"
  }
  

  eks_managed_node_groups = {
    project-db-application-ng = {
      name = "${var.project_name}-db-application-ng"
      iam_role_name="${var.project_name}-db-application-ng"
      iam_role_use_name_prefix=false
      use_name_prefix=false
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.medium"]
      labels = {
        app = "db"
      }

      taints = {
        dedicated = {
          key    = "app"
          value  = "db"
          effect = "NO_SCHEDULE"
        }
      }

      min_size     = 2
      max_size     = 27
      desired_size = 2
    }

    project-other-ng = {
      name = "${var.project_name}-other-ng"
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.medium"]
      use_name_prefix=false
      labels = {
        app = "other"
      }

      min_size     = 2
      max_size     = 27
      desired_size = 2
    }
  }

  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    example = {
      kubernetes_groups = []
      principal_arn = aws_iam_role.bastion.arn

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    }
    # karpenter = {
    #   principal_arn = "arn:aws:iam::${data.aws_caller_identity.caller.account_id}:role/karpenter-project-cluster-20240827024307095000000001"
    #   type = "EC2_LINUX"
    # }
  }
}
