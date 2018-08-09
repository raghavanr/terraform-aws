provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

module "core-network-vpc" {
  # Configure AWS VPC
  source     = "modules/network/vpc/"
  name = "core-network-vpc"
  cidr_block = "${var.cidr}"
  env          = "${var.env}"
  create_vpc = "${var.create_vpc}"
}

module "core-network-dhcp" {
  # Configure DHCP Option set
  source = "modules/network/dhcp/"
  name = "core-network-dhcp"
  env          = "${var.env}"
  vpc_id = "${module.core-network-vpc.id}"
  create_vpc = "${var.create_vpc}"
  enable_dhcp_options = "${var.enable_dhcp_options}"
}

module "public-frontend-subnet" {
  # Configure public subnet 
  source = "modules/network/subnet/"
  name = "core-network-vpc-publicsubnet"
  vpc_id = "${module.core-network-vpc.id}"
  cidr_block = "${var.public-frontend-subnet}"
  create_vpc = "${var.create_vpc}"
  env = "${var.env}"
}

module "private-app-subnet" {
  # Configure public subnet 
  source = "modules/network/subnet/"
  name = "core-network-vpc-app-privatesubnet"
  vpc_id = "${module.core-network-vpc.id}"
  cidr_block = "${var.private-app-subnet}"
  create_vpc = "${var.create_vpc}"
  env = "${var.env}"
}

module "private-db-subnet" {
  # Configure public subnet 
  source = "modules/network/subnet/"
  name = "core-network-vpc-db-privatesubnet"
  vpc_id = "${module.core-network-vpc.id}"
  cidr_block = "${var.private-db-subnet}"
  create_vpc = "${var.create_vpc}"
  env = "${var.env}"
}

module "public-route-table" {
  # Configure Public Route Table
  source = "modules/network/routetable/"
  name = "core-network-frontend-routetable"
  vpc_id = "${module.core-network-vpc.id}"
  env = "${var.env}"
  type = "public" # public or private
  create_vpc = "${var.create_vpc}"
  subnet_id = "${module.public-frontend-subnet.subnetid}"
}

module "app-private-route-table" {
  source = "modules/network/routetable/"
  name = "core-network-app-routetable"
  vpc_id = "${module.core-network-vpc.id}"
  env = "${var.env}"
  type = "app-private"
  create_vpc = "${var.create_vpc}"
  subnet_id = "${module.private-app-subnet.subnetid}"
}

module "db-private-route-table" {
  source = "modules/network/routetable/"
  name = "core-network-db-routetable"
  vpc_id = "${module.core-network-vpc.id}"
  env = "${var.env}"
  type = "db-private"
  create_vpc = "${var.create_vpc}"
  subnet_id = "${module.private-db-subnet.subnetid}"
}

module "igw" {
  # Configure IGW
  source = "modules/network/igw/"
  vpc_id = "${module.core-network-vpc.id}"
  env = "${var.env}"
  create_vpc = "${var.create_vpc}"
  route_table_id = "${module.public-route-table.rtid}"
  destination_cidr_block = "0.0.0.0/0"
}

module "ngw" {
  source = "modules/network/ngw/"
  internet_gateway = "${module.igw.igwid}"
  env = "${var.env}"
  create_vpc = "${var.create_vpc}"
  subnet_id = "${module.public-frontend-subnet.subnetid}"
  route_table_id = ["${module.app-private-route-table.rtid}", "${module.db-private-route-table.rtid}"]
}

/*module "common-route" {
  source = "modules/network/routes/"
  route_table_id = "${module.public-route-table.rtid}"
  destination_cidr_block = "0.0.0.0/0"
}*/