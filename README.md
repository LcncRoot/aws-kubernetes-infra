# AWS Kubernetes Infrastructure

## **Project Overview**
This repository demonstrates a **fully automated, scalable Kubernetes infrastructure** deployed on AWS. It is designed as **practical cloud-native architecture**, serving as a template for future use cases, leveraging:

- **Terraform** for Infrastructure as Code (IaC)
- **AWS EKS** (Elastic Kubernetes Service) for cluster management
- **Helm** for Kubernetes package management
- **GitHub Actions** for CI/CD automation
- **Prometheus & Grafana** for monitoring (planned)
- **AI-powered Log Anomaly Detection** (future implementation)

This is not intended reductively as a local development playground—it is a intended as a production-ready cloud-native environment.

---
## **Current Project Status**
### ✅ **Completed**
✔ **Terraform-based AWS Infrastructure Provisioning**
   - VPC with public subnets
   - IAM roles and security policies
   - AWS EKS control plane successfully provisioned

✔ **EKS Cluster Deployment**
   - `terraform apply` successfully created an **ACTIVE** Kubernetes control plane

### ⚠ **In Progress**
🔸 **Fixing EKS Node Group Creation Issues**
   - Node instances are failing to join the cluster due to IAM and networking misconfigurations.
   - **Solution:** Ensure worker nodes have proper IAM permissions and a valid security group configuration.

### 🔜 **Next Steps**
🔹 **Verify Kubernetes Cluster is Fully Functional**
   - Deploy a simple pod or application to confirm cluster health.
   - Validate with `kubectl get nodes` and `kubectl get pods -A`.

🔹 **Implement CI/CD Pipelines**
   - Set up **GitHub Actions** for automatic deployments.

🔹 **Deploy AI-Powered Log Anomaly Detection**
   - Develop and containerize an ML-based anomaly detection service.
   - Integrate with Prometheus for log ingestion and alerting.

---
## **How to Set Up Locally**
1. **Clone the Repository**
   ```sh
   git clone https://github.com/LcncRoot/aws-kubernetes-infra.git
   cd aws-kubernetes-infra
   ```

2. **Install Required Tools**
   ```sh
   sudo apt install awscli terraform kubectl helm -y
   ```

3. **Authenticate AWS CLI**
   ```sh
   aws configure
   ```

4. **Deploy Infrastructure with Terraform**
   ```sh
   cd terraform
   terraform init
   terraform apply
   ```

5. **Deploy Kubernetes Apps via Helm** *(Once cluster is stable)*
   ```sh
   helm install my-app ./charts/my-app
   ```

---
## **Long-Term Vision**
This project is intended to serve as a **complete cloud-native DevOps environment**, with plans to:
✅ Integrate **AI-powered log anomaly detection** for proactive incident response.
✅ Automate CI/CD pipelines for **seamless Kubernetes deployments**.
✅ Implement **observability tooling** (Prometheus, Loki, Grafana).
✅ Showcase a **real-world production architecture**.

### **Why This Matters**
This project is not just about deploying a home Kubernetes cluster—it’s about demonstrating **true DevOps automation, scalability, and cloud-native best practices**. If you’re an employer reviewing this, you’ll find that I can design, build, and manage **highly available, production-ready infrastructure**.

---
### *Written by LcncRoot with AI assitance*

