# Vpc 
module "vpc" {
  source = "./modules/vpc"

}
#s3-bucket
module "s3_bucket" {
  source = "./modules/s3"
}
#iam role for ec2
module "aws_iam_role" {
  source = "./modules/iamrole"
  
}
#Auto scaling group and launch template (and alb)
module "my_asg" {
  source = "./modules/asg"
  depends_on = [module.vpc, module.aws_iam_role]
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_profile_name =  module.aws_iam_role.instance_profile_name
}
#Route53 hosted zone for domain name
module "route53_hostedzone" {
  source = "./modules/route53"
  depends_on = [ module.cloudf]
  cloudfront_domain_name = module.cloudf.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.cloudf.cloudfront_hosted_zone_id
}
#ssl certificate for my domain name
module "certifi" {
  source = "./modules/acm"
  depends_on = [ module.route53_hostedzone ]
  route53_zone_id = module.route53_hostedzone.route53_zone_id
}
#cloudfront module 
module "cloudf" {
  depends_on = [ module.my_asg]
  source = "./modules/cloudfront"
  alb_dns_name= module.my_asg.alb_dns_name
}
