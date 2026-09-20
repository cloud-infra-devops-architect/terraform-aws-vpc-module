output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "Primary CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "secondary_cidr_block" {
  description = "Secondary CIDR block (null if not created)"
  value       = module.vpc.secondary_cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "All private subnet IDs across all layers"
  value       = module.vpc.private_subnet_ids
}

output "private_subnet_ids_by_layer" {
  description = "Map of layer number → list of private subnet IDs"
  value       = module.vpc.private_subnet_ids_by_layer
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs (empty list if create_nat_gateway = false)"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "Elastic IPs assigned to NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = module.vpc.private_route_table_ids
}

output "flow_log_id" {
  description = "VPC Flow Log ID (null if enable_flow_logs = false)"
  value       = module.vpc.flow_log_id
}

output "flow_log_cloudwatch_log_group" {
  description = "CloudWatch Log Group name for flow logs (null if enable_flow_logs = false)"
  value       = module.vpc.flow_log_cloudwatch_log_group
}
