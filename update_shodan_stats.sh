#!/bin/bash

# --- Set a comprehensive PATH for cron ---
# Include directories where common commands and your user-installed tools live.
# Based on your 'which' output, we need /home/karl/.local/bin and /usr/bin.
# We also include other standard places just to be safe.
export PATH="/home/karl/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Script: update_shodan_stats.sh
# Purpose: Run Shodan commands, save outputs, update a GitHub Gist, and refresh a GitHub Pages site

# --- Configuration ---
# Directory to store output files (make sure this directory exists)
OUTPUT_DIR="/home/karl/cybersecurity_paraguay/shodan_stats"
mkdir -p "$OUTPUT_DIR"

# GitHub Pages repository directory (replace with your local repo path)
REPO_DIR="/home/karl/cybersecurity_paraguay/Vulnerabilidades-Shodan-en-Paraguay"

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

# Top 50 ISPs in Paraguay (hosting vulnerable devices)
shodan stats --facets isp:50 country:PY has_vuln:true > "$ISP_FILE"

# Top 50 cities with devices online (that are vulnerable)
shodan stats --facets city:50 country:PY has_vuln:true > "$CITIES_FILE"

# Top 50 vulnerabilities in Paraguay (This command remains unchanged)
shodan stats --facets vuln:50 country:PY > "$VULNS_FILE"

# Top 50 products (that are vulnerable)
shodan stats --facets product:50 country:PY has_vuln:true > "$PRODUCT_FILE"

# Top 50 operating systems (on vulnerable devices)
shodan stats --facets os:50 country:PY has_vuln:true > "$OS_FILE"

# Top 50 most common open ports (on vulnerable devices)
shodan stats --facets port:50 country:PY has_vuln:true > "$PORT_FILE"

# Top 50 ASNs (Autonomous System Numbers) (hosting vulnerable devices)
shodan stats --facets asn:50 country:PY has_vuln:true > "$ASN_FILE"

# Top 50 HTTP components (on vulnerable devices)
shodan stats --facets http.component:50 country:PY has_vuln:true > "$HTTP_COMPONENT_FILE"

# Top 50 HTTP component categories (on vulnerable devices)
shodan stats --facets http.component_category:50 country:PY has_vuln:true > "$HTTP_COMPONENT_CATEGORY_FILE"

# Top 50 SSL versions (on vulnerable devices)
shodan stats --facets ssl.version:50 country:PY has_vuln:true > "$SSL_VERSION_FILE"

# Count of devices with and without screenshots (that are vulnerable)
shodan stats --facets has_screenshot:50 country:PY has_vuln:true > "$HAS_SCREENSHOT_FILE"

# --- Step 2: Generate HTML File ---
# Helper function to convert shodan stats output to an HTML table
# Takes the input file path as $1 and the column headers (e.g., "Proveedor|Dispositivos") as $2
generate_html_table() {
    local input_file="$1"
    local headers_str="$2"
    local header1 header2
    IFS='|' read -r header1 header2 <<< "$headers_str"
    
    local is_vuln_table_awk_var="0" # Default to false (not vuln table)
    if [ "$header1" = "Vulnerabilidad (CVE)" ]; then
        is_vuln_table_awk_var="1" # True if it's the vuln table
    fi

    # AWK script to generate table rows.
    # If it's the vulnerability table and the first field looks like a CVE ID,
    # it creates a hyperlink. Otherwise, it uses the original formatting.
    awk -v h1="$header1" -v h2="$header2" -v is_vuln_table="$is_vuln_table_awk_var" '
    BEGIN {
        print "<table class=\"stats-table\">"
        print "  <thead>"
        print "    <tr>"
        printf "      <th>%s</th>\n", h1
        printf "      <th>%s</th>\n", h2  # No style, left-aligned
        print "    </tr>"
        print "  </thead>"
        print "  <tbody>"
    }
    NR > 1 && NF >= 2 { # Process lines after header, ensuring at least 2 fields (name + count)
        count = $NF;
        name_output_final = ""; # Will hold the content for the first <td>

        if (is_vuln_table == 1 && $1 ~ /^CVE-[0-9]{4}-[0-9]+$/) {
            # This is the Vulnerability table and $1 matches CVE pattern
            cve_id_for_url = $1;       # Raw CVE ID for URL (e.g., CVE-2021-1234)
            cve_id_for_display = $1;   # CVE ID for link text, will be HTML-escaped

            # HTML-escape the CVE ID that will be displayed as the link text
            gsub(/&/, "&amp;", cve_id_for_display);
            gsub(/</, "&lt;", cve_id_for_display);
            gsub(/>/, "&gt;", cve_id_for_display);

            # Construct the hyperlink
            name_output_final = sprintf("<a href=\"https://www.cve.org/CVERecord/SearchResults?query=%s\" target=\"_blank\" rel=\"noopener noreferrer\">%s</a>", cve_id_for_url, cve_id_for_display);
            
            # If there are descriptive parts after CVE ID and before count (e.g. CVE-ID Description Count)
            # This part might not be used if Shodan vuln facet output is just "CVE-ID Count"
            if (NF > 2) { 
                description_part = "";
                for (i = 2; i < NF; i++) { # Concatenate fields between $1 and $NF
                    description_part = description_part (description_part == "" ? "" : " ") $i;
                }
                # HTML-escape the description part
                gsub(/&/, "&amp;", description_part);
                gsub(/</, "&lt;", description_part);
                gsub(/>/, "&gt;", description_part);
                name_output_final = name_output_final " " description_part; # Append description to link
            }
        } else {
            # Original logic for other tables: concatenate $1 up to $(NF-1)
            temp_name_part = $1;
            for (i = 2; i < NF; i++) {
                temp_name_part = temp_name_part " " $i;
            }
            # HTML-escape the entire name part
            gsub(/&/, "&amp;", temp_name_part);
            gsub(/</, "&lt;", temp_name_part);
            gsub(/>/, "&gt;", temp_name_part);
            name_output_final = temp_name_part;
        }
        printf "    <tr><td>%s</td><td>%s</td></tr>\n", name_output_final, count;
    }
    END {
        print "  </tbody>"
        print "</table>"
    }
    ' "$input_file"
}

