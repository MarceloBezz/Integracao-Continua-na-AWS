# Projeto de Formação: Evolução de CI/CD na AWS - EC2 → ECS → EKS

Este repositório é um projeto de aprendizado que demonstra a **evolução gradual** dos conceitos de Integração Contínua e Entrega Contínua na AWS, começando com deploy em **EC2**, avançando para orquestração containerizada em **ECS**, e evoluindo para gerenciamento de containers em larga escala com **EKS (Kubernetes)**.

## Objetivo

O objetivo do projeto é demonstrar a progressão de pipelines CI/CD para uma API em Go com Gin em diferentes ambientes AWS:

### Fase 1: Deploy em EC2 (Infraestrutura Tradicional)
- testes automatizados com GitHub Actions
- build de artefato Go
- build e push de imagem Docker
- deploy automático em instância EC2 via SSH
- uso de workflow reutilizáveis (`workflow_call`)

### Fase 2: Deploy em ECS (Containerização Gerenciada)
- Orquestração de containers com Amazon ECS
- Task definitions para definir a aplicação
- Load Balancer para distribuição de tráfego
- Auto Scaling baseado em métricas
- Integração com CloudWatch para monitoramento

### Fase 3: Deploy em EKS (Orquestração Kubernetes)
- Cluster Kubernetes gerenciado pela AWS
- Deployments e Services do Kubernetes
- Horizontal Pod Autoscaler (HPA)
- ConfigMaps e Secrets para configuração
- Ingress para gerenciamento de tráfego
- Monitoramento com Prometheus e CloudWatch

## Estrutura do projeto

- `main.go` - ponto de entrada da aplicação
- `go.mod` - dependências do projeto Go
- `controllers/controller.go` - lógica dos handlers HTTP
- `database/db.go` - conexão com PostgreSQL usando GORM
- `models/alunos.go` - modelo `Aluno` e validação de dados
- `routes/route.go` - definição das rotas da API
- `assets/` - arquivos estáticos (CSS)
- `templates/` - templates HTML para renderização de página
- `docker-compose.yml` - ambiente local com PostgreSQL e PgAdmin
- `Dockerfile` - build multi-stage da aplicação Go
- `.github/workflows/` - pipelines de CI/CD

## Tecnologias utilizadas

### Core da Aplicação
- Go (Golang)
- Gin Web Framework
- GORM ORM
- PostgreSQL
- Docker e Docker Compose

### CI/CD e Automação
- GitHub Actions (workflows de integração contínua)
- PgAdmin (para gerenciamento de banco)
- Docker Hub (registry de imagens)

### Infraestrutura AWS (por fase)
- **EC2**: Instâncias de computação, Security Groups, SSH
- **ECS**: Elastic Container Service, Task Definitions, Amazon ECR, Load Balancer, CloudWatch
- **EKS**: Elastic Kubernetes Service, kubectl, Helm, Kubernetes Deployments, Services, Ingress

## O que você aprende aqui

Este projeto demonstra a progressão completa de conceitos e práticas de CI/CD na AWS:

### Fundamentos (aplicável a todas as fases)
- Integração Contínua: executar testes e builds automaticamente em cada push e pull request
- Entrega Contínua: gerar artefatos e disponibilizar para deploy
- Pipelines reutilizáveis no GitHub Actions
- Automação de build Docker e publicação em registry

### Fase 1: EC2 - Infraestrutura Tradicional
- Deploy remoto usando SSH em servidor EC2
- Gerenciamento manual de instâncias
- Integração de aplicação Go com PostgreSQL
- Modelagem de API REST e persistência com banco de dados

### Fase 2: ECS - Containerização Gerenciada
- Orquestração de containers em ambiente gerenciado
- Task Definitions e configuração de containers
- Load Balancing e distribuição de tráfego
- Auto Scaling baseado em métricas
- Monitoramento centralizado com CloudWatch
- Integração com Amazon ECR para registry privado

### Fase 3: EKS - Kubernetes em Larga Escala
- Gerenciamento de Kubernetes na AWS
- Deployments, Pods e Services no Kubernetes
- Auto escalabilidade com Horizontal Pod Autoscaler
- ConfigMaps e Secrets para gerenciamento de configurações
- Ingress para roteamento avançado
- Observabilidade com Prometheus e integração com CloudWatch
- Padrões de deployment e rolling updates

## Como executar localmente

### Requisitos

- Go instalado
- Docker e Docker Compose
- Ambiente com acesso ao PostgreSQL local (via Docker Compose)

