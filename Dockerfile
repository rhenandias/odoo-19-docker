# ==============================================
# Dockerfile customizado para Odoo 19.0
# ==============================================

FROM odoo:19.0

# Metadados
LABEL maintainer="odoo-admin@exemplo.com"
LABEL description="Odoo 19.0 customizado com dependências adicionais e correções de permissão"

# ------------------------------------------
# DEPENDÊNCIAS DO SISTEMA
# ------------------------------------------
USER root

# Atualizar sistema e instalar dependências adicionais
RUN apt-get update && apt-get install -y \
  # Ferramentas de desenvolvimento
  git \
  vim \
  curl \
  wget \
  # Bibliotecas Python úteis
  python3-pip \
  # Ferramentas de build (caso precise compilar módulos)
  build-essential \
  python3-dev \
  libxml2-dev \
  libxslt1-dev \
  libldap2-dev \
  libsasl2-dev \
  libjpeg-dev \
  libpng-dev \
  libfreetype6-dev \
  liblcms2-dev \
  libwebp-dev \
  libtiff5-dev \
  # Fontes para relatórios PDF
  fonts-liberation \
  fonts-dejavu \
  # Limpeza
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# ------------------------------------------
# DEPENDÊNCIAS PYTHON (quando necessário)
# ------------------------------------------
# Descomente e adicione as que precisar:
#
# RUN pip3 install --no-cache-dir \
#     pandas \
#     openpyxl \
#     xlrd \
#     requests \
#     python-barcode \
#     qrcode

# ------------------------------------------
# Opção: Usar arquivo requirements.txt
# ------------------------------------------
# COPY requirements.txt /tmp/requirements.txt
# RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# ------------------------------------------
# CRIAÇÃO DE DIRETÓRIOS E PERMISSÕES
# ------------------------------------------
# Criar diretórios necessários com permissões corretas
# Isso resolve o erro: PermissionError: [Errno 13] Permission denied: '/var/lib/odoo/sessions'
RUN mkdir -p /var/lib/odoo/sessions \
  && mkdir -p /var/lib/odoo/filestore \
  && mkdir -p /mnt/extra-addons \
  && mkdir -p /etc/odoo \
  && chown -R odoo:odoo /var/lib/odoo \
  && chown -R odoo:odoo /mnt/extra-addons \
  && chown -R odoo:odoo /etc/odoo \
  && chmod -R 755 /var/lib/odoo \
  && chmod -R 755 /mnt/extra-addons

# ------------------------------------------
# SCRIPTS CUSTOMIZADOS (opcional)
# ------------------------------------------
# COPY --chown=odoo:odoo scripts/entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh

# Voltar para usuário odoo (segurança)
# Voltar para usuário odoo (segurança)
# USER odoo (Comentado para permitir fix de permissões no entrypoint)

# ------------------------------------------
# CONFIGURAÇÕES FINAIS
# ------------------------------------------
# Expor portas
EXPOSE 8069 8072

# Volumes
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Healthcheck para monitorar saúde do container
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8069/web/health || exit 1

# Entrypoint padrão do Odoo
# Entrypoint customizado para corrigir permissões
COPY entrypoint.sh /custom-entrypoint.sh
RUN chmod +x /custom-entrypoint.sh

ENTRYPOINT ["/custom-entrypoint.sh"]
CMD ["odoo"]
