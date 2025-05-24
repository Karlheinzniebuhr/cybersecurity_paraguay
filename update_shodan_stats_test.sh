#!/bin/bash

# --- Set a comprehensive PATH for cron ---
# Include directories where common commands and your user-installed tools live.
# Based on your 'which' output, we need /home/karl/.local/bin and /usr/bin.
# We also include other standard places just to be safe.
export PATH="/home/karl/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Script: update_shodan_stats_test.sh
# Purpose: Test script to update GitHub Gist and GitHub Pages using existing Shodan output files, skipping Shodan API calls.

# --- Configuration ---
OUTPUT_DIR="/home/karl/cybersecurity_paraguay/shodan_stats"

# Directory to store tracking CSV files
TRACKING_DIR="/home/karl/cybersecurity_paraguay/shodan_tracking"
mkdir -p "$TRACKING_DIR"

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

# Tracking CSV files
ISP_TRACKING_CSV="$TRACKING_DIR/isp_tracking.csv"
CITIES_TRACKING_CSV="$TRACKING_DIR/cities_tracking.csv"
VULNS_TRACKING_CSV="$TRACKING_DIR/vulns_tracking.csv"
PRODUCT_TRACKING_CSV="$TRACKING_DIR/product_tracking.csv"
OS_TRACKING_CSV="$TRACKING_DIR/os_tracking.csv"
PORT_TRACKING_CSV="$TRACKING_DIR/port_tracking.csv"
ASN_TRACKING_CSV="$TRACKING_DIR/asn_tracking.csv"
HTTP_COMPONENT_TRACKING_CSV="$TRACKING_DIR/http_component_tracking.csv"
HTTP_COMPONENT_CATEGORY_TRACKING_CSV="$TRACKING_DIR/http_component_category_tracking.csv"
SSL_VERSION_TRACKING_CSV="$TRACKING_DIR/ssl_version_tracking.csv"
HAS_SCREENSHOT_TRACKING_CSV="$TRACKING_DIR/has_screenshot_tracking.csv"

# Function to calculate total from a shodan stats file
calculate_total() {
    local file="$1"
    if [[ -f "$file" ]]; then
        awk 'NR > 1 && NF >= 2 { total += $NF } END { print total+0 }' "$file"
    else
        echo "0"
    fi
}

# Function to update tracking CSV
update_tracking_csv() {
    local csv_file="$1"
    local total="$2"
    local date_today=$(date +"%Y-%m-%d")
    
    # Create CSV with header if it doesn't exist
    if [[ ! -f "$csv_file" ]]; then
        echo "Date,Total" > "$csv_file"
    fi
    
    # Check if today's entry already exists
    if grep -q "^$date_today," "$csv_file"; then
        # Update existing entry
        sed -i "s/^$date_today,.*/$date_today,$total/" "$csv_file"
    else
        # Add new entry
        echo "$date_today,$total" >> "$csv_file"
    fi
    
    # Keep only last 30 days
    tail -n 31 "$csv_file" > "${csv_file}.tmp" && mv "${csv_file}.tmp" "$csv_file"
}

# Function to generate simple chart HTML
generate_chart_html() {
    local csv_file="$1"
    local title="$2"
    
    if [[ ! -f "$csv_file" ]]; then
        echo "<p><em>No hay datos históricos disponibles aún.</em></p>"
        return
    fi
    
    # Read data and generate chart
    awk -F',' '
    NR == 1 { next }  # Skip header
    {
        dates[NR-1] = $1
        values[NR-1] = $2
        if ($2 > max || max == "") max = $2
        if ($2 < min || min == "") min = $2
        count = NR-1
    }
    END {
        if (count == 0) {
            print "<p><em>No hay datos históricos disponibles aún.</em></p>"
            exit
        }
        
        range = max - min
        if (range == 0) range = 1
        
        print "<div class=\"chart-container\">"
        print "  <div class=\"chart-title\">" title " - Últimos " count " días</div>"
        print "  <div class=\"chart\">"
        
        for (i = 0; i < count; i++) {
            height = ((values[i] - min) / range) * 80 + 10  # 10-90% height
            print "    <div class=\"chart-bar\" style=\"height: " height "%\" title=\"" dates[i] ": " values[i] "\"></div>"
        }
        
        print "  </div>"
        print "  <div class=\"chart-info\">Min: " min " | Max: " max " | Último: " values[count-1] "</div>"
        print "</div>"
    }
    ' "$csv_file"
}