### Passos

1. Inicie o banco de dados e o PgAdmin com Docker Compose:

```bash
docker compose up -d
```

2. Defina as variáveis de ambiente para o banco de dados:

- `DB_HOST` (no exemplo do `Dockerfile` está configurado para `host.docker.internal`)
- `DB_PORT` = `5432`
- `DB_USER` = `root`
- `DB_PASSWORD` = `root`
- `DB_NAME` = `root`

3. Execute a aplicação:

```bash
go run main.go
```

4. Acesse a aplicação no navegador usando a porta padrão do Gin (`http://localhost:8080`):

- `http://localhost:8080/index` para a página HTML com os alunos
- `http://localhost:8080/alunos` para listar alunos via JSON

## Endpoints disponíveis

- `GET /:nome` - saudação personalizada
- `GET /alunos` - lista todos os alunos
- `GET /alunos/:id` - busca aluno por ID
- `GET /alunos/cpf/:cpf` - busca aluno por CPF
- `POST /alunos` - cria um novo aluno
- `PATCH /alunos/:id` - atualiza dados de aluno
- `DELETE /alunos/:id` - remove aluno
- `GET /index` - renderiza página HTML com lista de alunos

## Workflows do GitHub Actions

Os workflows evoluem ao longo do projeto para acomodar as diferentes estratégias de deploy:

### Fase 1: EC2 - `.github/workflows/go.yml` + `Docker.yml` + `EC2.yml`

#### `.github/workflows/go.yml` (Workflow Principal)
- checkout do repositório
- setup de Go nas versões definidas na matrix
- build do ambiente com `docker compose build`
- startup do banco com `docker compose up -d`
- execução dos testes com `go test -v main_test.go`
- build do binário Go
- upload do artefato `programa`
- chamada dos workflows reutilizáveis `Docker.yml` e `EC2.yml`

#### `.github/workflows/Docker.yml` (Workflow Reutilizável)
- checkout do código
- configuração do Docker Buildx
- download do artefato `programa`
- login no Docker Hub
- build e push de imagem Docker usando `Dockerfile`

Requer o segredo `PASSWORD_DOCKER_HUB` e publica como `marcelobezz07/api-go-dev:${{ github.ref_name }}`.

#### `.github/workflows/EC2.yml` (Workflow Reutilizável - Deploy SSH)
- checkout do repositório
- download do artefato `programa`
- upload dos arquivos para o servidor remoto via SSH
- execução remota do binário `main` com variáveis de ambiente de banco

Requer os segredos AWS/SSH:
- `SSH_PRIVATE_KEY`
- `REMOTE_HOST`
- `REMOTE_USER`
- `DBHOST`
- `DBUSER`
- `DBPASSWORD`
- `DBNAME`
- `DBPORT`

---

### Fase 2: ECS - `.github/workflows/ecs.yml`

Workflow adicional para deploy em ECS:
- checkout do repositório
- configuração de credenciais AWS
- download do artefato `programa`
- build e push de imagem Docker no Amazon ECR
- atualização de ECS Task Definition
- deploy da aplicação no cluster ECS com service update

Requer os segredos:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `ECR_REGISTRY`
- `ECS_CLUSTER_NAME`
- `ECS_SERVICE_NAME`
- `ECS_TASK_DEFINITION`

---

### Fase 3: EKS - `.github/workflows/eks.yml`

Workflow para deploy em EKS (Kubernetes):
- checkout do repositório
- configuração de credenciais AWS
- download do artefato `programa`
- build e push de imagem Docker no Amazon ECR
- configuração de kubectl com credenciais do cluster EKS
- aplicação de manifests Kubernetes (Deployment, Service, ConfigMap, etc.)
- verificação de rollout status

Requer os segredos:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `ECR_REGISTRY`
- `EKS_CLUSTER_NAME`
- `KUBE_CONFIG` ou credenciais para acesso ao cluster

## Observações importantes

- O projeto usa `Dockerfile` multi-stage para construir o binário em Go e empacotar apenas o runtime em uma imagem mais leve.
- O banco de dados local é gerenciado via Docker Compose com PostgreSQL e PgAdmin.
- A progressão de EC2 → ECS → EKS demonstra a evolução do pensamento de infraestrutura:
  - **EC2**: Controle total, responsabilidade total (infraestrutura e aplicação)
  - **ECS**: Orquestração gerenciada, foco na aplicação
  - **EKS**: Orquestração open-source, portabilidade e flexibilidade

