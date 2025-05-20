# Route 53 DNS record for the Jitsi Meet server
resource "aws_route53_record" "jitsi_dns" {
  zone_id = var.hosted_zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.jitsi_eip.public_ip]
}
