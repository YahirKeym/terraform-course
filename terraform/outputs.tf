output "instance_public_ip" {
    value = aws_instance.app.public_ip
    description = "The public IP address of the instance"
}

output "application_url" {
    value = "http://${aws_instance.app.public_ip}:3000"
    description = "The URL of the application"
}