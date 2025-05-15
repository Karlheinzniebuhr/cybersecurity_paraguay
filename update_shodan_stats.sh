#!/bin/bash

# Script: update_shodan_stats.sh
# Purpose: Run Shodan commands, save outputs, update a GitHub Gist, and refresh a GitHub Pages site

# --- Configuration ---
# Directory to store output files (make sure this directory exists)
OUTPUT_DIR="/home/karl/cybersecurity_paraguay/shodan_stats"
mkdir -p "$OUTPUT_DIR"

# GitHub Gist ID (replace with your Gist ID after creating it)
GIST_ID="539e833b844c3644d5f2dbae124c59c2"

# GitHub Pages repository directory (replace with your local repo path)
REPO_DIR="/home/karl/cybersecurity_paraguay/shodan_stats_repo"

# Shodan command output files
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

# HTML file for GitHub Pages
HTML_FILE="$REPO_DIR/index.html"

# --- Step 1: Run Shodan Commands ---
# These commands are derived from the X thread and the new requests
echo "Running Shodan commands..."

# Top 50 ISPs in Paraguay
shodan stats --facets isp:50 country:PY > "$ISP_FILE"

# Top 50 cities with devices online
shodan stats --facets city:50 country:PY > "$CITIES_FILE"

# Top 50 vulnerabilities in Paraguay
shodan stats --facets vuln:50 country:PY > "$VULNS_FILE"

# Top 50 products (e.g., routers like Mikrotik)
shodan stats --facets product:50 country:PY > "$PRODUCT_FILE"

# Top 50 operating systems
shodan stats --facets os:50 country:PY > "$OS_FILE"

# Top 50 ports with vulnerabilities
shodan stats --facets port:50 country:PY > "$PORT_FILE"

# Top 50 ASNs (Autonomous System Numbers)
shodan stats --facets asn:50 country:PY > "$ASN_FILE"

# Top 50 HTTP components
shodan stats --facets http.component:50 country:PY > "$HTTP_COMPONENT_FILE"

# Top 50 HTTP component categories
shodan stats --facets http.component_category:50 country:PY > "$HTTP_COMPONENT_CATEGORY_FILE"

# Top 50 SSL versions
shodan stats --facets ssl.version:50 country:PY > "$SSL_VERSION_FILE"

# Top 50 devices with screenshots
shodan stats --facets has_screenshot:50 country:PY > "$HAS_SCREENSHOT_FILE"

# --- Step 2: Update GitHub Gist ---
# Update the Gist with the new files
echo "Updating GitHub Gist..."
gh gist edit "$GIST_ID" -a "$ISP_FILE" -a "$CITIES_FILE" -a "$VULNS_FILE" \
  -a "$PRODUCT_FILE" -a "$OS_FILE" -a "$PORT_FILE" -a "$ASN_FILE" \
  -a "$HTTP_COMPONENT_FILE" -a "$HTTP_COMPONENT_CATEGORY_FILE" \
  -a "$SSL_VERSION_FILE" -a "$HAS_SCREENSHOT_FILE"

# --- Step 3: Generate HTML File ---
# Create a simple HTML file with the Shodan data
echo "Generating HTML file..."
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
# Commit and push the updated HTML file to your GitHub Pages repo
echo "Pushing updates to GitHub Pages..."
cd "$REPO_DIR"
git add index.html
git commit -m "Update Shodan stats - $(date)"
git push origin main  # Replace 'main' with your branch if it's different (e.g., 'master')

# --- Step 5: Log Completion ---
echo "Script completed at $(date)" >> "$OUTPUT_DIR/update_log.txt"