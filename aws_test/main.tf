module "aws_network" {
  source = "./modules/aws_network"

  cluster_name = var.cluster_name
}

module "aws_ecr" {
  source = "./modules/aws_ecr"

  vpc_id     = module.aws_network.vpc_id
  subnet_ids = module.aws_network.private_sn_ids
  sg_egress  = var.sg_egress

  depends_on = [module.aws_network]
}

module "aws_eks" {
  source = "./modules/aws_eks"

  access_key         = var.access_key
  secret_key         = var.secret_key
  cluster_name       = var.cluster_name
  vpc_id             = module.aws_network.vpc_id
  public_sn_ids      = module.aws_network.public_sn_ids
  private_sn_ids     = module.aws_network.private_sn_ids
  namespace          = var.kube_system_namespace
  sg_egress          = var.sg_egress
  template_file_path = var.template_file_path

  depends_on = [module.aws_network]
}

module "ingress_cotroller" {
  source = "./modules/aws_load_balancer"

  cluster_name                 = module.aws_eks.eks_cluster_name
  cluster_identity_oidc_issuer = module.aws_eks.eks_cluster_identity_oidc_issuer
  vpc_id                       = module.aws_network.vpc_id
  namespace                    = var.kube_system_namespace

  depends_on = [module.aws_eks]
}

module "external_dns" {
  source = "./modules/aws_route53"

  cluster_name                 = module.aws_eks.eks_cluster_name
  cluster_identity_oidc_issuer = module.aws_eks.eks_cluster_identity_oidc_issuer
  namespace                    = var.kube_system_namespace

  depends_on = [module.aws_eks]
}

module "ebs_csi_driver" {
  source = "./modules/aws_ebs_csi_driver"

  cluster_id                   = module.aws_eks.eks_cluster_id
  cluster_name                 = module.aws_eks.eks_cluster_name
  cluster_identity_oidc_issuer = module.aws_eks.eks_cluster_identity_oidc_issuer
  namespace                    = var.kube_system_namespace

  depends_on = [module.aws_eks]
}

module "argo_cd" {
  source = "./modules/argo_cd"

  depends_on = [ module.ingress_cotroller, module.external_dns, module.ebs_csi_driver ]
}
