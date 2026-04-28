# AWS Secure Three-Tier Infrastructure Challenge

## 🏗️ Architecture Overview & Technical Choices
This project implements a **Three-Tier Network Strategy** (Public, Private, and Isolated) to ensure maximum security and data integrity for the cloud environment.

* **Network Isolation:** A three-tier VPC design was chosen instead of a standard two-tier architecture to provide better isolation for core processing. The **Isolated Subnet** has no route to the internet, ensuring that sensitive data processing remains private and communicates only via AWS PrivateLinks.
* **Security-First API:** A **Private REST API Gateway** was implemented for internal communication. This allows the use of VPC Resource Policies, ensuring the Isolated Lambda is only triggered by internal requests, bypassing the public internet entirely.
* **Hardened Storage:** The S3 bucket is secured with AES256 encryption and a strict "Block Public Access" policy to prevent unauthorized data exposure.

## 🤖 AI Assistance & Human Oversight
AI tools were utilized to accelerate the development of Terraform modules and to review Security Group rules.

* **Technical Judgment:** Human oversight was critical to resolve provider version conflicts, ensuring full compatibility with **AWS Provider v6.x**. Additionally, `archive_file` blocks were implemented to generate Lambda artifacts dynamically. This approach ensures code portability, allowing the configuration to be initialized without external binary dependencies.

## 🚀 State Management & Backend Strategy
A clear separation was made between the **local evaluation environment** and the **production-ready configuration**:

* **Current Configuration:** The project uses a **Local Backend** to ensure that the evaluator can run `terraform init` and `terraform validate` immediately without requiring an existing S3 bucket or DynamoDB table.
* **Production Readiness:** A production-ready backend configuration (S3 for state storage and DynamoDB for state locking) is prepared in the `backend.tf.example` file. This setup is essential for team collaboration to prevent state corruption and ensure high availability of the infrastructure map.

## 🚀 Future Improvements (Next Steps)
Given more time to prepare this infrastructure for a production environment, the following enhancements would be prioritized:

1.  **Automated Infrastructure Pipelines:** Integration with CI/CD workflows to enable automated testing and deployment using short-lived credentials for enhanced security.
2.  **Advanced Observability:** Implementation of AWS X-Ray for distributed tracing and CloudWatch Alarms to monitor API traffic and execution errors in real-time.
3.  **High Availability Storage:** Configuring S3 Replication across multiple regions and enabling Cross-Region Load Balancing if required by business continuity plans.
4.  **Programmatic Security Validation:** Inclusion of automated testing suites (such as `terraform test`) to verify network isolation and security compliance before any resource is deployed.

## 🛠️ How to Run

1.  **Initialize:** 
    ```bash
    cd environments/${var.environment_type}/
    terraform init
    ```
2.  **Validate:** 
    ```bash
    terraform validate
    ```