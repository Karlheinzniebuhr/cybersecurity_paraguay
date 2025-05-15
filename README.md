# Estadísticas de Shodan para Paraguay

Este proyecto automatiza la recopilación, análisis y publicación de estadísticas sobre dispositivos conectados a Internet en Paraguay utilizando la API de Shodan. Los resultados se actualizan periódicamente y se publican tanto en un [GitHub Pages](https://github.com/tuusuario/Vulnerabilidades-Shodan-en-Paraguay) como en un Gist público.

## ¿Qué hace este proyecto?
- Ejecuta comandos de Shodan para obtener información relevante sobre Paraguay:
  - Vulnerabilidades más comunes
  - Proveedores de Internet (ISPs)
  - Ciudades con más dispositivos conectados
  - Productos y sistemas operativos detectados
  - Puertos expuestos
  - Números de Sistemas Autónomos (ASNs)
  - Componentes y categorías HTTP
  - Versiones de SSL/TLS (incluyendo detección de versiones obsoletas)
  - Dispositivos con capturas de pantalla
- Genera un archivo HTML visualmente atractivo con los resultados.
- Actualiza automáticamente un Gist y un repositorio de GitHub Pages con los datos más recientes.

## Archivos principales
- `update_shodan_stats.sh`: Script principal que ejecuta los comandos de Shodan, actualiza el Gist y genera el HTML.
- `index.html`: Archivo generado con las estadísticas, listo para ser publicado en GitHub Pages.

## Requisitos
- Tener una cuenta y API Key de [Shodan](https://shodan.io/).
- Tener instalado el CLI de Shodan (`pip install shodan`).
- Tener instalado [GitHub CLI](https://cli.github.com/) (`gh`).
- Acceso a un repositorio de GitHub Pages y un Gist donde publicar los resultados.
- Entorno Linux recomendado (el script está hecho para bash).

## Uso
1. Clona este repositorio y configura las variables en `update_shodan_stats.sh`:
   - `OUTPUT_DIR`: Carpeta donde se guardan los archivos temporales.
   - `GIST_ID`: ID de tu Gist de GitHub.
   - `REPO_DIR`: Ruta local a tu repositorio de GitHub Pages.
2. Da permisos de ejecución al script:
   ```bash
   chmod +x update_shodan_stats.sh
   ```
3. Ejecuta el script:
   ```bash
   ./update_shodan_stats.sh
   ```
4. El script generará los archivos, actualizará el Gist y subirá los cambios a GitHub Pages.

## Ejemplo de resultados
Puedes ver los resultados publicados en el archivo `index.html` o directamente en tu sitio de GitHub Pages.

## Créditos
- Datos públicos de [Shodan](https://shodan.io/).
- Autor: [@karl](https://x.com/karlbooklover)

## Licencia
MIT
