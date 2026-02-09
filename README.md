# 🧰 Multi-Cloud Platform Engineering Lab

This repository is a production-grade multi-cloud platform engineering lab built with Terraform and Terragrunt and App-of-Apps. It demonstrates Infrastructure-as-Code (DRY Terragrunt), GitOps bootstrapping with ArgoCD, zero-trust keyless authentication (OIDC / Workload Identity), observability, and a sample Agentic Analyzer workload running on GKE with Vertex AI.

---

## 🔎 Project Overview

- Goal: Provide a repeatable, DRY infrastructure layout that uses AWS as the state/management plane and GCP as the data plane (GKE / Vertex AI).
- Scope: Remote state (S3 + DynamoDB locks), VPC, GKE clusters, node pools, Artifact Registry, IAM/Workload Identity, and bootstrap apps (ArgoCD, Vault, Prometheus, Kyverno).
- Design pillars: Security (OIDC / Workload Identity), Maintainability (Terragrunt hierarchy and `_envcommon`), Observability (Prometheus & Grafana), and Cost-awareness (Free-tier / FinOps considerations).

#### Tools: `AWS`,`GCP`, `Terraform`, `GitHub Actions`, `Docker`, `Kubernetes`, `Prometeus`, `Grafana`, `ArgoCD`.

