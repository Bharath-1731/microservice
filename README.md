# Multi-Service .NET + Angular Microservices Platform

## Overview

This project is a production-ready, Docker-orchestrated microservices stack featuring:
- **.NET Core** backend services (A, B, C)
- **Angular** frontends for each service
- **Ocelot** API Gateway with RSA-secured JWT authentication
- **Key Management Service** for JWT signing
- **Swagger** for API documentation
- **Prometheus & Grafana** for monitoring
- **Automated deployment** scripts and Docker Stack files

## Folder Structure
/project-root/ 
├── ServiceA/ 
├── ServiceB/ 
├── ServiceC/ 
├── OcelotGateway/ 
├── KeyManagementService/ 
├── deployment/ 
├── docker-stack.yml 
└── README.md


## Quick Start

1. **Clone the repository**
2. **Build and deploy the stack:**
	cd deployment ./deploy.sh
3. **Access services:**
   - API Gateway: http://localhost:7000
   - ServiceA Frontend: http://localhost:4200
   - ServiceB Frontend: http://localhost:4201
   - ServiceC Frontend: http://localhost:4202
   - Swagger: http://localhost:7000/swagger
   - Grafana: http://localhost:3000 (admin/admin)
   - Prometheus: http://localhost:9090

## Monitoring

- **Prometheus** scrapes all backend services.
- **Grafana** dashboards visualize metrics.
- Configs are in `/deployment/prometheus/` and `/deployment/grafana/`.

## Security

- JWT tokens are signed with RSA keys managed by the KeyManagementService.
- Ocelot Gateway validates JWTs for all protected routes.

## Automated Deployment

All deployment scripts and stack files are in `/deployment/`.

- `deploy.sh`: Builds and deploys the full stack.
- `remove.sh`: Tears down the stack.

## Extending

- Add new services by copying ServiceA structure.
- Update `ocelot.json` and `docker-stack.yml` accordingly.

---

   