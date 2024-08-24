# bastion

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  tags = merge(var.common_tags, { Name = format("%s Bastion EIP", var.vpc_name) })
}

resource "tls_private_key" "bastion_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_key" {
  key_name   = var.bastion_key_name
  public_key = tls_private_key.bastion_private_key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.bastion_private_key.private_key_pem}' > ./keys/${var.bastion_key_name}.pem"
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  ebs_optimized          = false
  hibernation            = false
  instance_type          = var.instance_type
  key_name               = aws_key_pair.bastion_key.key_name
  monitoring             = true
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public.id, aws_vpc.main.default_security_group_id]
  tags                   = merge(var.common_tags, { Name = format("%s Bastion", var.vpc_name), DeviceRoleName = var.bastion_role.name, DeviceRoleColor = var.bastion_role.color })
}

# workers

resource "tls_private_key" "worker_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "worker_key" {
  key_name   = var.worker_key_name
  public_key = tls_private_key.worker_private_key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.worker_private_key.private_key_pem}' > ./keys/${var.worker_key_name}.pem"
  }
}

resource "aws_instance" "worker_1" {
  ami                    = data.aws_ami.amazon_linux.id
  ebs_optimized          = false
  hibernation            = false
  instance_type          = var.instance_type
  key_name               = aws_key_pair.worker_key.key_name
  monitoring             = true
  subnet_id              = aws_subnet.private_a.id
  private_ip = var.worker_1_ip
  vpc_security_group_ids = [aws_vpc.main.default_security_group_id]
  tags                   = merge(var.common_tags, { Name = format("%s Worker 1", var.vpc_name), DeviceRoleName = var.worker_role.name, DeviceRoleColor = var.worker_role.color })
}

resource "aws_instance" "worker_2" {
  ami                    = data.aws_ami.amazon_linux.id
  ebs_optimized          = false
  hibernation            = false
  instance_type          = var.instance_type
  key_name               = aws_key_pair.worker_key.key_name
  monitoring             = true
  subnet_id              = aws_subnet.private_b.id
  private_ip = var.worker_2_ip
  vpc_security_group_ids = [aws_vpc.main.default_security_group_id]
  tags                   = merge(var.common_tags, { Name = format("%s Worker 2", var.vpc_name), DeviceRoleName = var.worker_role.name, DeviceRoleColor = var.worker_role.color })
}

resource "aws_instance" "worker_3" {
  ami                    = data.aws_ami.amazon_linux.id
  ebs_optimized          = false
  hibernation            = false
  instance_type          = var.instance_type
  key_name               = aws_key_pair.worker_key.key_name
  monitoring             = true
  subnet_id              = aws_subnet.private_c.id
  private_ip = var.worker_3_ip
  vpc_security_group_ids = [aws_vpc.main.default_security_group_id]
  tags                   = merge(var.common_tags, { Name = format("%s Worker 3", var.vpc_name), DeviceRoleName = var.worker_role.name, DeviceRoleColor = var.worker_role.color })
}
