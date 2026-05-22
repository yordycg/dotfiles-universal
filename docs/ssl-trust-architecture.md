# Arquitectura de Confianza SSL y Gestión de Secretos

Este documento explica el desafío técnico que supuso conectar el CLI de Bitwarden con nuestra instancia local de Vaultwarden y cómo se resolvió mediante una cadena de confianza robusta.

## 1. El Desafío: Node.js y los Certificados Locales

El CLI de Bitwarden (`bw`) está construido sobre **Node.js**. A diferencia de los navegadores web, Node.js es extremadamente estricto con los certificados SSL y, a menudo, ignora el almacén de certificados del sistema operativo, utilizando su propia lista interna de CAs raíz.

Al usar **Caddy** con `tls internal`, el servidor genera certificados que los clientes externos no reconocen, provocando el error:
`FetchError: reason: unable to get local issuer certificate`

## 2. La Batalla del Proxy (Caddy vs. Vaultwarden)

Inicialmente, Caddy enviaba todas las peticiones a Vaultwarden. Esto rompía el endpoint de infraestructura `/pki/ca/local` de Caddy, impidiendo que los clientes descargaran el certificado automáticamente.

**Solución en Caddyfile:**
Se implementaron bloques `handle` para que Caddy gestione sus propias rutas de PKI y solo pase el resto del tráfico a Vaultwarden.

## 3. La Solución: El Bundle Maestro

Descubrimos que no basta con el Certificado Raíz (Root CA) si la cadena de Caddy incluye un paso intermedio. Node.js requiere ver la "escalera" completa.

**Pasos de la solución definitiva:**
1.  **Captura Triple:** Se extraen del servidor tanto el `root.crt` como el `intermediate.crt`.
2.  **El Bundle:** Se unen ambos en un solo archivo: `cat root.crt intermediate.crt > homelab-ca-bundle.crt`.
3.  **Inyección en el Sistema:** El bundle se instala en `/etc/pki/ca-trust/source/anchors/` (en Fedora).
4.  **Puente Node.js:** Se exporta la variable de entorno `NODE_EXTRA_CA_CERTS` apuntando a dicho bundle en el `.zshrc`.

## 4. Flujo de Trabajo Zero-Touch Actual

Gracias a esta arquitectura, el despliegue de un nuevo nodo sigue este flujo:
1.  **Bootstrap:** `just deploy-remote` inyecta la llave `age` y el token de GitHub.
2.  **Identidad:** El servidor se auto-configura y genera sus llaves SSH.
3.  **Confianza:** (Próxima mejora) El cliente descarga el bundle y confía en el servidor.
4.  **Secretos:** El cliente desbloquea Bitwarden y Chezmoi rellena las plantillas dinámicamente.

---

*Documento generado tras la sesión de estabilización de infraestructura - Mayo 2026*
