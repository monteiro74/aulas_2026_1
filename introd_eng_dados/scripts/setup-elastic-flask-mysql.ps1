# setup-elastic-flask-mysql.ps1
# Stack local para Docker Desktop:
# Elasticsearch + Kibana + APM Server + Elastic Agent + MySQL + Flask instrumentado

$ErrorActionPreference = "Stop"

$ELASTIC_VERSION = "9.4.1"
$MYSQL_ROOT_PASSWORD = "root123"
$MYSQL_DATABASE = "appdb"
$MYSQL_USER = "appuser"
$MYSQL_PASSWORD = "app123"
$APM_SECRET_TOKEN = "changeme_apm_token"

Write-Host "Criando estrutura de diretórios..." -ForegroundColor Cyan

New-Item -ItemType Directory -Force -Path ".\mysql\init" | Out-Null
New-Item -ItemType Directory -Force -Path ".\flask-app" | Out-Null
New-Item -ItemType Directory -Force -Path ".\elastic-agent" | Out-Null

Write-Host "Gerando docker-compose.yml..." -ForegroundColor Cyan

@"
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:${ELASTIC_VERSION}
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - xpack.license.self_generated.type=basic
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
    networks:
      - observability

  kibana:
    image: docker.elastic.co/kibana/kibana:${ELASTIC_VERSION}
    container_name: kibana
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      - XPACK_SECURITY_ENABLED=false
      - TELEMETRY_ENABLED=false
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
    networks:
      - observability

  apm-server:
    image: docker.elastic.co/apm/apm-server:${ELASTIC_VERSION}
    container_name: apm-server
    command: >
      apm-server -e
        -E apm-server.host=0.0.0.0:8200
        -E apm-server.auth.secret_token=${APM_SECRET_TOKEN}
        -E output.elasticsearch.hosts=["http://elasticsearch:9200"]
        -E setup.kibana.host=kibana:5601
    ports:
      - "8200:8200"
    depends_on:
      - elasticsearch
      - kibana
    networks:
      - observability

  mysql:
    image: mysql:8.4
    container_name: mysql
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
      - ./mysql/init:/docker-entrypoint-initdb.d
    networks:
      - observability

  elastic-agent:
    image: docker.elastic.co/beats/elastic-agent:${ELASTIC_VERSION}
    container_name: elastic-agent
    user: root
    environment:
      - FLEET_ENROLL=0
    volumes:
      - ./elastic-agent/elastic-agent.yml:/usr/share/elastic-agent/elastic-agent.yml:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    depends_on:
      - elasticsearch
      - mysql
    networks:
      - observability

  flask-app:
    build:
      context: ./flask-app
    container_name: flask-app
    environment:
      - ELASTIC_APM_SERVICE_NAME=flask-demo
      - ELASTIC_APM_SERVER_URL=http://apm-server:8200
      - ELASTIC_APM_SECRET_TOKEN=${APM_SECRET_TOKEN}
      - ELASTIC_APM_ENVIRONMENT=local
      - MYSQL_HOST=mysql
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
    ports:
      - "5000:5000"
    depends_on:
      - mysql
      - apm-server
    networks:
      - observability

volumes:
  elasticsearch-data:
  mysql-data:

networks:
  observability:
    driver: bridge
"@ | Set-Content -Encoding UTF8 ".\docker-compose.yml"

Write-Host "Gerando script inicial do MySQL..." -ForegroundColor Cyan

@"
CREATE DATABASE IF NOT EXISTS appdb;

USE appdb;

CREATE TABLE IF NOT EXISTS projetos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    situacao VARCHAR(30) NOT NULL DEFAULT 'ATIVO',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO projetos (nome, situacao) VALUES
('Projeto Observabilidade Flask', 'ATIVO'),
('Projeto Monitoramento MySQL', 'ATIVO');

CREATE USER IF NOT EXISTS 'elastic_monitor'@'%' IDENTIFIED BY 'elasticmonitor123';

GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'elastic_monitor'@'%';

FLUSH PRIVILEGES;
"@ | Set-Content -Encoding UTF8 ".\mysql\init\01-init.sql"