## Fase 1: Deploy em EC2

### Configuração da Instância EC2
- Criar instância EC2 com Ubuntu/Amazon Linux
- Instalar Docker e Docker Compose
- Configurar Security Group para permitir tráfego HTTP (porta 8080)
- Configurar SSH para acesso remoto

### Secrets necessários no GitHub
- `SSH_PRIVATE_KEY`: Chave privada para SSH
- `REMOTE_HOST`: IP ou hostname da instância EC2
- `REMOTE_USER`: Usuário SSH (geralmente `ec2-user` ou `ubuntu`)
- `DBHOST`, `DBUSER`, `DBPASSWORD`, `DBNAME`, `DBPORT`: Credenciais do banco

### Deploy automático
O workflow `EC2.yml` faz upload do binário e executa via SSH com `nohup`.

---

## Fase 2: Deploy em ECS

### Configuração do Cluster ECS
- Criar cluster ECS (mode: EC2 ou Fargate)
- Configurar Amazon ECR para armazenar imagens Docker
- Configurar Application Load Balancer (ALB)
- Criar IAM roles para ECS task execution

### Task Definition
- Definir imagem Docker (do ECR)
- Configurar variáveis de ambiente para PostgreSQL
- Definir resource limits (CPU, memória)
- Configurar logging para CloudWatch

### Secrets necessários no GitHub
- `AWS_ACCESS_KEY_ID`: Credenciais AWS
- `AWS_SECRET_ACCESS_KEY`: Credenciais AWS
- `AWS_REGION`: Região AWS (ex: us-east-1)
- `ECR_REGISTRY`: URL do ECR
- `ECS_CLUSTER_NAME`: Nome do cluster ECS
- `ECS_SERVICE_NAME`: Nome do serviço ECS
- `ECS_TASK_DEFINITION`: Nome da task definition

### Benefícios
- Orquestração automática de containers
- Load balancing integrado
- Auto scaling baseado em métricas
- Integração com CloudWatch para logs e monitoramento

---

## Fase 3: Deploy em EKS

### Configuração do Cluster EKS
- Criar cluster EKS com managed nodes ou Fargate
- Instalar e configurar `kubectl`
- Instalar CNI (Container Network Interface)
- Configurar RBAC (Role-Based Access Control)

### Manifests Kubernetes
- **Deployment**: Define replicas, template de pods, strategy de update
- **Service**: Expõe a aplicação (LoadBalancer ou ClusterIP)
- **ConfigMap**: Configurações da aplicação (variáveis não-sensíveis)
- **Secret**: Credenciais sensíveis (banco de dados)
- **Ingress**: Roteamento avançado de tráfego HTTP/HTTPS
- **HPA (Horizontal Pod Autoscaler)**: Auto scaling de pods baseado em métricas

### Exemplo de estrutura de manifests
```
k8s/
├── namespace.yaml
├── configmap.yaml
├── secret.yaml
├── deployment.yaml
├── service.yaml
├── hpa.yaml
└── ingress.yaml
```

### Secrets necessários no GitHub
- `AWS_ACCESS_KEY_ID`: Credenciais AWS
- `AWS_SECRET_ACCESS_KEY`: Credenciais AWS
- `AWS_REGION`: Região AWS
- `ECR_REGISTRY`: URL do ECR
- `EKS_CLUSTER_NAME`: Nome do cluster EKS
- `KUBE_CONFIG`: Arquivo kubeconfig ou usar AWS CLI para acesso

### Benefícios
- Portabilidade entre clouds (AWS, GCP, Azure, on-premise)
- Ecosystem Kubernetes rico (Helm, operators, service mesh)
- Padrões open-source consolidados
- Melhor suporte a multi-cloud e hybrid deployments

---

## Comparação das Fases

| Aspecto | EC2 | ECS | EKS |
|--------|-----|-----|-----|
| **Nível de Abstração** | Baixo (máquinas virtuais) | Médio (containers) | Alto (Kubernetes) |
| **Orquestração** | Manual | AWS gerenciada | Open-source (Kubernetes) |
| **Portabilidade** | Baixa (AWS specific) | Média (Docker) | Alta (Kubernetes universal) |
| **Escalabilidade** | Manual/Auto Scaling Groups | Auto Scaling nativo | HPA automático |
| **Complexidade** | Simples | Média | Alta |
| **Custo** | Baixo a médio | Médio | Médio a alto |
| **Melhor para** | Startups, prototipagem | Aplicações containerizadas | Microserviços, multi-cloud |
| **Monitoramento** | CloudWatch custom | CloudWatch integrado | CloudWatch + Prometheus |
| **Curva de Aprendizado** | Suave | Média | Íngreme |

