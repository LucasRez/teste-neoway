resource "aws_key_pair" "yawoen_key_pair" {
  key_name = "yawoenkey"
  public_key = file(var.public_key_path)
}