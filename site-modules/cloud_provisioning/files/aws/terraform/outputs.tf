output "nodes_dns_name" {
  description = "The name of the instances provisioned"
  value       = aws_route53_record.dns_name.*.name
}