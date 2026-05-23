// =============================================================================
// SURFINGKEYS CONFIG - FLUJO SENIOR / VIM-STYLE
// =============================================================================

// --- 1. CONFIGURACIÓN VISUAL (OMNIBAR) ---
// Configurar colores para que coincidan con un tema oscuro (ej. Gruvbox/OneDark)
settings.theme = `
.sk_theme {
    font-family: "JetBrainsMono Nerd Font", "FiraCode Nerd Font", monospace;
    background: #282c34;
    color: #abb2bf;
}
.sk_theme tbody {
    color: #fff;
}
.sk_theme input {
    color: #dcdfe4;
}
.sk_theme .url {
    color: #61afef;
}
.sk_theme .annotation {
    color: #56b6c2;
}
.sk_theme .omnibar_highlight {
    color: #e06c75;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
    background: #2c313a;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
    background: #3e4452;
}
#sk_status, #sk_find {
    font-size: 12pt;
}
`;

// --- 2. ATAJOS DE NAVEGACIÓN (VIM CORE) ---

// Mapear 'T' para buscar pestañas abiertas (Omnibar - Estilo Telescope/VSCode)
map('T', 'yt'); 

// Mapear 'F' para abrir links en pestañas nuevas (Hints)
map('F', 'gf');

// Mapear 'H' y 'L' para ir atrás/adelante en el historial (como en muchos configs de Vim)
map('H', 'S');
map('L', 'D');

// Mapear 'J' y 'K' para cambiar de pestaña rápidamente
map('J', 'E');
map('K', 'R');

// --- 3. BÚSQUEDA PERSONALIZADA ---
// Añadir búsqueda rápida en Forgejo o GitHub si lo deseas (ejemplo: 'g' seguido de búsqueda)
addSearchAlias('f', 'forgejo', 'https://github.com/search?q='); // Cambiar por tu URL de Forgejo

// --- 4. CONFIGURACIONES GENERALES ---
// Desactivar Surfingkeys en ciertos sitios (ej. editores de código online)
settings.blacklistPattern = /.*mail.google.com.*|.*docs.google.com.*/i;

// Enfocar el primer input automáticamente en ciertos sitios (opcional)
settings.stealFocusOnLoad = false;

// Suavizar el scroll
settings.smoothScroll = true;

// Mostrar siempre el estado (Modo actual)
settings.showModeStatus = true;
