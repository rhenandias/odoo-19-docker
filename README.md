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
├── native-addons/        # Módulos nativos do Odoo (somente leitura)
└── data/
    ├── postgres/         # Dados do PostgreSQL
    └── odoo/             # Dados do Odoo (filestore)
```

---

## 🗂️ Volumes Mapeados

Todos os volumes estão mapeados localmente, permitindo fácil acesso e reset dos dados.

| Container      | Caminho no Container              | Caminho Local     | Função                            |
| -------------- | --------------------------------- | ----------------- | --------------------------------- |
| **PostgreSQL** | `/var/lib/postgresql/data/pgdata` | `./data/postgres` | Dados do banco de dados           |
| **Odoo**       | `/var/lib/odoo`                   | `./data/odoo`     | Filestore e sessions              |
| **Odoo**       | `/etc/odoo`                       | `./config`        | Arquivo `odoo.conf`               |
| **Odoo**       | `/mnt/extra-addons`               | `./addons`        | Módulos customizados              |
| **Odoo**       | `/mnt/native-addons`              | `./native-addons` | Módulos nativos (somente leitura) |

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

### Consultar Módulos Nativos do Odoo

O diretório `native-addons/` contém uma cópia dos módulos nativos do Odoo, extraídos automaticamente na primeira inicialização do container. Estes arquivos são **apenas para consulta e referência** durante o desenvolvimento.

> ⚠️ **IMPORTANTE**: Os arquivos em `native-addons/` são **somente leitura**. **NÃO edite esses arquivos diretamente!** Qualquer alteração será perdida e não terá efeito no Odoo. Use-os apenas como referência para entender a estrutura dos módulos nativos ao criar seus próprios módulos customizados.

**Casos de uso:**

- Consultar campos e métodos de modelos nativos antes de herdá-los
- Verificar views XML para estender templates
- Analisar a estrutura de manifests (`__manifest__.py`)
- Estudar implementações de referência

**Para forçar uma nova extração** (ex: após atualizar a versão do Odoo):

```bash
rm -rf native-addons/*
docker compose restart odoo
```

---

## 🔗 Referências

- [Documentação Oficial do Odoo Docker](https://hub.docker.com/_/odoo)
- [Odoo 19 Documentation](https://www.odoo.com/documentation/19.0/)
