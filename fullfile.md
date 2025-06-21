# Production-Ready Docker Swarm Stack for Microservices with Auto-Scaling, Monitoring, and Secure Load Balancing

---

## 1. **Environment Variables & Configuration**

Create a file named `.env` in your project root with the following content (edit values for your environment):

```
# .env
DOCKER_HUB_USERNAME=yourdockerhubusername
DOCKER_HUB_PASSWORD=yourdockerhubpassword

ACR_SERVER=youracr.azurecr.io
ACR_USERNAME=youracrusername
ACR_PASSWORD=youracrpassword

GRAFANA_ADMIN_PASSWORD=your-strong-grafana-password

ALERT_EMAIL_FROM=your-alert-email@gmail.com
ALERT_EMAIL_TO=your-receive-email@gmail.com
ALERT_EMAIL_USER=your-alert-email@gmail.com
ALERT_EMAIL_PASS=your-app-password # Use an app password, not your main password!
SMTP_SERVER=smtp.gmail.com:587
```

---

## 2. **Files to Edit for Your Environment**

- `.env` (see above)
- `nginx/nginx.conf` (if you want to change load balancing or SSL)
- `prometheus/prometheus.yml` (add/remove scrape targets as needed)
- `prometheus/alert.rules.yml` (tune thresholds, add memory rules, etc.)
- `alertmanager/alertmanager.yml` (set your email and SMTP settings)
- `grafana_admin_password.txt` (set your Grafana admin password)
- `autoscaler/autoscaler.py` (advanced: add authentication, cooldowns, etc.)

---

## 3. **Pre-requisites & Commands to Run Before Deploying**

**Install required tools:**
```sh
# Docker & Docker Compose
sudo apt-get update
sudo apt-get install -y docker.io docker-compose jq curl python3 python3-pip

# Initialize Docker Swarm (run ONCE on your manager node)
docker swarm init

# Create overlay network for your stack
docker network create --driver=overlay --attachable app-net

# (Optional) Install Flask for autoscaler build context
pip3 install flask
```

**Create Grafana admin password file:**
```sh
echo "your-strong-grafana-password" > grafana_admin_password.txt
```

---

## 4. **Final Docker Stack File for Docker Hub**

```yaml
# docker-stack-dockerhub.yml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - app-net
    depends_on:
      - ocelotgateway

  ocelotgateway:
    image: yourdockerhubusername/ocelotgateway:OCELOT_TAG
    ports:
      - "7000:7000"
    networks:
      - app-net
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.50'
          memory: 512M

  servicea:
    image: yourdockerhubusername/servicea:SERVICEA_TAG
    networks:
      - app-net
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.50'
          memory: 512M

  serviceb:
    image: yourdockerhubusername/serviceb:SERVICEB_TAG
    networks:
      - app-net
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.50'
          memory: 512M

  servicec:
    image: yourdockerhubusername/servicec:SERVICEC_TAG
    networks:
      - app-net
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.50'
          memory: 512M

  prometheus:
    image: prom/prometheus
    user: "nobody"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/alert.rules.yml:/etc/prometheus/alert.rules.yml:ro
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    ports:
      - "9090:9090"
    networks:
      - app-net

  alertmanager:
    image: prom/alertmanager
    user: "nobody"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
    ports:
      - "9093:9093"
    networks:
      - app-net

  grafana:
    image: grafana/grafana
    user: "472"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD_FILE=/run/secrets/grafana_admin_password
    secrets:
      - grafana_admin_password
    ports:
      - "3000:3000"
    networks:
      - app-net

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - app-net

  nodeexporter:
    image: prom/node-exporter
    ports:
      - "9100:9100"
    networks:
      - app-net

  autoscaler:
    build: ./autoscaler
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - app-net
    environment:
      - DOCKER_HOST=unix:///var/run/docker.sock

secrets:
  grafana_admin_password:
    file: ./grafana_admin_password.txt

networks:
  app-net:
    driver: overlay
    attachable: true
```

---

## 5. **Final Docker Stack File for Azure Container Registry**


## 6. **How to Deploy**

**A. Build and Push Images (if needed):**
- Build and push your images to Docker Hub or ACR with appropriate tags.

**B. Use the Provided Deployment Script:**
- Use your `deploy.sh` script to select registry, fetch latest tags, and deploy the stack.

**C. Deploy the Stack:**
```sh
# For Docker Hub
docker stack deploy -c docker-stack-dockerhub.yml mystack

# For Azure Container Registry
docker stack deploy -c docker-stack-acr.yml mystack
```

---

## 7. **Accessing Services**

- **NGINX Load Balancer:** `http://<your-host>:80`
- **Prometheus:** `http://<your-host>:9090`
- **Grafana:** `http://<your-host>:3000`
- **Alertmanager:** `http://<your-host>:9093`
- **cAdvisor:** `http://<your-host>:8080`
- **Node Exporter:** `http://<your-host>:9100`

---

## 8. **Security & Production Notes**

- All configs are mounted read-only.
- Grafana admin password is stored as a Docker secret.
- Alertmanager uses app password for SMTP.
- Autoscaler runs with access to Docker socket (restrict network/firewall as needed).
- Tune Prometheus alert rules for your real production load and requirements.
- Consider using HTTPS/SSL for NGINX in production.

---

## 9. **Monitoring & Auto-Scaling**

- Prometheus scrapes all services, cAdvisor, and nodeexporter.
- Alertmanager sends email and webhook alerts.
- Autoscaler listens for webhooks and scales services up/down based on CPU usage.
- You can add memory-based rules or cooldown logic as needed.

---

## 10. **Support & Troubleshooting**

- Check logs with `docker service logs mystack_servicename`
- Scale manually with `docker service scale mystack_servicea=3`
- Update stack with `docker stack deploy -c <stack-file> mystack`
- Remove stack with `docker stack rm mystack`

---

**Edit the files as described, follow the commands, and you’ll have a secure, production-ready, auto-scaling, monitored microservices stack!**