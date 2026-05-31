// =============================================================================
// FIREFOX USER.JS - OPTIMIZADO PARA FLUJO SENIOR Y PRIVACIDAD
// =============================================================================
// NOTA: Este archivo es gestionado por Chezmoi. Cualquier cambio realizado 
// directamente en Firefox (about:config) será sobreescrito en el próximo inicio.
// =============================================================================

// --- 1. CONFIGURACIÓN BASE Y RENDIMIENTO ---
// Evitar animaciones innecesarias
user_pref("toolkit.cosmeticAnimations.enabled", false);
// Habilitar aceleración por hardware estricta (WebRender)
user_pref("gfx.webrender.all", true);
// Reducir retardo en el renderizado inicial
user_pref("nglayout.initialpaint.delay", 0);
user_pref("nglayout.initialpaint.delay_in_oopif", 0);

// --- 2. PRIVACIDAD Y TELEMETRÍA (Bloquear ruidos y tracking) ---
// Desactivar telemetría de Mozilla
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);

// Desactivar "Estudios" (experimentos en segundo plano)
user_pref("app.shield.optoutstudies.enabled", false);
// Desactivar reportes de fallos
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);

// Protección contra rastreo estricta por defecto
user_pref("browser.contentblocking.category", "strict");
// Enviar señal "Do Not Track"
user_pref("privacy.donottrackheader.enabled", true);

// --- 3. INTERFAZ DE USUARIO Y EXPERIENCIA (CLI-Friendly) ---
// Desactivar Pocket (bloatware)
user_pref("extensions.pocket.enabled", false);
// Activar soporte para modificaciones visuales personalizadas (userChrome.css)
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
// Forzar tema oscuro general
user_pref("ui.systemUsesDarkTheme", 1);

// Búsqueda en la barra de URL más limpia (sin sugerencias de patrocinadores)
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.trending.featureGate", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

// --- 4. COMPORTAMIENTO PARA FLUJO DE TRABAJO ---
// Evitar que Ctrl+Q cierre la ventana accidentalmente (útil si fallas atajos de tmux/nvim)
user_pref("browser.quitShortcut.disabled", true);
// Restaurar pestañas de la sesión anterior siempre
user_pref("browser.startup.page", 3);
// No advertir al acceder a about:config
user_pref("browser.aboutConfig.showWarning", false);
// Descargar archivos automáticamente a la carpeta de descargas sin preguntar (más eficiente)
user_pref("browser.download.useDownloadDir", true);

// --- 5. EXTENSIONES (Automatización) ---
// Evitar que Firefox deshabilite automáticamente extensiones instaladas vía sistema/script
user_pref("extensions.autoDisableScopes", 0);
user_pref("extensions.enabledScopes", 15);
