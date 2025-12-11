# 🐳 Odoo 19 - Docker Setup

Este projeto contém a configuração Docker para rodar o **Odoo 19** com **PostgreSQL (latest)**.

## 📁 Estrutura do Projeto

```
odoo-19-docker /
├── docker-compose.yml    # Configuração do Docker Compose
├── .env                  # Variáveis de ambiente
├── Dockerfile            # Build customizado (opcional)
├── config/
│   └── odoo.conf         # Configuração do Odoo
├── addons/               # Módulos customizados
├── odoo/                 # Cópia completa do código fonte do Odoo (somente leitura)
└── data/
    ├── postgres/         # Dados do PostgreSQL
    └── odoo/             # Dados do Odoo (filestore)
```

---

## 🗂️ Volumes Mapeados

Todos os volumes estão mapeados localmente, permitindo fácil acesso e reset dos dados.

| Container      | Caminho no Container              | Caminho Local     | Função                                          |
| -------------- | --------------------------------- | ----------------- | ----------------------------------------------- |
| **PostgreSQL** | `/var/lib/postgresql/data/pgdata` | `./data/postgres` | Dados do banco de dados                         |
| **Odoo**       | `/var/lib/odoo`                   | `./data/odoo`     | Filestore e sessions                            |
| **Odoo**       | `/etc/odoo`                       | `./config`        | Arquivo `odoo.conf`                             |
| **Odoo**       | `/mnt/extra-addons`               | `./addons`        | Módulos customizados                            |
| **Odoo**       | `/mnt/odoo`                       | `./odoo`          | Código fonte completo do Odoo (somente leitura) |

---

## ⚙️ Configuração do `.env`

O arquivo `.env` contém todas as variáveis de ambiente necessárias:

```env
# ===========================================
# Configurações do PostgreSQL
# ===========================================
POSTGRES_DB=postgres
POSTGRES_USER=odoo
POSTGRES_PASSWORD=odoo
POSTGRES_PORT=5432

# ===========================================
# Configurações do Odoo
# ===========================================
ODOO_PORT=8069                  # Porta principal do Odoo
ODOO_LONGPOLLING_PORT=8072      # Porta para websocket/live chat

# ===========================================
# Configurações gerais
# ===========================================
TZ=America/Sao_Paulo            # Timezone
```

### Personalizações Comuns

| Variável            | Descrição                   | Valor Padrão        |
| ------------------- | --------------------------- | ------------------- |
| `POSTGRES_PASSWORD` | Senha do banco de dados     | `odoo`              |
| `POSTGRES_PORT`     | Porta externa do PostgreSQL | `5432`              |
| `ODOO_PORT`         | Porta de acesso ao Odoo     | `8069`              |
| `TZ`                | Timezone do sistema         | `America/Sao_Paulo` |

---

## 🚀 Como Iniciar

```bash
# Subir os containers em background
docker compose up -d

# Ver os logs em tempo real
docker compose logs -f

# Ver logs apenas do Odoo
docker compose logs -f odoo

# Parar os containers
docker compose down
```

Após iniciar, acesse: **http://localhost:8069**

---

## 🔄 Reset dos Dados

Para resetar os dados, primeiro pare os containers e depois apague as pastas desejadas.

> ⚠️ **Importante**: Use `sudo` porque o Docker cria arquivos com permissões do container.

### Resetar TUDO (banco + filestore)

```bash
docker compose down
sudo rm -rf data/postgres data/odoo
docker compose up -d
```

### Resetar apenas o Banco de Dados (PostgreSQL)

```bash
docker compose down
sudo rm -rf data/postgres
docker compose up -d
```

### Resetar apenas o Filestore do Odoo

```bash
docker compose down
sudo rm -rf data/odoo
docker compose up -d
```

### Manter os dados, apenas reiniciar os containers

```bash
docker compose restart
```

---

## 🐘 Debug do PostgreSQL via `psql`

Para inspecionar o banco dentro do container do Postgres, use:

```bash
docker exec -it odoo_postgres psql -h postgres -U odoo -d odoo-test
```

No prompt do `psql`:

- `\dt` lista tabelas
- `\d table_name;` mostra o esquema da tabela
- `\q` sai

Se você já estiver dentro do próprio container `odoo_postgres`, o `-h postgres` é opcional.

---

## 📝 Notas Adicionais

### Admin Master Password

A senha master do Odoo está definida em `config/odoo.conf`:

```ini
admin_passwd = admin
```

> ⚠️ **Altere esta senha em produção!** Ela é usada para criar, duplicar e deletar bancos de dados.

### Usando Build Customizado

Se precisar de dependências adicionais, altere o `docker-compose.yml` para usar o `Dockerfile`:

```yaml
odoo:
  build:
    context: .
    dockerfile: Dockerfile
  image: odoo-custom:19.0
  # ... resto da configuração
```

### Adicionar Módulos Customizados

Coloque seus módulos na pasta `addons/`. Eles serão automaticamente reconhecidos pelo Odoo.

```
addons/
├── meu_modulo/
│   ├── __init__.py
│   ├── __manifest__.py
│   └── ...
└── outro_modulo/
    └── ...
```

### Consultar Código Fonte do Odoo

O diretório `odoo/` contém **todo o código fonte do Odoo** (não apenas os addons) extraído automaticamente na primeira inicialização do container. Ele é pensado para IDEs e extensões reconhecerem o projeto completo do Odoo localmente.

> ⚠️ **IMPORTANTE**: Os arquivos em `odoo/` são **somente leitura**. **NÃO edite esses arquivos diretamente!** Qualquer alteração será perdida e não terá efeito no Odoo. Use-os apenas como referência.

**Casos de uso:**

- Consultar campos, métodos e serviços do core do Odoo antes de herdá-los
- Verificar views XML para estender templates
- Analisar a estrutura de manifests (`__manifest__.py`)
- Permitir que extensões/IDEs detectem o projeto completo do Odoo para autocompletes

**Para forçar uma nova extração** (ex: após atualizar a imagem do Odoo ou migrar de apenas-addons para o código completo):

```bash
rm -rf odoo/*
docker compose restart odoo
```

---

## 🔗 Referências

- [Documentação Oficial do Odoo Docker](https://hub.docker.com/_/odoo)
- [Odoo 19 Documentation](https://www.odoo.com/documentation/19.0/)