# Generate HTML tables for each section
ISP_TABLE_HTML=$(generate_html_table "$ISP_FILE" "Proveedor|Dispositivos Conectados")
VULNS_TABLE_HTML=$(generate_html_table "$VULNS_FILE" "Vulnerabilidad (CVE)|Detecciones")
CITIES_TABLE_HTML=$(generate_html_table "$CITIES_FILE" "Ciudad|Dispositivos Conectados")
PRODUCT_TABLE_HTML=$(generate_html_table "$PRODUCT_FILE" "Producto|Instancias")
OS_TABLE_HTML=$(generate_html_table "$OS_FILE" "Sistema Operativo|Instancias")
PORT_TABLE_HTML=$(generate_html_table "$PORT_FILE" "Puerto|Detecciones")
ASN_TABLE_HTML=$(generate_html_table "$ASN_FILE" "ASN (Nombre)|Dispositivos")
HTTP_COMPONENT_TABLE_HTML=$(generate_html_table "$HTTP_COMPONENT_FILE" "Componente HTTP|Instancias")
HTTP_COMPONENT_CATEGORY_TABLE_HTML=$(generate_html_table "$HTTP_COMPONENT_CATEGORY_FILE" "Categoría Componente HTTP|Instancias")
SSL_VERSION_TABLE_HTML=$(generate_html_table "$SSL_VERSION_FILE" "Versión SSL/TLS|Detecciones")
HAS_SCREENSHOT_TABLE_HTML=$(generate_html_table "$HAS_SCREENSHOT_FILE" "Tiene Captura|Cantidad")