Write-Host "Gerando configuração standalone do Elastic Agent..." -ForegroundColor Cyan

@"
outputs:
  default:
    type: elasticsearch
    hosts:
      - http://elasticsearch:9200

inputs:
  - id: mysql-metrics
    type: mysql/metrics
    use_output: default
    data_stream.namespace: default
    streams:
      - metricsets:
          - status
        hosts:
          - "tcp(mysql:3306)/"
        username: elastic_monitor
        password: elasticmonitor123
        period: 10s
        data_stream:
          dataset: mysql.status
          type: metrics

  - id: docker-container-logs
    type: logfile
    use_output: default
    data_stream.namespace: default
    streams:
      - paths:
          - /var/lib/docker/containers/*/*.log
        data_stream:
          dataset: docker.container_logs
          type: logs
"@ | Set-Content -Encoding UTF8 ".\elastic-agent\elastic-agent.yml"

Write-Host "Gerando aplicação Flask de exemplo..." -ForegroundColor Cyan

@"
flask==3.0.3
elastic-apm[flask]==6.23.0
pymysql==1.1.1
cryptography==43.0.1
"@ | Set-Content -Encoding UTF8 ".\flask-app\requirements.txt"

@"
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
"@ | Set-Content -Encoding UTF8 ".\flask-app\Dockerfile"

@"
import os
import time
import pymysql
from flask import Flask, jsonify
from elasticapm.contrib.flask import ElasticAPM

app = Flask(__name__)

app.config["ELASTIC_APM"] = {
    "SERVICE_NAME": os.getenv("ELASTIC_APM_SERVICE_NAME", "flask-demo"),
    "SERVER_URL": os.getenv("ELASTIC_APM_SERVER_URL", "http://apm-server:8200"),
    "SECRET_TOKEN": os.getenv("ELASTIC_APM_SECRET_TOKEN", "changeme_apm_token"),
    "ENVIRONMENT": os.getenv("ELASTIC_APM_ENVIRONMENT", "local"),
    "DEBUG": True,
}

apm = ElasticAPM(app)

def get_connection():
    return pymysql.connect(
        host=os.getenv("MYSQL_HOST", "mysql"),
        user=os.getenv("MYSQL_USER", "appuser"),
        password=os.getenv("MYSQL_PASSWORD", "app123"),
        database=os.getenv("MYSQL_DATABASE", "appdb"),
        cursorclass=pymysql.cursors.DictCursor,
    )

@app.route("/")
def index():
    return jsonify({
        "status": "ok",
        "message": "Flask monitorado pelo Elastic APM",
        "endpoints": ["/projetos", "/lento", "/erro"]
    })

@app.route("/projetos")
def listar_projetos():
    conn = get_connection()
    with conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT id, nome, situacao, criado_em FROM projetos")
            rows = cursor.fetchall()
    return jsonify(rows)

@app.route("/lento")
def lento():
    time.sleep(2)
    return jsonify({
        "status": "ok",
        "message": "Endpoint propositalmente lento para aparecer no APM"
    })

@app.route("/erro")
def erro():
    raise RuntimeError("Erro proposital para teste do Elastic APM")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
"@ | Set-Content -Encoding UTF8 ".\flask-app\app.py"

Write-Host "Subindo containers..." -ForegroundColor Green

docker compose up -d --build

Write-Host ""
Write-Host "Stack iniciada." -ForegroundColor Green
Write-Host "Kibana:        http://localhost:5601"
Write-Host "Elasticsearch: http://localhost:9200"
Write-Host "APM Server:    http://localhost:8200"
Write-Host "Flask App:     http://localhost:5000"
Write-Host "MySQL:         localhost:3306"
Write-Host ""
Write-Host "Teste a aplicação:"
Write-Host "  http://localhost:5000/"
Write-Host "  http://localhost:5000/projetos"
Write-Host "  http://localhost:5000/lento"
Write-Host "  http://localhost:5000/erro"
Write-Host ""
Write-Host "Depois acesse Kibana > Observability > APM."
"@