<div align="center"> 

  ![My Skills](https://go-skill-icons.vercel.app/api/icons?i=aws,gcp,kubernetes,terraform,argocd,prometheus,grafana,git,fastapi,python,helm)
  
</div> <br>


---

## 📁 Repository Structure

```
Multi-Cloud-Platform/
.
├── README.md
├── _envcommon
│   ├── argocd.hcl
│   ├── cloud-run.hcl
│   ├── gke-nodepool.hcl
│   ├── gke.hcl
│   └── network.hcl
├── account.hcl
├── aws
│   ├── account.hcl
│   └── global
│       └── tf-state
├── env.hcl
├── gcp
│   ├── account.hcl
│   └── dev
│       ├── apps-bootstrap
│       │   ├── argocd
│       │   │   ├── main.tf
│       │   │   ├── terragrunt.hcl
│       │   │   └── variables.tf
│       │   └── rbac-setup
│       │       ├── main.tf
│       │       ├── terragrunt.hcl
│       │       └── variables.tf
│       ├── artifact-registry
│       │   ├── main.tf
│       │   ├── terragrunt.hcl
│       │   └── variables.tf
│       ├── env.hcl
│       ├── gke
│       │   ├── cluster
│       │   │   └── terragrunt.hcl
│       │   └── node-pools
│       │       └── terragrunt.hcl
│       ├── iam-roles
│       │   └── terragrunt.hcl
│       └── vpc
│           └── terragrunt.hcl
└── root.hcl
```

---

## ⚙️ Tech Stack

| Area | Technology |
|---|---|
| IaC | Terraform + Terragrunt |
| CI/CD | GitHub Actions (OIDC) / optional Atlantis |
| Cloud | AWS (S3, DynamoDB) for state; GCP (GKE, Artifact Registry, Vertex AI) for compute |
| GitOps | ArgoCD (App-of-Apps) |
| Secrets | HashiCorp Vault (sidecar injection) |
| Policy | Kyverno |
| Observability | Prometheus + Grafana |
| Security Scanning | Trivy, TFLint, Infracost |

---

## 🧠 System Architecture

- Control plane: AWS S3 for Terraform state + DynamoDB for locks. GitHub Actions uses OIDC to assume roles — no long-lived keys in GitHub.
- Data plane: GKE clusters in GCP where workloads run (Agentic Analyzer). Workload Identity binds Kubernetes service accounts to GCP IAM roles.
- Bootstrap flow: Terragrunt provisions network → cluster → node-pools. After cluster is ready, ArgoCD (installed via Terraform Helm provider) syncs k8s-configs and installs system apps: Vault, Kyverno, Prometheus, etc.
- Dependencies: Terragrunt `dependency` blocks wire outputs (e.g., VPC → cluster → apps).

---

## 🔐 Security & Connectivity Decisions

- OIDC: GitHub Actions authenticates to cloud providers using OIDC / Workload Identity Pools — no static keys stored in repo or secrets.
- Vault sidecar: Secrets are injected at runtime and mounted under `/vault/secrets` in pods.
- Networking: To reduce costs in this lab we avoid Cloud NAT and assign public IPs to nodes but strictly restrict ingress via VPC firewall rules (`AUTHORIZED_NETWORK`). This is a conscious trade-off for Free-Tier labs; production should use NAT where appropriate.

---

## 💸 FinOps Notes 

- State in AWS stays within typical free-tier limits (S3/DynamoDB). Artifact Registry kept small.
- Node sizing: `e2-standard-4` is recommended to avoid OOMs when running Vault/Prometheus/ArgoCD alongside agent workloads. Using the free $300 credit on GCP justifies using stronger node classes to keep the control plane stable.
- Cost-saving tradeoffs explained in the Security section (NAT vs public IPs + firewall).

---

## 🚀 Getting Started — Prerequisites

- Install: `terraform` (v1.0+), `terragrunt` (v0.35+), `gcloud`, `aws` CLI, `kubectl`, `helm` (optional).
- Recommended local environment: Linux/macOS, GitHub Actions for CI using OIDC.

### Required environment variables / GitHub Secrets

These must be provided in CI (GitHub Actions) or exported locally:

| Name | Purpose |
|---:|---|
| `AUTHORIZED_NETWORK` | CIDR to whitelist for API / SSH access (e.g., `1.2.3.4/32`) |
| `AWS_ACCOUNT_ID` | AWS account for S3/DynamoDB state storage |
| `AWS_ROLE_TO_ASSUME` | Role ARN GitHub Actions will assume for state operations |
| `GCP_PROJECT_ID` | GCP project where GKE and AI will run |
| `GCP_SERVICE_ACCOUNT` | Service account email (where required) |
| `GCP_WORKLOAD_PROVIDER` | Workload Identity Provider resource name/path |
| `INFRACOST_API_KEY` | Infracost API key for cost estimates in PRs |

Also set or configure `AWS_REGION` and `GCP_REGION` (defaults in `account.hcl` / `env.hcl`).

---

## 📦 Directory & Terragrunt patterns

- `root.hcl` generates providers and remote-state configs and merges `account.hcl` + `env.hcl` locals.
- `_envcommon/` contains common inputs for GKE, argocd, node-pools, and network fragments used across environments.
- Each stack has a `terragrunt.hcl` that `include`s `root.hcl` and uses `dependency` blocks to consume outputs from related stacks.

---

## 🧾 Typical Terragrunt commands

Validate/apply a single stack:

```bash
cd gcp/dev/gke/cluster
terragrunt init
terragrunt validate
terragrunt plan
terragrunt apply
```

Deploy an entire environment:

```bash
cd gcp/dev
terragrunt run-all init
terragrunt run-all plan
terragrunt run-all apply
```

Destroy environment:

```bash
cd gcp/dev
terragrunt run-all destroy
```

Notes:
- Use `terragrunt plan` and `terragrunt run-all plan` to inspect changes before applying.
- Provide `GCP_PROJECT_ID`, `AWS_REGION`, and credentials in environment or CI prior to runs.

---

## 🔭 Main resources created

| Area | Resources |
|---|---|
| State & locking | S3 bucket (terraform state), DynamoDB table (locks) [AWS] |
| Networking | VPC, subnets, firewall rules (GCP) |
| Compute | GKE clusters, node pools (GCP) |
| Registry | Artifact Registry (GCP) |
| Identity | IAM roles, service accounts, Workload Identity bindings (GCP) |
| GitOps / Apps | ArgoCD, Vault, Kyverno, Prometheus, Grafana |

---

## ⚙️ Agentic Analyzer (example workload)

- A Python-based Agentic-DevOps Analyzer runs on GKE and uses Vertex AI for analysis.
- It authenticates via Workload Identity (no static keys) and receives secrets via Vault sidecar.
- Deployed via ArgoCD from the `k8s-configs` repo (app-of-apps pattern).

---

## 📁 Files of interest

- `root.hcl` — central provider and remote-state generation.
- `_envcommon/gke.hcl` — common cluster inputs/labels.
- `_envcommon/argocd.hcl` — common ArgoCD chart inputs.
- `gcp/dev/gke/cluster/terragrunt.hcl` — cluster stack with `dependency` on VPC.
- `gcp/dev/apps-bootstrap/argocd/terragrunt.hcl` — ArgoCD Helm install referencing cluster outputs.
- `aws/global/tf-state/` — S3/DynamoDB backend details.

---

## ✅ CI / PR checks recommendations

- Use GitHub Actions with OIDC to authenticate to cloud providers (no secret JSON files).
- Run linters and scanners in PRs: `tflint`, `terraform fmt`, `terraform validate`, `trivy` for container images, and `infracost` for cost estimates.

---

## 🤖 Automated Deployment Workflow (CI/CD)
The entire infrastructure and application lifecycle are managed via GitHub Actions. No manual terragrunt apply is required.

1. **The Infrastructure Multi-Cloud Platform Pipeline**
When you push code or open a PR in the main-infra-repo, the following flow triggers:

**Identity Handshake (OIDC):** GitHub Actions requests a short-lived token from AWS and GCP using OpenID Connect. No static credentials are used.

**Plan Phase (PR):** tflint checks for best practices.

- trivy scans for security misconfigurations.

- infracost comments on the PR with the estimated monthly cost change.

- terragrunt run-all plan generates the execution plan.

**Apply Phase (Merge to Main):** terragrunt run-all apply --terragrunt-non-interactive executes the plan.

*Order of Operations:* `AWS State` → `GCP Network` → `GKE Cluste`r → `Artifact Registry` → `IAM/Workload Identity` → `ArgoCD Bootstrap`.

2. **The GitOps Handshake (k8s-configs Repo)**
Once the main pipeline installs the ArgoCD Root Application, the "Push" phase ends and the "Pull" phase begins:

ArgoCD starts polling the k8s-configs repo.

It detects the definitions for Vault, Kyverno, and Prometheus.

**Automatic Sync:** Any change merged into the main branch of the k8s-configs repo is immediately reconciled by ArgoCD in the cluster.

3. **The Application Pipeline (Agentic-Analyzer Repo)**
This repo has its own independent lifecycle:

**CI:** Runs tests on the Python/AI Agent code.

**Build:** Packages the agent into a Docker image using a slim base image (FinOps).

**Push:** Authenticates via OIDC and pushes the image to the GCP Artifact Registry.

**Promote:** The pipeline automatically sends a Pull Request to the k8s-configs repo to update the image tag.

**Deploy:** Once that PR is merged, ArgoCD detects the new tag and performs a rolling update of the Agent Pod..

---



## 🤝 Contributing

This portfolio is a personal multi-cloud platform engineering lab, but contributions, suggestions, or improvements are always welcome.

---
## 📜 License

This project is licensed under the `MIT License`
.

## 👋 Let’s Connect


<div align="center">
  <a href="https://www.linkedin.com/in/andres-rivera0608">
    <img src="https://img.shields.io/badge/LinkedIn-Andres_Rivera-253342?style=for-the-badge&logo=linkedin&logoColor=white" />
  </a>
  <a href="https://github.com/Rivce06">
    <img src="https://img.shields.io/badge/GitHub-Rivce06-253342?style=for-the-badge&logo=github&logoColor=white" />
  </a>
  <a href="mailto:gvenegas7978@gmail.com">
    <img src="https://img.shields.io/badge/Email-gvenegas7978@gmail.com-253342?style=for-the-badge&logo=gmail&logoColor=white" />
  </a>
</div>
