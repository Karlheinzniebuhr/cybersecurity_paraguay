#!/bin/bash

# Script: update_shodan_stats_test.sh
# Purpose: Test script to update GitHub Gist and GitHub Pages using existing Shodan output files, skipping Shodan API calls.

# --- Configuration ---
OUTPUT_DIR="/home/karl/cybersecurity_paraguay/shodan_stats"
GIST_ID="b7caf313129e29a5ac56081c5b5e0114"
REPO_DIR="/home/karl/cybersecurity_paraguay/Vulnerabilidades-Shodan-en-Paraguay"

ISP_FILE="$OUTPUT_DIR/isp.txt"
CITIES_FILE="$OUTPUT_DIR/cities.txt"
VULNS_FILE="$OUTPUT_DIR/vulns.txt"
PRODUCT_FILE="$OUTPUT_DIR/product.txt"
OS_FILE="$OUTPUT_DIR/os.txt"
PORT_FILE="$OUTPUT_DIR/port.txt"
ASN_FILE="$OUTPUT_DIR/asn.txt"
HTTP_COMPONENT_FILE="$OUTPUT_DIR/http_component.txt"
HTTP_COMPONENT_CATEGORY_FILE="$OUTPUT_DIR/http_component_category.txt"
SSL_VERSION_FILE="$OUTPUT_DIR/ssl_version.txt"
HAS_SCREENSHOT_FILE="$OUTPUT_DIR/has_screenshot.txt"

HTML_FILE="$REPO_DIR/index.html"

# --- Step 1: Skip Shodan Commands ---
echo "[INFO] Skipping Shodan commands. Using existing output files in $OUTPUT_DIR."

# --- Step 2: Update GitHub Gist ---
echo "[INFO] Updating GitHub Gist..."
gh gist edit "$GIST_ID" -a "$ISP_FILE" -a "$CITIES_FILE" -a "$VULNS_FILE" \
  -a "$PRODUCT_FILE" -a "$OS_FILE" -a "$PORT_FILE" -a "$ASN_FILE" \
  -a "$HTTP_COMPONENT_FILE" -a "$HTTP_COMPONENT_CATEGORY_FILE" \
  -a "$SSL_VERSION_FILE" -a "$HAS_SCREENSHOT_FILE"

# --- Step 3: Generate HTML File ---
echo "[INFO] Generating HTML file..."
cat <<EOF > "$HTML_FILE"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Estadísticas de Shodan - Paraguay</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h2 { color: #333; }
        pre { 
            font-family: monospace; 
            white-space: pre-wrap; 
            background-color: #fff; 
            padding: 15px; 
            border: 1px solid #ddd; 
            border-radius: 5px; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.1); 
        }
        p.description { font-style: italic; color: #555; }
    </style>
</head>
<body>
    <h1>Estadísticas de Ciberseguridad de Shodan para Paraguay</h1>
    <p>Última actualización: $(date)</p>

    <h2>Top 50 Proveedores de Internet (ISPs)</h2>
    <p class="description">Muestra los 50 principales proveedores de internet en Paraguay con más dispositivos conectados detectados por Shodan.</p>
    <pre>$(cat "$ISP_FILE")</pre>

    <h2>Top 50 Ciudades</h2>
    <p class="description">Lista las 50 ciudades de Paraguay con mayor cantidad de dispositivos en línea, según su presencia en internet.</p>
    <pre>$(cat "$CITIES_FILE")</pre>

    <h2>Top 50 Vulnerabilidades</h2>
    <p class="description">Identifica las 50 vulnerabilidades más comunes en dispositivos conectados a internet en Paraguay.</p>
    <pre>$(cat "$VULNS_FILE")</pre>

    <h2>Top 50 Productos</h2>
    <p class="description">Presenta los 50 productos (como routers o servidores) más detectados en Paraguay, indicando su prevalencia.</p>
    <pre>$(cat "$PRODUCT_FILE")</pre>

    <h2>Top 50 Sistemas Operativos</h2>
    <p class="description">Muestra los 50 sistemas operativos más utilizados en dispositivos conectados en Paraguay.</p>
    <pre>$(cat "$OS_FILE")</pre>

    <h2>Top 50 Puertos</h2>
    <p class="description">Lista los 50 puertos más expuestos en dispositivos de Paraguay, indicando posibles riesgos de seguridad.</p>
    <pre>$(cat "$PORT_FILE")</pre>

    <h2>Top 50 Números de Sistemas Autónomos (ASNs)</h2>
    <p class="description">Muestra los 50 principales ASNs (identificadores de redes) en Paraguay, indicando su actividad en internet.</p>
    <pre>$(cat "$ASN_FILE")</pre>

    <h2>Top 50 Componentes HTTP</h2>
    <p class="description">Identifica los 50 componentes HTTP (como servidores web) más comunes en dispositivos de Paraguay.</p>
    <pre>$(cat "$HTTP_COMPONENT_FILE")</pre>

    <h2>Top 50 Categorías de Componentes HTTP</h2>
    <p class="description">Clasifica los componentes HTTP en categorías, mostrando las 50 más frecuentes en Paraguay.</p>
    <pre>$(cat "$HTTP_COMPONENT_CATEGORY_FILE")</pre>

    <h2>Top 50 Versiones de SSL</h2>
    <p class="description">Lista las 50 versiones de SSL más utilizadas en conexiones seguras de dispositivos en Paraguay.</p>
    <pre>$(cat "$SSL_VERSION_FILE")</pre>

    <h2>Top 50 Dispositivos con Capturas de Pantalla</h2>
    <p class="description">Muestra la cantidad de dispositivos en Paraguay que tienen capturas de pantalla disponibles en Shodan.</p>
    <pre>$(cat "$HAS_SCREENSHOT_FILE")</pre>
</body>
</html>
EOF

# --- Step 4: Push to GitHub Pages ---
echo "[DEBUG] Changing to repo directory: $REPO_DIR"
cd "$REPO_DIR"
echo "[DEBUG] Current directory: $(pwd)"
echo "[DEBUG] Git remote -v:"
git remote -v
echo "[DEBUG] Git branch: $(git rev-parse --abbrev-ref HEAD)"
echo "[DEBUG] Git status:"
git status

git add index.html
git commit -m "[TEST] Update Shodan stats - $(date)"
git push origin master  # Replace 'main' with your branch if it's different

# --- Step 5: Log Completion ---
echo "[INFO] Test script completed at $(date)" >> "$OUTPUT_DIR/update_log.txt"
