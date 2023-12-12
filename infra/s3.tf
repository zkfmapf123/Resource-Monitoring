resource "aws_s3_bucket" "fluentbit-logs" {
  bucket = "fluentbit-dk-logs"

  tags = {
    Name     = "fleuntbit-logs"
    Pipeline = "fluentbit"
  }
}
