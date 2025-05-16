# Estadísticas de Shodan para Paraguay (Enfoque en Vulnerabilidades)

Este proyecto automatiza la recopilación, análisis y publicación de estadísticas sobre dispositivos **con vulnerabilidades conocidas** conectados a Internet en Paraguay, utilizando la API de Shodan. Los resultados se actualizan periódicamente y se publican tanto en un sitio de [GitHub Pages](https://github.com/tuusuario/Vulnerabilidades-Shodan-en-Paraguay) (reemplaza con tu URL) como en un Gist público.

## ¿Qué hace este proyecto?
- Ejecuta comandos de Shodan para obtener información relevante sobre **dispositivos vulnerables** en Paraguay. La mayoría de las estadísticas utilizan el filtro `has_vuln:true` para enfocarse en sistemas con problemas de seguridad identificados:
  - Vulnerabilidades más comunes (esta es una lista general de CVEs, no filtrada por `has_vuln:true` ya que el objetivo es listar las propias vulnerabilidades).
  - Proveedores de Internet (ISPs) que alojan dispositivos vulnerables.
  - Ciudades con más dispositivos vulnerables conectados.
  - Productos y sistemas operativos detectados en dispositivos vulnerables.
  - Puertos expuestos en dispositivos vulnerables.
  - Números de Sistemas Autónomos (ASNs) con mayor concentración de dispositivos vulnerables.
  - Componentes y categorías HTTP presentes en dispositivos web vulnerables.
  - Versiones de SSL/TLS utilizadas por dispositivos vulnerables (incluyendo detección de versiones obsoletas).
  - Dispositivos vulnerables con capturas de pantalla disponibles.
- Genera un archivo HTML visualmente atractivo con los resultados.
- Actualiza automáticamente un Gist y un repositorio de GitHub Pages con los datos más recientes.

## Archivos principales
- `update_shodan_stats.sh`: Script principal que ejecuta los comandos de Shodan (con filtro `has_vuln:true` para la mayoría), actualiza el Gist y genera el HTML.
- `update_shodan_stats_test.sh`: Script de prueba para verificar el flujo de actualización del Gist y GitHub Pages sin realizar llamadas a la API de Shodan (usa archivos de datos locales preexistentes).
- `index.html`: Archivo generado por `update_shodan_stats.sh` con las estadísticas, listo para ser publicado en GitHub Pages.

## Requisitos
- Tener una cuenta y API Key de [Shodan](https://shodan.io/).
- Tener instalado el CLI de Shodan (`pip install shodan`).
- Tener instalado [GitHub CLI](https://cli.github.com/) (`gh`).
- Acceso a un repositorio de GitHub Pages y un Gist donde publicar los resultados.
- Entorno Linux recomendado (los scripts están hechos para bash).

## Uso
1. Clona este repositorio.
2. **Configura las variables** en `update_shodan_stats.sh` y `update_shodan_stats_test.sh`:
   - `OUTPUT_DIR`: Carpeta donde se guardan los archivos temporales de Shodan.
   - `GIST_ID`: ID de tu Gist de GitHub.
   - `REPO_DIR`: Ruta local a tu repositorio de GitHub Pages (donde se encuentra el `index.html` y otros archivos a publicar).
3. Da permisos de ejecución a los scripts:
   ```bash
   chmod +x update_shodan_stats.sh
   chmod +x update_shodan_stats_test.sh
   ```

Para generar y publicar los datos actualizados:

```bash
./update_shodan_stats.sh
```

Para probar el flujo de publicación sin llamar a Shodan (asegúrate de tener archivos de datos en OUTPUT_DIR):

```bash
./update_shodan_stats_test.sh
```

El script generará los archivos, actualizará el Gist y subirá los cambios a GitHub Pages.

## Ejemplo de resultados

Puedes ver los resultados publicados en el archivo `index.html` o directamente en tu sitio de GitHub Pages (ej. https://tuusuario.github.io/Vulnerabilidades-Shodan-en-Paraguay/).

## Créditos

Datos públicos de Shodan.

Autor: [@karl](https://x.com/karlbooklover)

## Licencia

MIT
