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
        h1 { color: #2c3e50; }
        h2 { color: #2980b9; }
        p { color: #34495e; }
        pre { 
            font-family: monospace; 
            white-space: pre-wrap; 
            background-color: #fff; 
            padding: 15px; 
            border: 1px solid #ddd; 
            border-radius: 5px; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.1); 
            color: #2c3e50;
        }
        p.description { font-style: italic; color: #555; }
        /* New styles for improved readability */
        .intro { 
            background:#e9f5ff;
            border-radius:8px;
            padding:18px 20px;
            margin-bottom:30px;
            border:1px solid #b3d8f7;
            font-size: 16px;
            line-height: 1.5;
        }
        .section-title {
            color: #2980b9;
            margin-top: 30px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <h1>Estadísticas de Ciberseguridad de Paraguay según Shodan</h1>
    <p class="intro"><b>Shodan es un motor de búsqueda que rastrea dispositivos conectados a internet en todo el mundo. Estos dispositivos pueden ser cámaras, routers, servidores, sensores, entre otros. Este informe presenta cómo está expuesto Paraguay en términos de ciberseguridad.</b></p>
    <p>Última actualización: $(date)</p>

    <h2>Top 50 Vulnerabilidades</h2>
    <p><b>Vulnerabilidades (CVE)</b></p>
    <p class="description"><i>¿Qué muestra? Una "CVE" es una falla de seguridad conocida. Esta sección lista cuáles son las más comunes en Paraguay.</i></p>
    <p class="description"><i>¿Por qué importa? Si un dispositivo tiene una de estas fallas sin corregir (sin actualizar o sin protección), puede ser hackeado fácilmente. Muchas de estas fallas tienen más de 10 años. Eso significa que hay muchos dispositivos antiguos o mal gestionados que aún están en uso.</i></p>
    <pre>$(cat "$VULNS_FILE")</pre>

    <h2>Top 50 Proveedores de Internet (ISPs)</h2>
    <p><b>Proveedores de Internet (ISPs)</b></p>
    <p class="description"><i>¿Qué muestra? Lista las empresas que proveen acceso a internet y cuántos dispositivos bajo su red están visibles en internet.</i></p>
    <p class="description"><i>¿Por qué importa? Un número alto no es malo por sí solo, pero si esos dispositivos no están protegidos correctamente, pueden ser atacados. Algunos ISPs no aplican suficientes medidas de seguridad.</i></p>
    <pre>$(cat "$ISP_FILE")</pre>

    <h2>Top 50 Ciudades</h2>
    <p><b>Ciudades</b></p>
    <p class="description"><i>¿Qué muestra? Muestra las ciudades paraguayas donde hay más dispositivos conectados y expuestos en internet.</i></p>
    <p class="description"><i>¿Por qué importa? Donde hay más exposición, también hay más riesgo. Una ciudad con miles de dispositivos visibles en internet tiene mayor probabilidad de sufrir ciberataques masivos o propagación rápida de amenazas.</i></p>
    <pre>$(cat "$CITIES_FILE")</pre>

    <h2>Top 50 Productos</h2>
    <p><b>Productos</b></p>
    <p class="description"><i>¿Qué muestra? Dispositivos y programas específicos que están conectados a internet (por ejemplo, cámaras de vigilancia, routers, servidores de bases de datos, etc.).</i></p>
    <p class="description"><i>¿Por qué importa? Algunos productos son muy vulnerables si no se configuran correctamente. Por ejemplo, muchas cámaras o routers vienen con contraseñas débiles de fábrica. Si no se cambian, cualquier persona en internet podría ver esas cámaras o entrar a la red.</i></p>
    <pre>$(cat "$PRODUCT_FILE")</pre>

    <h2>Top 50 Sistemas Operativos</h2>
    <p><b>Sistemas Operativos</b></p>
    <p class="description"><i>¿Qué muestra? Los sistemas que usan los dispositivos conectados (como Windows, Linux, RouterOS, etc.).</i></p>
    <p class="description"><i>¿Por qué importa? Los sistemas desactualizados o no oficiales suelen tener fallas conocidas. Es como dejar abierta una puerta que ya se sabe cómo forzar. Muchos sistemas aquí tienen versiones viejas que ya no reciben actualizaciones de seguridad.</i></p>
    <pre>$(cat "$OS_FILE")</pre>

    <h2>Top 50 Puertos Abiertos Detectados</h2>
    <p><b>Puertos</b></p>
    <p class="description"><i>¿Qué muestra? "Puertos" son como puertas que permiten que los dispositivos se comuniquen. Esta sección lista los más abiertos en Paraguay.</i></p>
    <p class="description"><i>¿Por qué importa? Algunos puertos son conocidos por ser usados en ataques (como el puerto 23 o 3389). Si están abiertos y mal protegidos, los hackers pueden entrar fácilmente. Cada puerto abierto debe estar justificado y protegido.</i></p>
    <pre>$(cat "$PORT_FILE")</pre>

    <h2>Top 50 Números de Sistemas Autónomos (ASNs)</h2>
    <p><b>Números de Sistemas Autónomos (ASN)</b></p>
    <p class="description"><i>¿Qué muestra? Cada ASN representa una red de computadoras de un proveedor o empresa. Aquí se muestra cuántos dispositivos visibles tiene cada red.</i></p>
    <p class="description"><i>¿Por qué importa? Si una red entera está mal configurada, todos sus dispositivos pueden ser atacados o utilizados para lanzar ataques a otros. Es responsabilidad de cada red aplicar buenas prácticas de ciberseguridad.</i></p>
    <pre>$(cat "$ASN_FILE")</pre>

    <h2>Top 50 Componentes HTTP</h2>
    <p><b>Componentes HTTP</b></p>
    <p class="description"><i>¿Qué muestra? Lista de tecnologías usadas para servir páginas web o gestionar conexiones a través de internet.</i></p>
    <p class="description"><i>¿Por qué importa? Muchos de estos sistemas, si no se actualizan o configuran bien, permiten que atacantes tomen control del sitio web, accedan a información privada o modifiquen el contenido.</i></p>
    <pre>$(cat "$HTTP_COMPONENT_FILE")</pre>

    <h2>Top 50 Categorías de Componentes HTTP</h2>
    <p><b>Categorías de Componentes HTTP</b></p>
    <p class="description"><i>¿Qué muestra? Clasifica los componentes HTTP en categorías, mostrando las más frecuentes en Paraguay.</i></p>
    <p class="description"><i>¿Por qué importa? Permite identificar tendencias tecnológicas y posibles vectores de ataque según el tipo de tecnología predominante.</i></p>
    <pre>$(cat "$HTTP_COMPONENT_CATEGORY_FILE")</pre>

    <h2>Versiones de SSL/TLS Detectadas y su Prevalencia</h2>
    <p><b>Versiones de SSL/TLS</b></p>
    <p class="description"><i>¿Qué muestra? Enumera las versiones de SSL/TLS detectadas en dispositivos en Paraguay y su frecuencia.</i></p>
    <p class="description"><i>¿Por qué importa? El uso de versiones obsoletas (ej. SSLv2, SSLv3, TLS 1.0/1.1) representa un riesgo de seguridad significativo.</i></p>
    <pre>$(cat "$SSL_VERSION_FILE")</pre>

    <h2>Conteo de Dispositivos con Capturas de Pantalla</h2>
    <p><b>Capturas de Pantalla</b></p>
    <p class="description"><i>¿Qué muestra? Muestra la cantidad de dispositivos en Paraguay para los cuales Shodan tiene capturas de pantalla disponibles.</i></p>
    <p class="description"><i>¿Por qué importa? Permite visualizar remotamente la interfaz de algunos dispositivos, lo que puede evidenciar configuraciones inseguras o información sensible expuesta.</i></p>
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
