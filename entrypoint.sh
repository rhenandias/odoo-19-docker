#!/bin/bash
set -e

# Fix permissions for /var/lib/odoo (where sessions/filestore live)
if [ -d "/var/lib/odoo" ]; then
    echo "Fixing permissions for /var/lib/odoo..."
    chown -R odoo:odoo /var/lib/odoo
    chmod -R 755 /var/lib/odoo
fi

# ===========================================
# Extração dos Addons Nativos do Odoo
# ===========================================
# Copia os módulos nativos do Odoo para o diretório mapeado
# para que possam ser consultados durante o desenvolvimento
NATIVE_ADDONS_SRC="/usr/lib/python3/dist-packages/odoo/addons"
NATIVE_ADDONS_DEST="/mnt/native-addons"

if [ -d "$NATIVE_ADDONS_DEST" ]; then
    # Verifica se o diretório está vazio (exceto arquivos ocultos)
    if [ -z "$(ls -A $NATIVE_ADDONS_DEST 2>/dev/null)" ]; then
        echo "Extracting native Odoo addons to $NATIVE_ADDONS_DEST..."
        if [ -d "$NATIVE_ADDONS_SRC" ]; then
            cp -r "$NATIVE_ADDONS_SRC"/* "$NATIVE_ADDONS_DEST/"
            chown -R odoo:odoo "$NATIVE_ADDONS_DEST"
            chmod -R 755 "$NATIVE_ADDONS_DEST"
            echo "Native addons extracted successfully!"
        else
            echo "Warning: Native addons source directory not found at $NATIVE_ADDONS_SRC"
        fi
    else
        echo "Native addons directory already populated, skipping extraction."
    fi
fi

# Execute the original entrypoint as the 'odoo' user
echo "Starting Odoo as user 'odoo'"
exec su odoo -s /bin/bash -c "/entrypoint.sh $@"