# --- Step 1: Skip Shodan Commands ---
echo "[INFO] Skipping Shodan commands. Using existing output files in $OUTPUT_DIR."

# --- Step 1.5: Update Tracking Data ---
echo "[INFO] Updating tracking data..."

# Calculate totals and update tracking CSVs
ISP_TOTAL=$(calculate_total "$ISP_FILE")
CITIES_TOTAL=$(calculate_total "$CITIES_FILE")
VULNS_TOTAL=$(calculate_total "$VULNS_FILE")
PRODUCT_TOTAL=$(calculate_total "$PRODUCT_FILE")
OS_TOTAL=$(calculate_total "$OS_FILE")
PORT_TOTAL=$(calculate_total "$PORT_FILE")
ASN_TOTAL=$(calculate_total "$ASN_FILE")
HTTP_COMPONENT_TOTAL=$(calculate_total "$HTTP_COMPONENT_FILE")
HTTP_COMPONENT_CATEGORY_TOTAL=$(calculate_total "$HTTP_COMPONENT_CATEGORY_FILE")
SSL_VERSION_TOTAL=$(calculate_total "$SSL_VERSION_FILE")
HAS_SCREENSHOT_TOTAL=$(calculate_total "$HAS_SCREENSHOT_FILE")

# Update tracking CSVs
update_tracking_csv "$ISP_TRACKING_CSV" "$ISP_TOTAL"
update_tracking_csv "$CITIES_TRACKING_CSV" "$CITIES_TOTAL"
update_tracking_csv "$VULNS_TRACKING_CSV" "$VULNS_TOTAL"
update_tracking_csv "$PRODUCT_TRACKING_CSV" "$PRODUCT_TOTAL"
update_tracking_csv "$OS_TRACKING_CSV" "$OS_TOTAL"
update_tracking_csv "$PORT_TRACKING_CSV" "$PORT_TOTAL"
update_tracking_csv "$ASN_TRACKING_CSV" "$ASN_TOTAL"
update_tracking_csv "$HTTP_COMPONENT_TRACKING_CSV" "$HTTP_COMPONENT_TOTAL"
update_tracking_csv "$HTTP_COMPONENT_CATEGORY_TRACKING_CSV" "$HTTP_COMPONENT_CATEGORY_TOTAL"
update_tracking_csv "$SSL_VERSION_TRACKING_CSV" "$SSL_VERSION_TOTAL"
update_tracking_csv "$HAS_SCREENSHOT_TRACKING_CSV" "$HAS_SCREENSHOT_TOTAL"

