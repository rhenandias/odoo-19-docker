#!/bin/bash
set -e

# Fix permissions for /var/lib/odoo (where sessions/filestore live)
if [ -d "/var/lib/odoo" ]; then
    echo "Fixing permissions for /var/lib/odoo..."
    chown -R odoo:odoo /var/lib/odoo
    chmod -R 755 /var/lib/odoo
fi

# ===========================================
# Extração do código fonte completo do Odoo
# ===========================================
# Copia todo o pacote do Odoo (não apenas os addons) para o diretório
# mapeado, permitindo que IDEs/extensões enxerguem o projeto completo.
ODOO_SOURCE_SRC="/usr/lib/python3/dist-packages/odoo"
ODOO_SOURCE_DEST="/mnt/odoo"

if [ -d "$ODOO_SOURCE_DEST" ]; then
    # Verifica se o diretório está vazio (exceto arquivos ocultos)
    if [ -z "$(ls -A "$ODOO_SOURCE_DEST" 2>/dev/null)" ]; then
        echo "Extracting full Odoo source to $ODOO_SOURCE_DEST..."
        if [ -d "$ODOO_SOURCE_SRC" ]; then
            cp -r "$ODOO_SOURCE_SRC"/* "$ODOO_SOURCE_DEST/"
            chown -R odoo:odoo "$ODOO_SOURCE_DEST"
            chmod -R 755 "$ODOO_SOURCE_DEST"
            echo "Full Odoo source extracted successfully!"
        else
            echo "Warning: Odoo source directory not found at $ODOO_SOURCE_SRC"
        fi
    else
        if [ -f "$ODOO_SOURCE_DEST/odoo-bin" ] || [ -f "$ODOO_SOURCE_DEST/__init__.py" ]; then
            echo "Odoo source directory already populated, skipping extraction."
        else
            echo "Odoo source directory contains existing files. Remove them to re-extract the full source."
        fi
    fi
fi

# Execute the original entrypoint as the 'odoo' user
echo "Starting Odoo as user 'odoo'"
exec su odoo -s /bin/bash -c "/entrypoint.sh $@"
