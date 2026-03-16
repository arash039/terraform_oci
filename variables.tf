variable "oci_region" {
  description = "The OCI region to deploy resources in."
  default     = "exampleorigin"
}

variable "instance_shape" {
  description = "The shape of the instance to deploy."
  default     = "exampleshape"
}

variable "compartment_id" {
  description = "The OCI compartment ID where resources will be created."
  default = "examplecompartmentid"
}

# Add variables for secrets
variable "db_user" {
  description = "The database username."
  default     = "exampleuser"
}

variable "db_password" {
  description = "The database password."
  default     = "examplepass"
}

variable "db_name" {
  description = "The database name."
  default     = "exampledb"
}

variable "db_root_password" {
  description = "The root password for the database."
  default     = "examplepass"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file."
  type        = string
}