# terraform-aws-web-stack

Pile web resiliente sur AWS : Application Load Balancer sur deux zones,
groupe d'auto-scaling depuis un Launch Template, deux Security Groups chaines.

Le module ne cree ni VPC ni subnets : il les recoit. Le reseau vient du module
public `terraform-aws-modules/vpc/aws`.

## Exemple

    module "web_stack" {
      source = "git::https://github.com/celestin-esgi/terraform-aws-web-stack.git?ref=v1.0.0"

      name                      = "novasphere-dev-cel"
      vpc_id                    = module.network.vpc_id
      subnet_ids                = module.network.public_subnets
      ami_id                    = data.aws_ami.debian.id
      instance_type             = "t3.micro"
      user_data_base64          = base64encode(file("bootstrap.sh"))
      iam_instance_profile_name = "LabInstanceProfile"
    }

## Modele de securite

Le Security Group des instances n'accepte le port 80 que depuis le Security
Group de l'ALB, par reference et non par plage d'adresses : les instances
etant remplacees en continu par l'auto-scaling, une regle par CIDR serait
invalide des le premier remplacement. Aucune regle n'expose les instances a
Internet, et le SSH direct n'existe pas : la configuration se fait au
demarrage. IMDSv2 est exige (`http_tokens = "required"`).

## Inputs principaux

| Nom | Obligatoire | Defaut |
|---|---|---|
| `name` | oui, 28 caracteres maximum | — |
| `vpc_id` | oui | — |
| `subnet_ids` | oui, deux minimum | — |
| `ami_id` | oui | — |
| `user_data_base64` | oui | — |
| `iam_instance_profile_name` | oui | — |
| `instance_type` | non | `t3.micro` |
| `min_size` / `max_size` / `desired_capacity` | non | 2 / 4 / 2 |
| `health_check_path` | non | `/` |

## Outputs

`alb_dns_name`, `alb_security_group_id`, `web_security_group_id`,
`target_group_arn`, `asg_name`.

## Renouvellement progressif

Un groupe d'auto-scaling lit le Launch Template au moment ou il cree une
instance, et seulement a ce moment. Changer le `user_data` ne modifie donc pas
les instances deja en service : elles garderaient leur configuration jusqu'au
prochain remplacement.

Le bloc `instance_refresh` corrige cela. Un changement de Launch Template
declenche un remplacement progressif : l'ASG retire une instance du target
group, la termine, attend que sa remplacante soit saine, puis traite la
suivante. `min_healthy_percentage` garantit la capacite maintenue pendant
l'operation, `instance_warmup` laisse a une nouvelle instance le temps
d'installer nginx et de passer le health check avant d'etre comptee comme
saine.

| Nom | Defaut |
|---|---|
| `min_healthy_percentage` | 50 |
| `instance_warmup` | 120 |
