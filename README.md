# AWS Kubernetes Infrastructure

## **Project Overview**
This repository demonstrates a fully automated, scalable Kubernetes infrastructure deployed on AWS. It is designed as practical cloud-native architecture serving as a template for future use cases, leveraging:

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
   - Set up GitHub Actions for automatic deployments.

🔹 **Deploy AI-Powered Log Anomaly Detection**
   - Develop and containerize an ML-based anomaly detection service.
   - Integrate with Prometheus for log ingestion and alerting.

---
## **How to set up locally**
1. **Clone the repository**
   ```sh
   git clone https://github.com/LcncRoot/aws-kubernetes-infra.git
   cd aws-kubernetes-infra
   ```

2. **Install required tools**
   ```sh
   sudo apt install awscli terraform kubectl helm -y
   ```

3. **Authenticate AWS CLI**
   ```sh
   aws configure
   ```

4. **Deploy infrastructure with Terraform**
   ```sh
   cd terraform
   terraform init
   terraform apply
   ```

5. **Deploy Kubernetes apps via Helm** *(Once cluster is stable)*
   ```sh
   helm install my-app ./charts/my-app
   ```



Below is a sample README in Markdown format that includes the instructions:

---

# Kubernetes Cluster Autoscaler Setup

Validate your Kubernetes cluster, set up Helm, deploy the Cluster Autoscaler, and simulate a load test to trigger autoscaling.

---

## 1. Cluster Validation

Ensure cluster is healthy and all system pods are running.

```bash
# List all nodes
kubectl get nodes

# List system pods in the kube-system namespace
kubectl get pods -n kube-system
```

---

## 2. Helm Setup

### Verify Helm Installation

Check that Helm is installed:

```bash
helm version
```

### Add and Update the Helm Repository for the Autoscaler

```bash
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update
```

---

## 3. Install Cluster Autoscaler

Deploy the Cluster Autoscaler into the `kube-system`, or whatever namespace youve created, using Helm. Replace the `awsRegion` and `autoDiscovery.clusterName` values as needed. 

```bash
helm install cluster-autoscaler autoscaler/cluster-autoscaler \
  --namespace kube-system \
  --set awsRegion=us-east-1 \
  --set autoDiscovery.clusterName=aws-kubernetes-cluster \
  --set cloudProvider=aws
```

### Verify Deployment

Check that autoscaler pod is running:

```bash
kubectl get pods -n kube-system
```

To view the logs (replace `<cluster-autoscaler-pod-name>` with the actual pod name):

```bash
kubectl logs -n kube-system <cluster-autoscaler-pod-name>
```

---

## 4. Simulation Test to Trigger Autoscaler

Create a test pod that simulates a resource load, potentially triggering the autoscaler to scale up the cluster.

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: resource-hog
spec:
  containers:
  - name: hog
    image: nginx
    resources:
      requests:
        cpu: "500m"
        memory: "512Mi"
      limits:
        cpu: "1000m"
        memory: "1024Mi"
