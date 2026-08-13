<div align="center">

# 𐂷 Open Resilience Initiative

**Building Online Counseling & Consultation Systems for Resilience and Support**

</div>

---

## What role does ORISO play inside our open-source resilience initiative?

**ORISO (Online Resilience Initiative Single Organisation)** is the dedicated instance of the Open Resilience Initiative designed for single large organisations. It provides a secure, multi-tenant counseling infrastructure where one organisation can manage multiple internal counseling units within a unified, scalable architecture.

### 🏁 Mission

To provide accessible, intuitive, secure and scalable online counseling services through open-source technology.

📚 Documentation: [docs.oriso.site](https://docs.oriso.site)

---

## 🏗️ Platform Architecture
<img width="2793" height="1375" alt="2026-01-20 ORISO architectur diagram" src="https://github.com/user-attachments/assets/4783fdd1-787e-4aa0-92da-99d01039fb33" />

### 📊 Repository Structure

| Category | Repositories |
|----------|-------------|
| **Frontend** | [`ORISO-Frontend`](https://github.com/OpenResilienceInitiative/ORISO-Frontend), [`ORISO-Admin`](https://github.com/OpenResilienceInitiative/ORISO-Admin) |
| **Backend Services** | [`ORISO-UserService`](https://github.com/OpenResilienceInitiative/ORISO-UserService), [`ORISO-TenantService`](https://github.com/OpenResilienceInitiative/ORISO-TenantService), [`ORISO-AgencyService`](https://github.com/OpenResilienceInitiative/ORISO-AgencyService), [`ORISO-ConsultingTypeService`](https://github.com/OpenResilienceInitiative/ORISO-ConsultingTypeService), [`ORISO-Keycloak`](https://github.com/OpenResilienceInitiative/ORISO-Keycloak) |
| **Infrastructure** | [`ORISO-Helm`](https://github.com/OpenResilienceInitiative/ORISO-Helm), [`.github`](https://github.com/OpenResilienceInitiative/.github) |
| **Communication** | [`ORISO-Livekit`](https://github.com/OpenResilienceInitiative/ORISO-Livekit), [`ORISO-ElementCall`](https://github.com/OpenResilienceInitiative/ORISO-ElementCall) |
| **Monitoring** | [`ORISO-HealthDashboard`](https://github.com/OpenResilienceInitiative/ORISO-HealthDashboard), [`ORISO-SigNoz`](https://github.com/OpenResilienceInitiative/ORISO-SigNoz) |
| **Documentation** | [`ORISO-Docs`](https://github.com/OpenResilienceInitiative/ORISO-Docs) |

### 🛠️ Technology Stack

- **Frontend**: React 19, TypeScript, Vite
- **Backend**: Spring Boot, Java 21, REST APIs
- **Databases**: MariaDB, MongoDB, PostgreSQL, Redis
- **Authentication**: Keycloak, OIDC, JWT
- **Messaging**: Matrix Protocol (E2EE)
- **Orchestration**: Kubernetes, Docker
- **Observability**: SigNoz

---

## 🤝 Contributing

We welcome contributions! Our organization uses standardized workflows and templates:

- ✅ **Semantic PR Titles** - `feat:`, `fix:`, `docs:`, etc.
- ✅ **Auto-labeling** - Work type, area, priority, size
- ✅ **Security Scanning** - Automatic vulnerability detection
- ✅ **Code Quality Checks** - Automated quality validation

---

<div align="center">

**Built with ❤️ by the Open Resilience Initiative team**

[![License](https://img.shields.io/badge/License-AGPL--3.0-green)](https://github.com/OpenResilienceInitiative/.github/blob/main/LICENSE)

</div>
