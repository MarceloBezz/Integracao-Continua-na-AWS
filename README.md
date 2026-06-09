# Projeto de Formação: Entrega Contínua com GitHub Actions e Deploy na AWS EC2

Este repositório é um projeto de aprendizado focado em ensinar os conceitos e a prática de Integração Contínua e Entrega Contínua usando GitHub Actions, Docker, banco de dados PostgreSQL e deploy em servidor AWS EC2.

## Objetivo

O objetivo do projeto é demonstrar uma pipeline completa de CI/CD para uma API em Go com Gin, incluindo:

- testes automatizados com GitHub Actions
- build de artefato Go
- build e push de imagem Docker
- deploy automático em instância EC2 via SSH
- uso de workflow reutilizáveis (`workflow_call`)

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

- Go (Golang)
- Gin Web Framework
- GORM ORM
- PostgreSQL
- Docker e Docker Compose
- GitHub Actions
- AWS EC2 (deploy via SSH)
- PgAdmin (para gerenciamento de banco)
- Docker Hub (push de imagem)

## O que você aprende aqui

Este projeto mostra como aplicar na prática os conceitos de:

- Integração Contínua: executar testes e builds automaticamente em cada push e pull request
- Entrega Contínua: gerar artefatos e disponibilizar para deploy
- Pipelines reutilizáveis no GitHub Actions
- Automação de build Docker e publicação em registry
- Deploy remoto usando SSH em servidor EC2
- Modelagem de API REST em Go e persistência com PostgreSQL

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

### `.github/workflows/go.yml`

Este é o workflow principal do projeto. Ele é acionado em qualquer push e pull request e faz:

- checkout do repositório
- setup de Go nas versões definidas na matrix
- build do ambiente com `docker compose build`
- startup do banco com `docker compose up -d`
- execução dos testes com `go test -v main_test.go`
- build do binário Go
- upload do artefato `programa`
- chamada dos workflows reutilizáveis `Docker.yml` e `EC2.yml`

### `.github/workflows/Docker.yml`

Workflow reutilizável para:

- checkout do código
- configuração do Docker Buildx
- download do artefato `programa`
- login no Docker Hub
- build e push de imagem Docker usando `Dockerfile`

Requer o segredo `PASSWORD_DOCKER_HUB` e publica como `marcelobezz07/api-go-dev:${{ github.ref_name }}`.

### `.github/workflows/EC2.yml`

Workflow reutilizável de deploy remoto para EC2. Ele faz:

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

## Observações importantes

- O projeto usa `Dockerfile` multi-stage para construir o binário em Go e empacotar apenas o runtime em uma imagem mais leve.
- O banco de dados local é gerenciado via Docker Compose com PostgreSQL e PgAdmin.
- O deploy em EC2 é feito via SSH e roda o binário em background com `nohup`.
- O workflow está organizado para separar testes, build, entrega Docker e deploy em EC2 em etapas distintas.

## Conclusão

Este repositório serve como exemplo completo de um pipeline de CI/CD moderno para aplicações Go, combinando desenvolvimento local com Docker e automação com GitHub Actions. Ele é ideal para quem está estudando Integração Contínua, Entrega Contínua e deploy em servidores AWS EC2.
