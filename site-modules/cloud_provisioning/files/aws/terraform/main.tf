provider "aws" {
  shared_credentials_files = var.credentials
  profile                  = var.profile
  region                   = var.region
}


data "aws_ami" "search" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  name_regex = lookup(var.amis_os_map_regex, var.os)
  owners     = [length(var.amis_primary_owners) == 0 ? lookup(var.amis_os_map_owners, var.os) : var.amis_primary_owners]
}


locals {
  common_tags = {
      "created_by"   = "Jerome Fontanel"
      "cost_center"  = "44001"
      "organization" = "tse"
      "environment"  = "testing"
      "Terraform"    = "True"
      "lifetime"     = "10d"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "${var.name}-key"
  public_key = file("${path.module}/../${var.pub_key}")

  tags       = merge(
    local.common_tags,
    {
    "Name"  = "${var.name}-key_pair"
    },
  )
}

resource "aws_instance" "server" {
  count                       = var.machines_count != 0 ? var.machines_count : 0
  ami                         = data.aws_ami.search.image_id
  instance_type               = lookup(var.map_instance_type, var.instance_type)
  key_name                    = aws_key_pair.ssh-key.key_name
  get_password_data           = substr(var.os,0,7)=="windows" ? true : false                   
  subnet_id                   = element(aws_subnet.core-subnet.*.id, count.index)
  vpc_security_group_ids      = [aws_security_group.core-securitygroup.id]
  associate_public_ip_address = true
  user_data                   = substr(var.os,0,7)=="windows" ? templatefile("${path.module}/templates/init-win.tftpl", {
      primary_ip        = var.primary_ip,
      primary_name      = var.primary_name,
      agent_name        = "${var.name}${count.index}",
      dns_domain        = var.domain
      role              = var.role
      challengepassword = var.challengepassword
    }
    ) : templatefile("${path.module}/templates/init-lnx.tftpl",{
      primary_ip        = var.primary_ip,
      primary_name      = var.primary_name,
      agent_name        = "${var.name}${count.index}",
      dns_domain        = var.domain
      role              = var.role
      challengepassword = var.challengepassword
      })
  
  tags                        = merge(
    local.common_tags,
    {
    "Name"  = "${var.name}${count.index}.${var.domain}"
    "cname" = "${var.name}${count.index}.${var.domain}"
    },
  )
  lifecycle {
    ignore_changes = [
      source_dest_check,
      ami,
      user_data,
      vpc_security_group_ids,
    ]
  }
}

resource "aws_route53_record" "dns_name" {
  zone_id = "Z007471117JSU6DZ6EUGO"
  count   = var.machines_count
  name    = "${var.name}${count.index}.${var.domain}"
  type    = "A"
  ttl     = "5"
  records = [aws_instance.server[count.index].public_ip]

  lifecycle {
    ignore_changes = all
  } 
}

