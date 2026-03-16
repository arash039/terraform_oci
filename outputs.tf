output "instance_id" {
  description = "The ID of the WordPress instance."
  value       = oci_core_instance.wordpress.id
}

output "public_ip" {
  description = "The public IP address of the WordPress instance."
  value       = oci_core_instance.wordpress.public_ip
}

output "instance_display_name" {
  description = "The display name of the WordPress instance."
  value       = oci_core_instance.wordpress.display_name
}