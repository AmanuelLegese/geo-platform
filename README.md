# Geo-Platform Project

Welcome to the **Geo-Platform** project! This repository contains a full-stack application leveraging a modern web architecture. It consists of a **Next.js** frontend, a **Django REST Framework** backend, and a **PostgreSQL** database, all containerized with **Docker** and reverse-proxied through **Nginx**.

## 📑 Table of Contents

- [Architecture & Tech Stack](#architecture--tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started (Run & Build)](#getting-started-run--build)
- [Deployment Guide](#deployment-guide)
- [Git & Commit Standards](#git--commit-standards)
- [DevOps Approaches & Best Practices](#devops-approaches--best-practices)

---

## 🏗️ Architecture & Tech Stack

- **Frontend (`/Frontend`)**: Next.js 16 (React 19), TailwindCSS 4, TypeScript.
- **Backend (`/Backend`)**: Python (Django, Django REST Framework, django-filter).
- **Database**: PostgreSQL (with Adminer GUI for data management).
- **Reverse Proxy (`/nginx`)**: Nginx (routes `/api/` to Django, and `/` to Next.js).
- **Containerization**: Docker & Docker Compose.

---

## 📂 Project Structure

```text
.
├── Backend/              # Django application and backend logic
├── Frontend/             # Next.js React application
├── Dockerfile/           # Dockerfiles for various services (Python, Next.js, Nginx, Postgres)
├── nginx/                # Nginx reverse proxy configuration
├── docker-compose.yml    # Main Docker Compose configuration
└── .git/                 # Git repository
```

---

## 📋 Prerequisites

To run this project locally, you will need the following installed on your machine:

- **Docker Base**: [Docker](https://docs.docker.com/get-docker/) installed and running.
- **Docker Compose**: [Docker Compose](https://docs.docker.com/compose/install/) plugin.
- **Git**: For version control.

---

## 🚀 Getting Started (Run & Build)

You can build and run the entire stack using Docker Compose.

### 1. Build and Start the Containers

In the root directory of the project, run:

```bash
docker-compose up --build -d
```

This will build the images for Next.js, Django, Nginx, and Postgres, and start the containers in detached mode.

### 2. Access the Application

Once the containers are successfully up and running, you can access the following services:

- **Main Application (Frontend)**: [http://localhost](http://localhost) (Proxied via Nginx) or [http://localhost:3000](http://localhost:3000) (Direct)
- **Backend API**: [http://localhost/api/](http://localhost/api/) (Proxied via Nginx) or [http://localhost:8000](http://localhost:8000) (Direct)
- **Database Admin (Adminer)**: [http://localhost:8080](http://localhost:8080)
- **PostgreSQL Database**: `localhost:5432`

### 3. Helpful Commands

- **View Logs**: `docker-compose logs -f`
- **Stop Containers**: `docker-compose down`
- **Restart a specific service**: `docker-compose restart <service_name>` (e.g., `docker-compose restart django_api`)
- **Run Django Migrations**: `docker-compose exec django_api python manage.py migrate`

---

## 🚢 Deployment Guide

When deploying this application to a production environment (e.g., AWS EC2, DigitalOcean Droplet, Linode), follow these steps:

1. **Provision a Server**: Set up a Linux server equipped with Docker and Docker Compose.
2. **Clone the Repository**:
   ```bash
   git clone <your-repository-url>
   cd geo-platform
   ```
3. **Environment Variables (.env)**: Do not hardcode secrets (like `DATABASE_PASSWORD` or Django `SECRET_KEY`) in `.yml` files. Create a `.env` file for production and reference it in `docker-compose.yml` (`env_file: .env`).
4. **HTTPS/SSL Certificate**: Use **Certbot (Let's Encrypt)** alongside Nginx to secure your application with HTTPS. Update `nginx/default.conf` to listen on port 443 and include your SSL certificates.
5. **Run Production Build**:
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
   ```
   *(Note: You might want to strip dev tools out of your dockerfiles and avoid mounting local source volumes for production.)*

---

## 📝 Git & Commit Standards

To maintain a clean and readable Git history, we adopt **Conventional Commits**. This standardization makes it easy to read history, automatically generate changelogs, and figure out semantic versioning bumps.

### Commit Message Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Allowed `<type>`s:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools and libraries such as documentation generation
- `ci`: Changes to our CI configuration files and scripts (e.g., GitHub Actions, GitLab CI)

**Examples:**
- `feat(auth): enable JWT token login`
- `fix(api): resolve 500 error on geometry upload`
- `docs: update deployment instructions in README`

---

## ⚙️ DevOps Approaches & Best Practices

To elevate this project to a robust, enterprise-grade standard, consider implementing the following DevOps workflows:

### 1. Continuous Integration / Continuous Deployment (CI/CD)
- **GitHub Actions / GitLab CI**: Create a pipeline that triggers on every Push/Pull Request.
  - **Linting & Formatting**: Enforce strict linting for Next.js (ESLint/Prettier) and Django (Flake8/Black).
  - **Automated Testing**: Run frontend `jest` or `cypress` tests, and backend `pytest` or `django test`.
  - **Docker Build Validation**: Ensure that standard Docker build commands never fail before merging.
- **Automated Deployments**: Once code is merged to the `main` branch, auto-deploy it to a `staging` environment. Tagged releases can be deployed to production.

### 2. Infrastructure as Code (IaC)
- Use tools like **Terraform** or **AWS CloudFormation** to provision your database, compute instances, and networking layers. This ensures environments are reproducible, scalable, and version-controlled.

### 3. Container Orchestration
- While Docker Compose is excellent for local dev and single-server deployments, for high availability, consider migrating to **Kubernetes (K8s)** or fully managed cloud solutions like **AWS ECS / EKS** or **Google Cloud Run**.

### 4. Logging & Monitoring
- **Application Monitoring**: Integrate **Sentry** in both the Next.js frontend and the Django backend to catch and aggregate unhandled exceptions in real-time.
- **Resource Metrics**: Use **Prometheus** (to gather metrics from Postgres and Docker) and **Grafana** (to visualize CPU, memory, API latency, and traffic).
- **Log Aggregation**: Utilize an **ELK Stack** (Elasticsearch, Logstash, Kibana) or cloud-native options like **AWS CloudWatch** to aggregate logs across all separated Docker containers for unified analysis.

### 5. Database Management
- **Automated Backups**: Schedule daily `pg_dump` jobs (using a sidecar cron container) that stream encrypted database backups to an object storage bucket (e.g., AWS S3).
- **Migrations**: Always test Django migrations locally before applying them. Consider a pre-deploy hook in your CI/CD pipeline to strictly handle `python manage.py migrate`.

### 6. Security & Vulnerability Scanning
- Implement **Trivy** or **Dependabot** to scan your Next.js `package.json`, Python `requirements.txt`, and Docker images for underlying CVE vulnerabilities and outdated dependencies.
