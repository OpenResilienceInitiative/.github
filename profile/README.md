<div align="center">

# 𐂷 Open Resilience Initiative

**Building Online Counseling & Consultation Systems for Resilience and Support**

[![Website](https://img.shields.io/badge/Website-openresilience.cc-blue)](https://openresilience.cc)
[![Documentation](https://img.shields.io/badge/Docs-Platform%20Guide-green)](https://docs.oriso.site)

</div>

---

## What role plays ORISO inside our open source resilience initiative?

**ORISO (Online Resilience Initiative Single Organisation)** is the dedicated instance of the Open Resilience Initiative designed for single large organisations. It provides a secure, multi-tenant counseling infrastructure where one organisation can manage multiple internal counseling units within a unified, scalable architecture.

### 🏁 Mission

To provide accessible, secure, and scalable online counseling services through open-source technology that empowers communities to deliver mental health support.

---

## 🏗️ Platform Architecture

<img width="6950" height="4241" alt="architecture-overview" src="https://github.com/user-attachments/assets/01c92c05-22c5-4569-b28b-12bb5edb330c" />

### 📊 Repository Structure

| Category | Repositories |
|----------|-------------|
| **Frontend** | `ORISO-Frontend`, `ORISO-Admin` |
| **Backend Services** | `ORISO-UserService`, `ORISO-TenantService`, `ORISO-AgencyService`, `ORISO-ConsultingTypeService` |
| **Infrastructure** | `ORISO-Database`, `ORISO-Keycloak`, `ORISO-Redis`, `ORISO-Kubernetes` |
| **Communication** | `ORISO-Matrix`, `ORISO-Element`, `ORISO-ElementCall`, `ORISO-Livekit` |
| **Monitoring** | `ORISO-HealthDashboard`, `ORISO-SignOZ`, `ORISO-Status` |
| **Documentation** | `ORISO-Docs` |

### 🛠️ Technology Stack

- **Frontend**: React 18, TypeScript, Vite
- **Backend**: Spring Boot 2.7.14, Java 17, REST APIs
- **Databases**: MariaDB, MongoDB, PostgreSQL, Redis
- **Message Broker**: RabbitMQ
- **Authentication**: Keycloak, OIDC, JWT
- **Messaging**: Matrix Protocol (E2EE)
- **Video Calls**: LiveKit (WebRTC/SFU), Element Call
- **Orchestration**: Kubernetes (k3s), Helm 3.x, Docker
- **Ingress**: Nginx Ingress Controller, Cert-Manager (TLS automation)
- **Observability**: SignOZ, OpenTelemetry

### 🚀 Deployment Architecture

ORISO is deployed as a complete platform using **Helm charts**:

- **21 services** managed via umbrella chart (`oriso-platform`)
- **Kubernetes-native** deployment with automatic scaling
- **TLS automation** via Cert-Manager and Let's Encrypt
- **Centralized database management** (Liquibase disabled in services)
- **Multi-phase deployment**: Infrastructure → Authentication → Communication → WebRTC → Backend → Frontend → Monitoring

**Quick Deploy:** sh
cd caritas-workspace/ORISO-Kubernetes/helm
helm dependency update oriso-platform
helm install oriso-platform ./oriso-platform --namespace caritas --create-namespace -f values.yaml

---

## 🔗 Quick Links

- **📘 Platform Documentation**: [docs.oriso.site](https://docs.oriso.site)
- **🌐 Website**: [openresilience.cc](https://openresilience.cc)
- **📚 Organization Standards**: [`.github` repository](https://github.com/OpenResilienceInitiative/.github)

---

## 🤝 Contributing

We welcome contributions! Our organization uses standardized workflows and templates:

- ✅ **Semantic PR Titles** - `feat:`, `fix:`, `docs:`, etc.
- ✅ **Auto-labeling** - Work type, area, priority, size
- ✅ **Security Scanning** - Automatic vulnerability detection
- ✅ **Code Quality Checks** - Automated quality validation

**📖 Guides**: See [`.github` repository](https://github.com/OpenResilienceInitiative/.github) for contribution guidelines.

---

<div align="center">

**Built with ❤️ by the Open Resilience Initiative team**

[![License](https://img.shields.io/badge/License-AGPL--3.0-green)](LICENSE)

</div>