EOF
```

### Observe the Scaling Behavior

- **Check for new nodes:**

  ```bash
  kubectl get nodes
  ```

- **Monitor autoscaler logs:**

  ```bash
  kubectl logs -n kube-system <cluster-autoscaler-pod-name>
  ```

### Clean Up

Remove the test pod when finished:

```bash
kubectl delete pod resource-hog
```

---
## Gitlab

**Why Deploy GitLab Within Our Kubernetes Cluster?**

https://www.reddit.com/r/kubernetes/comments/154n1la/should_i_run_gitlab_on_a_droplet_or_in_a_cluster/
https://www.reddit.com/r/devops/comments/nzi9mp/do_you_run_gitlab_inside_k8s_cluster_how_is_your/

I had a somewhat long internal debate deciding which way to go with this, but for "our" operation, which currently involves just myself and possibly a few other engineers, I have chosen to deploy GitLab directly within our existing Kubernetes cluster rather than creating separate infrastructure for it. Someone, incorrectly, will suggest that I shoudl have host it externally on separate infrastructure:

1. Unified Infrastructure:
Deploying GitLab in-cluster allows me to manage my CI/CD tooling alongside our production workloads in a single environment.

**2. Resource Efficiency:**
Given the modest scale of our operation, resource contention is not a significant concern. Our expected workload is light, meaning the existing cluster’s resources are more than sufficient to support GitLab without adversely affecting other applications. It would be **more** resource intensive at this juncture to deploy it elsewhere on separate infrastructure.

By avoiding the need to provision and manage a separate infrastructure for GitLab, we reduce complexity and associated costs. This allows us to focus our resources on enhancing our core applications and services.

4. Modern DevOps Practices:
Leveraging a container-native deployment aligns with best practices in modern DevOps and GitOps. It enables seamless scalability, easier management via Helm charts and Kubernetes manifests, and better overall consistency in our deployment processes.

In summary, deploying GitLab within our Kubernetes cluster is both a practical and strategic choice that supports our current scale and growth objectives, without incurring unnecessary overhead or resource conflicts.

Below is an example writeup you could include in your README. It explains the process you used to calculate costs and determine resource optimization when selecting the appropriate AWS instance types for a GitLab deployment:

---

### General Cost and Resource Optimization Analysis

This section will be updated as the project progresses. In my deployment planning for GitLab on AWS EKS, I performed a brief analysis to balance performance, resource availability, and cost:

1. **Assessing GitLab Resource Requirements:**
   - I reviewed the resource requests and usage from gitLab components (web service, Sidekiq, and auxiliary services).
   - For example, the GitLab web service was observed to request approximately 400 m CPU and around 2.6 GB of memory, while Sidekiq was using close to 900 m CPU and 2 GB of memory.

2. **Evaluating AWS Instance Options:**
   - **t3.medium:** Offers 2 vCPUs and 4 GB of memory at a lower cost (~\$0.0416/hour). However, the limited memory and CPU made it less ideal for a production GitLab environment with multiple resource-intensive services.
   - **t3.large:** Doubles the memory to 8 GB while keeping the same 2 vCPUs (~\$0.0832/hour). Although this improves memory capacity, the CPU remains limited, potentially causing bottlenecks under sustained load.
   - **m5.xlarge:** Provides 4 vCPUs and 16 GB of memory (~\$0.192/hour), offering significantly more resources. This instance type also offers non-burstable performance, which is crucial for a production workload that requires consistent performance.

3. **Cost Comparison and Final Decision:**
   - Using cost estimates for a 10-hour period:
     - **4 t3.large nodes:** Approximately \$3.33 for nodes + \$1 for the EKS control plane, totaling roughly \$4.33.
     - **2 m5.xlarge nodes:** Approximately \$0.192/hour each, yielding a combined cost of around \$0.384 per hour. For 10 hours, this is about \$3.84 for nodes plus the same \$1 for the control plane, totaling roughly \$4.84.
   - Although the total cost difference between the two configurations is marginal, the m5.xlarge nodes provide:
     - **Double the vCPUs (4 vs. 2)** for better handling of concurrent tasks.
     - **Significantly more memory (16 GB vs. 8 GB)**, which is critical given GitLab's higher memory usage.
     - **Non-burstable performance,** ensuring consistent and reliable operation even under sustained load.
   - Considering these factors, the decision was made to deploy GitLab on a cluster of **2 m5.xlarge nodes**. This configuration not only meets GitLab’s resource demands but also leaves ample headroom for running additional applications on the same cluster.

---


---
## **Long-term vision**
This project is intended to serve as a complete cloud-native DevOps environment, with plans to:
✅ Integrate AI-powered log anomaly detection for proactive incident response.
✅ Automate CI/CD pipelines for seamless Kubernetes deployments.
✅ Implement observability tooling (Prometheus, Loki, Grafana).
✅ Showcase a real-world production architecture.

### Why this matters
I have plans, grand plans, this servers as a template for clusters that I will service applciations on. Additionally, it’s about demonstrating production-ready DevOps automation, scalability, and cloud-native best practices. 

### Why a public repo?
In order to show my ongoing work. I simply don't care if my iterative processes is visible, and im pretty sure nothing sensitive is currently stored in git.


---
### *Written by LcncRoot with AI assitance*