cat <<EOF > "$HTML_FILE"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Estadísticas de Shodan - Paraguay</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; color: #333; }
        h1 { color: #2c3e50; }
        h2 { color: #2980b9; }
        p { color: #34495e; line-height: 1.6; }
        pre {
            font-family: monospace;
            white-space: pre-wrap;
            background-color: #fff;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            color: #2c3e50;
            overflow-x: auto;
        }
        p.description { font-style: italic; color: #555; margin-bottom: 5px; }
        .intro {
            background:#e9f5ff;
            border-radius:8px;
            padding:18px 20px;
            margin-bottom:30px;
            border:1px solid #b3d8f7;
            font-size: 16px;
        }
        .section-title {
            color: #2980b9;
            margin-top: 40px;
            margin-bottom: 15px;
            border-bottom: 2px solid #2980b9;
            padding-bottom: 5px;
        }
        .stats-table {
            /* width: 100%; */
            border-collapse: collapse;
            margin-bottom: 20px;
            background-color: #fff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            font-size: 0.9em;
        }
        .stats-table th, .stats-table td {
            border: 1px solid #ddd;
            padding: 10px;
            text-align: left;
            vertical-align: top;
        }
        .stats-table th {
            background-color: #e9ecef;
            color: #2c3e50;
            font-weight: bold;
        }
        .stats-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .stats-table td:last-child {
            text-align: left;
            white-space: nowrap;
        }
    </style>
</head>
<body>
    <h1>Estadísticas de Ciberseguridad de Paraguay según Shodan</h1>
    <p class="intro"><b>Shodan es un motor de búsqueda que rastrea dispositivos conectados a internet en todo el mundo. Estos dispositivos pueden ser cámaras, routers, servidores, sensores, entre otros. Este informe presenta cómo está expuesto Paraguay en términos de ciberseguridad.</b></p>
    <p title="Los rastreadores de Shodan escanean todo internet al menos una vez por semana, actualizando su base de datos en tiempo real. Trabajan 24/7, sondeando continuamente internet en busca de dispositivos y servicios abiertos. Los rastreadores de Shodan no barren rangos de IP; en su lugar, generan aleatoriamente direcciones IP y puertos para verificar. Aunque la frecuencia principal de rastreo es semanal, los usuarios pueden activar escaneos bajo demanda utilizando la API para dispositivos o redes específicas.">Última actualización: $(date +"%d-%m-%Y %H:%M:%S")</p>

    <h2 class="section-title">Top 50 Vulnerabilidades</h2>
    <p><b>Vulnerabilidades (CVE)</b></p>
    <p class="description"><i>¿Qué muestra? Una "CVE" es una falla de seguridad conocida. Esta sección lista cuáles son las más comunes en Paraguay.</i></p>
    <p class="description"><i>¿Por qué importa? Si un dispositivo tiene una de estas fallas sin corregir (sin actualizar o sin protección), puede ser hackeado fácilmente. Muchas de estas fallas tienen más de 10 años. Eso significa que hay muchos dispositivos antiguos o mal gestionados que aún están en uso.</i></p>
    ${VULNS_TABLE_HTML}

    <h2 class="section-title">Top 50 Proveedores de Internet (ISPs)</h2>
    <p><b>Proveedores de Internet (ISPs)</b></p>
    <p class="description"><i>¿Qué muestra? Lista las empresas que proveen acceso a internet y cuántos dispositivos <b>con vulnerabilidades conocidas</b> bajo su red están visibles en internet.</i></p>
    <p class="description"><i>¿Por qué importa? Un número alto no es malo por sí solo, pero si esos dispositivos no están protegidos correctamente, pueden ser atacados. Algunos ISPs no aplican suficientes medidas de seguridad.</i></p>
    ${ISP_TABLE_HTML}

    <h2 class="section-title">Top 50 Ciudades</h2>
    <p><b>Ciudades</b></p>
    <p class="description"><i>¿Qué muestra? Muestra las ciudades paraguayas donde hay más dispositivos <b>con vulnerabilidades conocidas</b> conectados y expuestos en internet.</i></p>
    <p class="description"><i>¿Por qué importa? Donde hay más exposición, también hay más riesgo. Una ciudad con miles de dispositivos visibles en internet tiene mayor probabilidad de sufrir ciberataques masivos o propagación rápida de amenazas.</i></p>
    ${CITIES_TABLE_HTML}

    <h2 class="section-title">Top 50 Productos</h2>
    <p><b>Productos</b></p>
    <p class="description"><i>¿Qué muestra? Dispositivos y programas específicos <b>con vulnerabilidades conocidas</b> que están conectados a internet (por ejemplo, cámaras de vigilancia, routers, servidores de bases de datos, etc.).</i></p>
    <p class="description"><i>¿Por qué importa? Algunos productos son muy vulnerables si no se configuran correctamente. Por ejemplo, muchas cámaras o routers vienen con contraseñas débiles de fábrica. Si no se cambian, cualquier persona en internet podría ver esas cámaras o entrar a la red.</i></p>
    ${PRODUCT_TABLE_HTML}

    <h2 class="section-title">Top 50 Sistemas Operativos</h2>
    <p><b>Sistemas Operativos</b></p>
    <p class="description"><i>¿Qué muestra? Los sistemas que usan los dispositivos <b>con vulnerabilidades conocidas</b> conectados (como Windows, Linux, RouterOS, etc.).</i></p>
    <p class="description"><i>¿Por qué importa? Los sistemas desactualizados o no oficiales suelen tener fallas conocidas. Es como dejar abierta una puerta que ya se sabe cómo forzar. Muchos sistemas aquí tienen versiones viejas que ya no reciben actualizaciones de seguridad.</i></p>
    ${OS_TABLE_HTML}

    <h2 class="section-title">Top 50 Puertos Abiertos Detectados</h2>
    <p><b>Puertos</b></p>
    <p class="description"><i>¿Qué muestra? "Puertos" son como puertas que permiten que los dispositivos <b>con vulnerabilidades conocidas</b> se comuniquen. Esta sección lista los más abiertos en Paraguay.</i></p>
    <p class="description"><i>¿Por qué importa? Algunos puertos son conocidos por ser usados en ataques (como el puerto 23 o 3389). Si están abiertos y mal protegidos, los hackers pueden entrar fácilmente. Cada puerto abierto debe estar justificado y protegido.</i></p>
    ${PORT_TABLE_HTML}

    <h2 class="section-title">Top 50 Números de Sistemas Autónomos (ASNs)</h2>
    <p><b>Números de Sistemas Autónomos (ASN)</b></p>
    <p class="description"><i>¿Qué muestra? Cada ASN representa una red de computadoras de un proveedor o empresa. Aquí se muestra cuántos dispositivos <b>con vulnerabilidades conocidas</b> visibles tiene cada red.</i></p>
    <p class="description"><i>¿Por qué importa? Si una red entera está mal configurada, todos sus dispositivos pueden ser atacados o utilizados para lanzar ataques a otros. Es responsabilidad de cada red aplicar buenas prácticas de ciberseguridad.</i></p>
    ${ASN_TABLE_HTML}

    <h2 class="section-title">Top 50 Componentes HTTP</h2>
    <p><b>Componentes HTTP</b></p>
    <p class="description"><i>¿Qué muestra? Lista de tecnologías usadas para servir páginas web o gestionar conexiones a través de internet en dispositivos <b>con vulnerabilidades conocidas</b>.</i></p>
    <p class="description"><i>¿Por qué importa? Muchos de estos sistemas, si no se actualizan o configuran bien, permiten que atacantes tomen control del sitio web, accedan a información privada o modifiquen el contenido.</i></p>
    ${HTTP_COMPONENT_TABLE_HTML}

    <h2 class="section-title">Top 50 Categorías de Componentes HTTP</h2>
    <p><b>Categorías de Componentes HTTP</b></p>
    <p class="description"><i>¿Qué muestra? Clasifica los componentes HTTP en categorías, mostrando las más frecuentes en Paraguay entre dispositivos <b>con vulnerabilidades conocidas</b>.</i></p>
    <p class="description"><i>¿Por qué importa? Permite identificar tendencias tecnológicas y posibles vectores de ataque según el tipo de tecnología predominante.</i></p>
    ${HTTP_COMPONENT_CATEGORY_TABLE_HTML}

    <h2 class="section-title">Versiones de SSL/TLS Detectadas y su Prevalencia</h2>
    <p><b>Versiones de SSL/TLS</b></p>
    <p class="description"><i>¿Qué muestra? Enumera las versiones de SSL/TLS detectadas en dispositivos <b>con vulnerabilidades conocidas</b> en Paraguay y su frecuencia.</i></p>
    <p class="description"><i>¿Por qué importa? El uso de versiones obsoletas (ej. SSLv2, SSLv3, TLS 1.0/1.1) representa un riesgo de seguridad significativo.</i></p>
    ${SSL_VERSION_TABLE_HTML}

    <h2 class="section-title">Conteo de Dispositivos con posibles Capturas de Pantalla</h2>
    <p><b>Capturas de Pantalla</b></p>
    <p class="description"><i>¿Qué muestra? Muestra la cantidad de dispositivos <b>con vulnerabilidades conocidas</b> en Paraguay para los cuales Shodan tiene capturas de pantalla disponibles.</i></p>
    <p class="description"><i>¿Por qué importa? Permite visualizar remotamente la interfaz de algunos dispositivos, lo que puede evidenciar configuraciones inseguras o información sensible expuesta.</i></p>
    ${HAS_SCREENSHOT_TABLE_HTML}

    <h2 class="section-title">Créditos</h2>
    <p>Este proyecto fue realizado por Karl y la comunidad Hackpy. Puedes seguirme en X (Twitter): <a href="https://x.com/karlbooklover" target="_blank" rel="noopener noreferrer">@karlbooklover</a>.</p>
    <p>Datos obtenidos de Shodan.</p>
</body>
</html>
EOF

# --- Step 3: Push to GitHub Pages ---
echo "[DEBUG] Changing to repo directory: $REPO_DIR"
cd "$REPO_DIR"
git add index.html
git commit -m "Update Shodan stats - $(date)"
git push origin master # Please ensure this is your default branch

# --- Step 4: Log Completion ---
echo "Script completed at $(date)" >> "$OUTPUT_DIR/update_log.txt"