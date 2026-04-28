# AWS Secure Three-Tier Infrastructure Challenge

## 📌 Project Overview
This project implements a secure, scalable, and modular AWS architecture using Terraform. The design focuses on **strict network isolation** and the **Principle of Least Privilege (PoLP)** to protect sensitive data processing, as required in the technical assessment.

## 🏗️ Architecture Design

### 1. Networking (Three-Tier Strategy)
* **Public Subnet:** Hosts the NAT Gateway for controlled egress.
* **Private Subnet:** Hosts logic requiring internet access (e.g., external API integrations) via NAT.
* **Isolated Subnet:** A high-security zone with **no route to the internet**. Communication is strictly internal via VPC Endpoints, preventing data exfiltration.

### 2. Security & Compliance
* **Traffic Filtering:** * **WAFv2:** Protects the Public API Gateway against common web exploits.
    * **Resource Policy:** The Private API is restricted to VPC-only traffic using `aws:SourceVpc` conditions.
* **Data Protection:** The S3 bucket is provisioned with **AES256 Server-Side Encryption** and a complete **Public Access Block**.
* **Identity Isolation:** Lambdas use distinct IAM Roles. The Isolated Lambda is only permitted to perform `s3:PutObject` actions.

### 3. Connectivity (VPC Endpoints)
* **S3 Gateway Endpoint:** Provides high-performance, cost-effective access to storage without leaving the AWS backbone.
* **Interface Endpoint (Execute-API):** Enables the Isolated Lambda to securely invoke the Private API Gateway without internet traversal.

## 🚀 DevOps Best Practices
* **Modularization:** Decoupled modules for Network, Security, Storage, API, and Compute to ensure reusability.
* **Standardized Tagging:** Centralized tagging via Terraform `locals` for cost allocation and environment governance (`EnvironmentType`, `EnvironmentName`).
* **Dependency Management:** The `.terraform.lock.hcl` is included to guarantee idempotent and secure provider versions across environments.
* **Infrastructure as Code (IaC):** 100% automated provisioning with strictly defined inputs and outputs.

## 🛠️ How to Deploy

1.  **Initialize:** ```bash
    cd environments/production/
    terraform init
    ```
2.  **Validate & Lint:**
    ```bash
    terraform validate
    terraform fmt -recursive ../../
    ```
3.  **Deploy:**
    ```bash
    terraform plan
    terraform apply
    ```

---
**Note:** The application code for Lambdas uses a placeholder (`dummy_lambda.zip`) to separate infrastructure provisioning from application deployment pipelines.