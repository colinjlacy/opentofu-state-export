data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = [lower(var.ami_owner)]
  
  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami_virtualization_type]
  }

  filter {
    name   = "architecture"
    values = [var.ami_architecture]
  }
}