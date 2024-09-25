module "vpc_ma" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-ma-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  public_subnets  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets = ["10.0.20.0/24", "10.0.21.0/24"]

  public_subnet_names = ["${var.project_name}-ma-mgmt-sn-a", "${var.project_name}-ma-mgmt-sn-b"]
  private_subnet_names = ["${var.project_name}-ma-tgw-sn-a", "${var.project_name}-ma-tgw-sn-b"]

  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = false
}

module "vpc_prod" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-prod-vpc"
  cidr = "172.16.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  public_subnets  = ["172.16.0.0/24", "172.16.1.0/24"]
  private_subnets = ["172.16.2.0/24", "172.16.3.0/24"]
  intra_subnets = ["172.16.20.0/24", "172.16.21.0/24"]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "karpenter.sh/discovery" = "${var.project_name}-eks-cluster"
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_names = ["${var.project_name}-prod-load-sn-a", "${var.project_name}-prod-load-sn-b"]
  private_subnet_names = ["${var.project_name}-prod-app-sn-a", "${var.project_name}-prod-app-sn-b"]
  intra_subnet_names = ["${var.project_name}-prod-tgw-sn-a", "${var.project_name}-prod-tgw-sn-b"]

  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = true

  one_nat_gateway_per_az = true
}

module "vpc_storage" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-storage-vpc"
  cidr = "192.168.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["192.168.0.0/24", "192.168.1.0/24"]
  intra_subnets = ["192.168.20.0/24", "192.168.21.0/24"]


  private_subnet_names = ["${var.project_name}-storage-db-sn-a", "${var.project_name}-storage-db-sn-b"]
  intra_subnet_names = ["${var.project_name}-storage-tgw-sn-a", "${var.project_name}-storage-tgw-sn-b"]

  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = false
}
