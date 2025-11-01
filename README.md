<div align="center">

# 🌱 Open Resilience Initiative

**Building Online Counseling & Consultation Systems for Resilience and Support**

[![Website](https://img.shields.io/badge/Website-openresilience.cc-blue)](https://openresilience.cc)
[![Documentation](https://img.shields.io/badge/Docs-Platform%20Guide-green)](https://openresilienceinitiative.mintlify.app)
[![Organization](https://img.shields.io/badge/GitHub-Organization-lightgrey)](https://github.com/OpenResilienceInitiative)

</div>

---

## 🌟 About ORISO Platform

**ORISO (Online Resilience Initiative Support Operations)** is a comprehensive microservices-based online counseling system designed for scalability, security, and real-time communication. The platform enables accessible mental health support through a modern, decentralized architecture.

### 🎯 Mission

To provide accessible, secure, and scalable online counseling services through open-source technology that empowers communities to deliver mental health support.

### ✨ Key Features

- 🔐 **Secure Authentication** - Keycloak-based SSO and identity management
- 💬 **Real-time Communication** - Matrix Protocol for encrypted chat and video calls
- 🏗️ **Microservices Architecture** - Scalable, maintainable service-oriented design
- ☸️ **Kubernetes Orchestration** - Cloud-native deployment and scaling
- 📊 **Full Observability** - Distributed tracing, metrics, and monitoring
- 🌐 **Multi-tenant Support** - Isolated tenant configurations and data

---

## 🏗️ Platform Architecture

### 📊 Platform Statistics

- **Repositories** - Specialized components for each system aspect
- **Microservices** - Spring Boot backend services (Java 17)
- **Modern Frontend** - React 18 with TypeScript
- **Real-time Messaging** - Matrix Protocol (E2EE support)
- **Container Orchestration** - Kubernetes (k3s)
- **Database Stack** - MariaDB, MongoDB, PostgreSQL, Redis

### 🛠️ Technology Stack

| Layer | Technologies |
|-------|--------------|
| **Frontend** | React 18, TypeScript, Vite, Matrix JS SDK |
| **Backend** | Spring Boot 2.7.x, Java 17, REST APIs |
| **Databases** | MariaDB 10.6, MongoDB 5.0, PostgreSQL 14, Redis 7.0 |
| **Messaging** | RabbitMQ 3.12, Matrix Synapse |
| **Authentication** | Keycloak 22.x, OIDC, JWT |
| **Orchestration** | Kubernetes (k3s), Docker |
| **Observability** | SignOZ, OpenTelemetry, Prometheus |
| **Reverse Proxy** | Nginx 1.25 |

---

## 📦 Repository Structure

<div align="center">

### **Frontend Applications**
[`ORISO-Frontend`](https://github.com/OpenResilienceInitiative/ORISO-Frontend) • [`ORISO-Admin`](https://github.com/OpenResilienceInitiative/ORISO-Admin)

### **Backend Microservices**
[`ORISO-UserService`](https://github.com/OpenResilienceInitiative/ORISO-UserService) • [`ORISO-TenantService`](https://github.com/OpenResilienceInitiative/ORISO-TenantService) • [`ORISO-AgencyService`](https://github.com/OpenResilienceInitiative/ORISO-AgencyService) • [`ORISO-ConsultingTypeService`](https://github.com/OpenResilienceInitiative/ORISO-ConsultingTypeService)

### **Infrastructure & Communication**
[`ORISO-Database`](https://github.com/OpenResilienceInitiative/ORISO-Database) • [`ORISO-Nginx`](https://github.com/OpenResilienceInitiative/ORISO-Nginx) • [`ORISO-Keycloak`](https://github.com/OpenResilienceInitiative/ORISO-Keycloak) • [`ORISO-Redis`](https://github.com/OpenResilienceInitiative/ORISO-Redis) • [`ORISO-Matrix`](https://github.com/OpenResilienceInitiative/ORISO-Matrix) • [`ORISO-Element`](https://github.com/OpenResilienceInitiative/ORISO-Element)

### **Monitoring & Deployment**
[`ORISO-HealthDashboard`](https://github.com/OpenResilienceInitiative/ORISO-HealthDashboard) • [`ORISO-SignOZ`](https://github.com/OpenResilienceInitiative/ORISO-SignOZ) • [`ORISO-Kubernetes`](https://github.com/OpenResilienceInitiative/ORISO-Kubernetes) • [`ORISO-Docs`](https://github.com/OpenResilienceInitiative/ORISO-Docs)

</div>

<details>
<summary><b>📚 View Complete Repository Guide</b></summary>

See our [Complete Repository Guide](https://github.com/OpenResilienceInitiative/.github/blob/main/README.md#repositories) for detailed information about each repository, including:
- Repository purposes and features
- Technology stacks
- API endpoints
- Deployment configurations
- Documentation links

</details>

---

## 🚀 Quick Start

### 📖 Documentation

- **📘 Platform Documentation:** [openresilienceinitiative.mintlify.app](https://openresilienceinitiative.mintlify.app)
- **📝 Contributing Guide:** See [Contribution Guidelines](#-contributing) below
- **🏷️ Label System:** [Label Setup Guide](./LABEL_SETUP_GUIDE.md)
- **📋 PR Templates:** [PR Template Guide](./PR_TEMPLATE_SETUP_GUIDE.md)

### 🔧 Getting Started

1. **Explore the Platform** - Check out our [live documentation](https://openresilienceinitiative.mintlify.app)
2. **Clone Repositories** - Start with [`ORISO-Kubernetes`](https://github.com/OpenResilienceInitiative/ORISO-Kubernetes) for deployment
3. **Read the Docs** - Each repository contains detailed README files
4. **Contribute** - See our [contribution guidelines](#-contributing) below

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### For Contributors

1. **Fork & Clone** - Fork the repository you want to contribute to
2. **Create Branch** - Use naming like `feature/`, `fix/`, `task/`
3. **Follow Standards** - Use PR templates and follow our guidelines
4. **Submit PR** - Create a pull request with proper description

### Contribution Standards

- ✅ **Semantic PR Titles** - Use format: `feat:`, `fix:`, `docs:`, etc.
- ✅ **PR Templates** - Select appropriate template when creating PR
- ✅ **Code Quality** - Follow code review guidelines
- ✅ **Documentation** - Update docs for significant changes

**📖 Detailed Guides:**
- [PR Template Setup Guide](./PR_TEMPLATE_SETUP_GUIDE.md) - How to create proper PRs
- [Label Setup Guide](./LABEL_SETUP_GUIDE.md) - Understanding our label system
- [Code Review Guide](./CODE_REVIEW_GUIDE.md) - Review standards and practices

### Automated Checks

All PRs are automatically validated for:
- ✅ Semantic commit format
- ✅ PR body completeness
- ✅ Auto-labeling (work type, area, priority, size)
- ✅ Security scanning (Trivy)
- ✅ Code quality checks

---

## 🏷️ Repository Labels

We use a comprehensive labeling system for better organization:

| Category | Labels |
|----------|--------|
| **Work Type** | `story`, `task`, `bug`, `hotfix` |
| **Priority** | `P0-Critical`, `P1-High`, `P2-Medium`, `P3-Low` |
| **Area** | `frontend`, `backend`, `api`, `database`, `infra`, `docs` |
| **Size** | `S`, `M`, `L`, `XL` |

See [LABEL_SETUP_GUIDE.md](./LABEL_SETUP_GUIDE.md) for complete details.

---

## 📖 About This Repository

This `.github` repository contains **organization-wide standards** that apply to all repositories:

- 📋 **PR Templates** - Standardized templates for different change types
- ⚙️ **Workflow Automation** - GitHub Actions for validation and quality checks
- 🏷️ **Label Configuration** - Consistent labeling across all repos
- 📚 **Documentation** - Contribution guidelines and best practices

---

## 🌐 Links & Resources

- **🌐 Website:** [openresilience.cc](https://openresilience.cc)
- **📚 Documentation:** [Platform Docs](https://openresilienceinitiative.mintlify.app)
- **👥 Organization:** [OpenResilienceInitiative](https://github.com/OpenResilienceInitiative)

---

## 📄 License

This organization uses **GNU Affero General Public License v3.0** (AGPL-3.0) for core repositories. This copyleft license ensures that modifications and services built using ORISO Platform remain open source, maintaining freedom and accessibility of mental health support technology.

> **Note:** License information is specified in individual repository LICENSE files.

---

## 📞 Contact & Support

- **Questions?** Open an issue in the relevant repository
- **Documentation Issues?** See [ORISO-Docs](https://github.com/OpenResilienceInitiative/ORISO-Docs)
- **General Inquiries:** Visit our [website](https://openresilience.cc)

---

<div align="center">

**Built with ❤️ by the Open Resilience Initiative team**

[![License](https://img.shields.io/badge/License-AGPL--3.0-green)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success)]()

</div>