# --- Step 2: Generate HTML File ---
# Helper function to convert shodan stats output to an HTML table
# Takes the input file path as $1 and the column headers (e.g., "Proveedor|Dispositivos") as $2
generate_html_table() {
    local input_file="$1"
    local headers_str="$2"
    local header1 header2
    IFS='|' read -r header1 header2 <<< "$headers_str"
    
    # AWK script to generate table rows.
    # If it's the vulnerability table (based on h1) and the first field looks like a CVE ID,
    # it creates a hyperlink. Otherwise, it uses the original formatting.
    awk -v h1="$header1" -v h2="$header2" '
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

        if (tolower($1) ~ /^cve-[0-9][0-9][0-9][0-9]-[0-9]+$/) {
            # This is the Vulnerability table and $1 matches CVE pattern (case-insensitive)
            # Convert to uppercase for URL and display
            cve_id_for_url = toupper($1);     # Convert to uppercase for URL
            cve_id_for_display = toupper($1); # Convert to uppercase for display

            # HTML-escape the CVE ID that will be displayed as the link text
            gsub(/&/, "&amp;", cve_id_for_display);
            gsub(/</, "&lt;", cve_id_for_display);
            gsub(/>/, "&gt;", cve_id_for_display);

            # Construct the hyperlink
            name_output_final = sprintf("<a href=\"https://www.cve.org/CVERecord/SearchResults?query=%s\" target=\"_blank\" rel=\"noopener noreferrer\">%s</a>", cve_id_for_url, cve_id_for_display);
            
            # If there are descriptive parts after CVE ID and before count (e.g. CVE-ID Description Count)
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

# Generate chart HTML for each section
VULNS_CHART_HTML=$(generate_chart_html "$VULNS_TRACKING_CSV" "Vulnerabilidades")
ISP_CHART_HTML=$(generate_chart_html "$ISP_TRACKING_CSV" "Proveedores ISP")
CITIES_CHART_HTML=$(generate_chart_html "$CITIES_TRACKING_CSV" "Ciudades")
PRODUCT_CHART_HTML=$(generate_chart_html "$PRODUCT_TRACKING_CSV" "Productos")
OS_CHART_HTML=$(generate_chart_html "$OS_TRACKING_CSV" "Sistemas Operativos")
PORT_CHART_HTML=$(generate_chart_html "$PORT_TRACKING_CSV" "Puertos")
ASN_CHART_HTML=$(generate_chart_html "$ASN_TRACKING_CSV" "ASNs")
HTTP_COMPONENT_CHART_HTML=$(generate_chart_html "$HTTP_COMPONENT_TRACKING_CSV" "Componentes HTTP")
HTTP_COMPONENT_CATEGORY_CHART_HTML=$(generate_chart_html "$HTTP_COMPONENT_CATEGORY_TRACKING_CSV" "Categorías HTTP")
SSL_VERSION_CHART_HTML=$(generate_chart_html "$SSL_VERSION_TRACKING_CSV" "Versiones SSL/TLS")
HAS_SCREENSHOT_CHART_HTML=$(generate_chart_html "$HAS_SCREENSHOT_TRACKING_CSV" "Capturas de Pantalla")

cat <<EOF > "$HTML_FILE"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Estadísticas de Shodan - Paraguay</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; color: #333; }
        .github-link {
            position: absolute;
            top: 20px;
            right: 20px;
            font-size: 14px;
            color: #0366d6; /* GitHub link blue */
            text-decoration: none;
            z-index: 10;
        }
        .github-link:hover {
            text-decoration: underline;
        }
        h1 { color: #2c3e50; margin-top: 60px; padding-right: 120px; }
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
        .chart-container {
            background-color: #fff;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 15px;
            margin: 15px 0;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .chart-title {
            font-size: 14px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
            text-align: center;
        }
        .chart {
            display: flex;
            align-items: flex-end;
            height: 100px;
            border-bottom: 1px solid #ddd;
            padding: 5px 0;
            gap: 2px;
        }
        .chart-bar {
            flex: 1;
            background-color: #2980b9;
            min-height: 2px;
            border-radius: 2px 2px 0 0;
            transition: background-color 0.3s;
        }
        .chart-bar:hover {
            background-color: #3498db;
        }
        .chart-info {
            font-size: 12px;
            color: #666;
            text-align: center;
            margin-top: 8px;
        }
    </style>
</head>
<body>
    <div class="github-link">
        <a href="https://github.com/Karlheinzniebuhr/cybersecurity_paraguay" target="_blank" rel="noopener noreferrer">Código Abierto</a>
    </div>
    <h1>Estadísticas de Ciberseguridad de Paraguay según Shodan</h1>
    <p class="intro"><b>Shodan es un motor de búsqueda que rastrea dispositivos conectados a internet en todo el mundo. Estos dispositivos pueden ser cámaras, routers, servidores, sensores, entre otros. Este informe presenta cómo está expuesto Paraguay en términos de ciberseguridad.</b></p>
    <p title="Los rastreadores de Shodan escanean todo internet al menos una vez por semana, actualizando su base de datos en tiempo real. Trabajan 24/7, sondeando continuamente internet en busca de dispositivos y servicios abiertos. Los rastreadores de Shodan no barren rangos de IP; en su lugar, generan aleatoriamente direcciones IP y puertos para verificar. Aunque la frecuencia principal de rastreo es semanal, los usuarios pueden activar escaneos bajo demanda utilizando la API para dispositivos o redes específicas.">Última actualización: $(date +"%d-%m-%Y %H:%M:%S")</p>

    <h2 class="section-title">Top 50 Vulnerabilidades</h2>
    <p><b>Vulnerabilidades (CVE)</b></p>
    <p class="description"><i>¿Qué muestra? Una "CVE" es una falla de seguridad conocida. Esta sección lista cuáles son las más comunes en Paraguay.</i></p>
    <p class="description"><i>¿Por qué importa? Si un dispositivo tiene una de estas fallas sin corregir (sin actualizar o sin protección), puede ser hackeado fácilmente. Muchas de estas fallas tienen más de 10 años. Eso significa que hay muchos dispositivos antiguos o mal gestionados que aún están en uso.</i></p>
    ${VULNS_CHART_HTML}
    ${VULNS_TABLE_HTML}

    <h2 class="section-title">Top 50 Proveedores de Internet (ISPs)</h2>
    <p><b>Proveedores de Internet (ISPs)</b></p>
    <p class="description"><i>¿Qué muestra? Lista las empresas que proveen acceso a internet y cuántos dispositivos <b>con vulnerabilidades conocidas</b> bajo su red están visibles en internet.</i></p>
    <p class="description"><i>¿Por qué importa? Un número alto no es malo por sí solo, pero si esos dispositivos no están protegidos correctamente, pueden ser atacados. Algunos ISPs no aplican suficientes medidas de seguridad.</i></p>
    ${ISP_CHART_HTML}
    ${ISP_TABLE_HTML}

    <h2 class="section-title">Top 50 Ciudades</h2>
    <p><b>Ciudades</b></p>
    <p class="description"><i>¿Qué muestra? Muestra las ciudades paraguayas donde hay más dispositivos <b>con vulnerabilidades conocidas</b> conectados y expuestos en internet.</i></p>
    <p class="description"><i>¿Por qué importa? Donde hay más exposición, también hay más riesgo. Una ciudad con miles de dispositivos visibles en internet tiene mayor probabilidad de sufrir ciberataques masivos o propagación rápida de amenazas.</i></p>
    ${CITIES_CHART_HTML}
    ${CITIES_TABLE_HTML}

    <h2 class="section-title">Top 50 Productos</h2>
    <p><b>Productos</b></p>
    <p class="description"><i>¿Qué muestra? Dispositivos y programas específicos <b>con vulnerabilidades conocidas</b> que están conectados a internet (por ejemplo, cámaras de vigilancia, routers, servidores de bases de datos, etc.).</i></p>
    <p class="description"><i>¿Por qué importa? Algunos productos son muy vulnerables si no se configuran correctamente. Por ejemplo, muchas cámaras o routers vienen con contraseñas débiles de fábrica. Si no se cambian, cualquier persona en internet podría ver esas cámaras o entrar a la red.</i></p>
    ${PRODUCT_CHART_HTML}
    ${PRODUCT_TABLE_HTML}

    <h2 class="section-title">Top 50 Sistemas Operativos</h2>
    <p><b>Sistemas Operativos</b></p>
    <p class="description"><i>¿Qué muestra? Los sistemas que usan los dispositivos <b>con vulnerabilidades conocidas</b> conectados (como Windows, Linux, RouterOS, etc.).</i></p>
    <p class="description"><i>¿Por qué importa? Los sistemas desactualizados o no oficiales suelen tener fallas conocidas. Es como dejar abierta una puerta que ya se sabe cómo forzar. Muchos sistemas aquí tienen versiones viejas que ya no reciben actualizaciones de seguridad.</i></p>
    ${OS_CHART_HTML}
    ${OS_TABLE_HTML}

    <h2 class="section-title">Top 50 Puertos Abiertos Detectados</h2>
    <p><b>Puertos</b></p>
    <p class="description"><i>¿Qué muestra? "Puertos" son como puertas que permiten que los dispositivos <b>con vulnerabilidades conocidas</b> se comuniquen. Esta sección lista los más abiertos en Paraguay.</i></p>
    <p class="description"><i>¿Por qué importa? Algunos puertos son conocidos por ser usados en ataques (como el puerto 23 o 3389). Si están abiertos y mal protegidos, los hackers pueden entrar fácilmente. Cada puerto abierto debe estar justificado y protegido.</i></p>
    ${PORT_CHART_HTML}
    ${PORT_TABLE_HTML}

    <h2 class="section-title">Top 50 Números de Sistemas Autónomos (ASNs)</h2>
    <p><b>Números de Sistemas Autónomos (ASN)</b></p>
    <p class="description"><i>¿Qué muestra? Cada ASN representa una red de computadoras de un proveedor o empresa. Aquí se muestra cuántos dispositivos <b>con vulnerabilidades conocidas</b> visibles tiene cada red.</i></p>
    <p class="description"><i>¿Por qué importa? Si una red entera está mal configurada, todos sus dispositivos pueden ser atacados o utilizados para lanzar ataques a otros. Es responsabilidad de cada red aplicar buenas prácticas de ciberseguridad.</i></p>
    ${ASN_CHART_HTML}
    ${ASN_TABLE_HTML}

    <h2 class="section-title">Top 50 Componentes HTTP</h2>
    <p><b>Componentes HTTP</b></p>
    <p class="description"><i>¿Qué muestra? Lista de tecnologías usadas para servir páginas web o gestionar conexiones a través de internet en dispositivos <b>con vulnerabilidades conocidas</b>.</i></p>
    <p class="description"><i>¿Por qué importa? Muchos de estos sistemas, si no se actualizan o configuran bien, permiten que atacantes tomen control del sitio web, accedan a información privada o modifiquen el contenido.</i></p>
    ${HTTP_COMPONENT_CHART_HTML}
    ${HTTP_COMPONENT_TABLE_HTML}

    <h2 class="section-title">Top 50 Categorías de Componentes HTTP</h2>
    <p><b>Categorías de Componentes HTTP</b></p>
    <p class="description"><i>¿Qué muestra? Clasifica los componentes HTTP en categorías, mostrando las más frecuentes en Paraguay entre dispositivos <b>con vulnerabilidades conocidas</b>.</i></p>
    <p class="description"><i>¿Por qué importa? Permite identificar tendencias tecnológicas y posibles vectores de ataque según el tipo de tecnología predominante.</i></p>
    ${HTTP_COMPONENT_CATEGORY_CHART_HTML}
    ${HTTP_COMPONENT_CATEGORY_TABLE_HTML}

    <h2 class="section-title">Versiones de SSL/TLS Detectadas y su Prevalencia</h2>
    <p><b>Versiones de SSL/TLS</b></p>
    <p class="description"><i>¿Qué muestra? Enumera las versiones de SSL/TLS detectadas en dispositivos <b>con vulnerabilidades conocidas</b> en Paraguay y su frecuencia.</i></p>
    <p class="description"><i>¿Por qué importa? El uso de versiones obsoletas (ej. SSLv2, SSLv3, TLS 1.0/1.1) representa un riesgo de seguridad significativo.</i></p>
    ${SSL_VERSION_CHART_HTML}
    ${SSL_VERSION_TABLE_HTML}

    <h2 class="section-title">Conteo de Dispositivos con posibles Capturas de Pantalla</h2>
    <p><b>Capturas de Pantalla</b></p>
    <p class="description"><i>¿Qué muestra? Muestra la cantidad de dispositivos <b>con vulnerabilidades conocidas</b> en Paraguay para los cuales Shodan tiene capturas de pantalla disponibles.</i></p>
    <p class="description"><i>¿Por qué importa? Permite visualizar remotamente la interfaz de algunos dispositivos, lo que puede evidenciar configuraciones inseguras o información sensible expuesta.</i></p>
    ${HAS_SCREENSHOT_CHART_HTML}
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
echo "[DEBUG] Current directory: $(pwd)"
echo "[DEBUG] Git remote -v:"
git remote -v
echo "[DEBUG] Git branch: $(git rev-parse --abbrev-ref HEAD)"
echo "[DEBUG] Git status:"
git status

git add index.html
git commit -m "[TEST] Update Shodan stats - $(date)"
git push origin master  # Replace 'master' with your branch if it's different

# --- Step 4: Log Completion ---
echo "[INFO] Test script completed at $(date)" >> "$OUTPUT_DIR/update_log.txt"
