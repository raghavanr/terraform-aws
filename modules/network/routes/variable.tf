variable "route_table_id" {}

variable "destination_cidr_block" {}

variable "nat_gateway_route" {
  default = "false"
}

variable "nat_gateway_id" {}

variable "create_vpc" {}
