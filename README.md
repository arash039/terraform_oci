# WordPress Deployment on Oracle Cloud Infrastructure (OCI)

This project provides an automated solution to deploy a WordPress site on Oracle Cloud Infrastructure (OCI). Using Terraform and Docker, it sets up WordPress, MySQL, and Caddy to deliver a fully functional and scalable website.

---

### Prerequisites
1. Oracle Cloud account.
2. Terraform installed locally.
3. SSH key pair for instance access.

### Start
1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd terraform_oci
   ```
2. Update the `variables.tf` file with your OCI details.
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Deploy the resources:
   ```bash
   terraform apply
   ```
5. Access your WordPress site at:
   ```
   http://<instance_public_ip>:8080
   ```