---

## Conclusão

Este repositório serve como **exemplo completo e evolutivo** de pipelines de CI/CD modernas na AWS. O projeto demonstra não apenas uma única abordagem de deployment, mas uma **progressão pedagógica** que prepara você para diferentes cenários:

- **Fase 1 (EC2)**: Entender os fundamentos de deployment remoto e SSH
- **Fase 2 (ECS)**: Aprender orquestração gerenciada pela AWS com containers
- **Fase 3 (EKS)**: Dominar Kubernetes e ganhar portabilidade entre clouds

### Próximos passos sugeridos

1. **Comece com EC2**: Entenda os conceitos básicos de deployment com SSH
2. **Evolua para ECS**: Aprenda containerização gerenciada na AWS
3. **Chegue ao EKS**: Domine Kubernetes e open-source container orchestration
4. **Considere alternativas**: GitOps (ArgoCD), Service Mesh (Istio), Observabilidade (Prometheus + Grafana)

Este projeto é ideal para quem está estudando **Integração Contínua**, **Entrega Contínua**, **Infrastructure as Code**, **DevOps** e **Cloud-Native Architecture** na AWS.

---

## Apêndice: Arquitetura Evolutiva

### Diagrama conceitual da evolução

```
┌──────────────────────────────────────────────────────────────┐
│ FASE 1: EC2 - Infrastructure as Servers                      │
├──────────────────────────────────────────────────────────────┤
│                                                                │
│  GitHub Actions → SSH Deploy → EC2 Instance → PostgreSQL     │
│                                                                │
│  Características:                                             │
│  • Deploy via SSH commands                                    │
│  • Gerenciamento manual                                       │
│  • Servidor único ou auto-scaling groups                      │
│                                                                │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ FASE 2: ECS - Container Orchestration (AWS-managed)          │
├──────────────────────────────────────────────────────────────┤
│                                                                │
│  GitHub Actions → ECR Push → ECS Service → ALB               │
│                                          ↓                    │
│                                       PostgreSQL              │
│  Características:                                             │
│  • Container orchestration                                    │
│  • Task definitions                                           │
│  • Load balancing                                             │
│  • Auto scaling por métricas                                  │
│                                                                │
└──────────────────────────────────────────────────────────────┘
                            ↓
┌──────────────────────────────────────────────────────────────┐
│ FASE 3: EKS - Kubernetes (Open-source, Multi-cloud)          │
├──────────────────────────────────────────────────────────────┤
│                                                                │
│  GitHub Actions → ECR Push → EKS Cluster → Ingress           │
│                                 ↓                             │
│                          Deployment/Pods                      │
│                                 ↓                             │
│                          PostgreSQL (RDS)                     │
│                                                                │
│  Características:                                             │
│  • Orquestração open-source                                   │
│  • Portabilidade multi-cloud                                  │
│  • Manifests Kubernetes                                       │
│  • HPA e VPA                                                  │
│  • Ecosystem extensível                                       │
│                                                                │
└──────────────────────────────────────────────────────────────┘
```

### Matriz de Decisão: Qual fase escolher?

**Use EC2 se:**
- Você tem uma aplicação monolítica simples
- Precisa aprender os fundamentos de cloud
- Quer minimizar complexidade operacional

**Use ECS se:**
- Você deseja containerização com simplicidade AWS
- Precisa de orquestração automática
- Quer otimizar custos com Fargate

**Use EKS se:**
- Você tem arquitetura de microserviços
- Precisa de portabilidade entre clouds
- Vai crescer para observabilidade avançada
- Quer participar do ecosistema Kubernetes

### Evolução de Habilidades

| Habilidade | EC2 | ECS | EKS |
|-----------|-----|-----|-----|
| Linux/SSH | ✓✓✓ | ✓ | ✓ |
| Docker | ✓ | ✓✓✓ | ✓✓✓ |
| AWS Services | ✓✓ | ✓✓✓ | ✓✓ |
| Kubernetes | - | - | ✓✓✓ |
| YAML/IaC | ✓ | ✓✓ | ✓✓✓ |
| Networking | ✓✓ | ✓✓✓ | ✓✓✓ |
| Observability | ✓ | ✓✓ | ✓✓✓ |
