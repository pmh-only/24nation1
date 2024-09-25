resource "aws_iam_policy" "externalsecrets" {
  name = "project-policy-externalsecrets"
  policy = data.aws_iam_policy_document.externalsecrets.json  
}

data "aws_iam_policy_document" "externalsecrets" {
  statement {
    actions = [
      "secretsmanager:*",
      "kms:*"
    ]

    resources = ["*"]
  }
}

module "irsa" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${var.project_name}-role-externalsecrets"

  role_policy_arns = {
    policy = aws_iam_policy.externalsecrets.arn
  }

  oidc_providers = {
    cluster-oidc-provider = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "wsc2024:externalsecrets"
      ]
    }
  }
}

# resource "aws_iam_policy" "prometheus" {
#   name = "project-policy-prometheus"
#   policy = data.aws_iam_policy_document.prometheus.json  
# }

# data "aws_iam_policy_document" "prometheus" {
#   statement {
#     actions = [
#       "aps:RemoteWrite", 
#       "aps:GetSeries", 
#       "aps:GetLabels",
#       "aps:GetMetricMetadata"
#     ]

#     resources = ["*"]
#   }
# }

# module "irsa2" {
#   source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   role_name = "${var.project_name}-role-prometheus"

#   role_policy_arns = {
#     policy = aws_iam_policy.prometheus.arn
#   }

#   oidc_providers = {
#     cluster-oidc-provider = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = [
#         "opentelemetry-operator-system:adot-col-prom-metrics",
#         "prometheus:amp-iamproxy-ingest-service-account"
#       ]
#     }
#   }
# }
