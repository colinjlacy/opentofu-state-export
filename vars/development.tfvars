#tofu configuration
bucket_name="tofu-remote-state"
backend_region="us-west-2"
remote_statefile_path="tofu/terraform.tfstate"
aws_region="us-west-2"

#data blocks
ami_owner="Amazon"
ami_name="al2023-ami-*"
ami_virtualization_type="hvm"
ami_architecture="x86_64"

#vpc configuration
vpc_cidr="10.0.0.0/16"
subnet_public_cidr="10.0.0.0/18"
subnet_private_a_cidr="10.0.64.0/18"
subnet_private_b_cidr="10.0.128.0/18"
subnet_private_c_cidr="10.0.192.0/18"
vpc_name="tofu-vpc"
common_tags={
  "Owner"="hwa"
  "Environment"="development"
  "Site"="us-west-2_tofu-vpc"
}
public_subnet_tags={
  "Type"="public"
}
private_subnet_tags={
  "Type"="private"
}

#ec2 configuration
instance_type="t2.micro"
bastion_role={
  "name"="bastion"
  "color"="0000ff"
}
bastion_key_name="bastion"
worker_role={
  "name"="worker"
  "color"="00ff00"
}
worker_key_name="worker"
worker_1_ip="10.0.64.10"
worker_2_ip="10.0.128.10"
worker_3_ip="10.0.192.10"