/*
 * Confifure DNS and Domain Name Registration
 * Author: Andrew Jarombek
 * Date: 9/5/2018
 */

resource "aws_route53_zone" "jarombek" {
  name = "jarombek.com."
}

resource "aws_route53_record" "jarombek_ns" {
  name = "jarombek.com."
  type = "NS"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"
  ttl = 172800

  records = [
    "${aws_route53_zone.jarombek.name_servers.0}",
    "${aws_route53_zone.jarombek.name_servers.1}",
    "${aws_route53_zone.jarombek.name_servers.2}",
    "${aws_route53_zone.jarombek.name_servers.3}"
  ]
}

resource "aws_route53_record" "jarombek_a" {
  name = "jarombek.com."
  type = "A"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"
  ttl = 300

  records = ["${var.ip}"]
}

resource "aws_route53_record" "fn_jarombek_a" {
  name = "fn.jarombek.com."
  type = "A"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"

  # TTL for all alias records is 60 seconds
  alias {
    evaluate_target_health = false
    name = ""
    zone_id = ""
  }
}

resource "aws_route53_record" "asset_jarombek_a" {
  name = "asset.jarombek.com."
  type = "A"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"

  # TTL for all alias records is 60 seconds
  alias {
    evaluate_target_health = false
    name = ""
    zone_id = ""
  }
}

resource "aws_route53_record" "www_asset_jarombek_a" {
  name = "www.asset.jarombek.com."
  type = "A"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"

  # TTL for all alias records is 60 seconds
  alias {
    evaluate_target_health = false
    name = ""
    zone_id = ""
  }
}

resource "aws_route53_record" "jarombek_cname" {
  name = "www.jarombek.com."
  type = "CNAME"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"
  ttl = 300

  records = ["jarombek.com."]
}

resource "aws_route53_record" "jarombek_mx" {
  name = "jarombek.com."
  type = "MX"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"
  ttl = 300

  records = [
    "1 ASPMX.L.GOOGLE.COM.",
    "5 ALT1.ASPMX.L.GOOGLE.COM.",
    "5 ALT2.ASPMX.L.GOOGLE.COM.",
    "10 ALT3.ASPMX.L.GOOGLE.COM.",
    "10 ALT4.ASPMX.L.GOOGLE.COM."
  ]
}

resource "aws_route53_record" "jarombek_soa" {
  name = "jarombek.com."
  type = "SOA"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"
  ttl = 900

  records = ["ns-1626.awsdns-11.co.uk. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
}

resource "aws_route53_record" "fn_jarombek_txt" {
  name = "_acme-challenge.fn.jarombek.com."
  type = "TXT"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"
  ttl = 300

  records = ["xc0Vilgr6au429PaMEDwMRwiu7XvVHp3e5Ttf-CLzmM"]
}

resource "aws_route53_record" "jarombek_google_txt" {
  name = "jarombek.com."
  type = "TXT"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"
  ttl = 300

  records = ["google-site-verification=ZRGy5ArALIOLvjcIh-_P-io1-1uSKHtJyA9MxxAzyyE"]
}