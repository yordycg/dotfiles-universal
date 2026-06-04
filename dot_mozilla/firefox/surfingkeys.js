// =============================================================================
// SURFINGKEYS CONFIG - REFINADO (ESTILO TELESCOPE / CATPPUCCIN)
// =============================================================================

// --- 1. ESTÉTICA AVANZADA (OMNIBAR CENTRADA Y MODERNA) ---
settings.theme = `
#sk_omnibar {
    width: 60% !important;
    left: 20% !important;
    top: 20% !important;
    background: #1e1e2e !important;
    border: 1px solid #45475a !important;
    box-shadow: 0px 15px 45px rgba(0,0,0,0.7) !important;
    border-radius: 12px !important;
    font-family: "JetBrainsMono Nerd Font", "FiraCode Nerd Font", monospace !important;
    padding: 10px !important;
}
.sk_theme input {
    color: #cdd6f4 !important;
    background: #313244 !important;
    font-size: 18px !important;
    padding: 12px !important;
    border-radius: 6px !important;
    border: none !important;
    outline: none !important;
    width: 100% !important;
}
.sk_theme #sk_omnibarSearchResult {
    margin-top: 10px !important;
}
.sk_theme #sk_omnibarSearchResult ul li {
    padding: 10px 15px !important;
    font-size: 15px !important;
    border-radius: 4px !important;
    margin: 2px 0 !important;
    color: #a6adc8 !important;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
    background: #181825 !important;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
    background: #45475a !important;
    color: #f5e0dc !important;
}
.sk_theme .url {
    color: #89b4fa !important;
    font-size: 12px !important;
    margin-left: 10px !important;
}
.sk_theme .omnibar_highlight {
    color: #f38ba8 !important;
    font-weight: bold !important;
}
#sk_status, #sk_find {
    font-size: 11pt !important;
    background: #1e1e2e !important;
    color: #cdd6f4 !important;
    border: 1px solid #45475a !important;
    padding: 5px 10px !important;
    border-radius: 4px !important;
}
/* Hints (letras amarillas) más legibles */
#sk_hints .sk_hint {
    background: #f9e2af !important;
    color: #11111b !important;
    font-weight: bold !important;
    border: 1px solid #fab387 !important;
    font-size: 12px !important;
    padding: 2px 4px !important;
    border-radius: 3px !important;
}
`;

// --- 2. ATAJOS DE NAVEGACIÓN ---

// Omnibar (Telescope-style)
map('T', 'yt');  // Búsqueda de pestañas
map('b', 'ob');  // Búsqueda de marcadores (bookmarks)

// Navegación de pestañas (J y K como en Vim)
map('J', 'E');   // Pestaña izquierda
map('K', 'R');   // Pestaña derecha

// Movimiento en historial
map('H', 'S');   // Atrás
map('L', 'D');   // Adelante

// Abrir enlaces (Hints)
map('f', 'f');   // Abrir en misma pestaña
map('F', 'gf');  // Abrir en nueva pestaña

// Cerrar pestaña rápidamente
map('x', 'x');

// --- 3. EXCLUSIONES Y COMPORTAMIENTO ---
settings.blacklistPattern = /.*mail.google.com.*|.*docs.google.com.*|.*github.com.*|.*forgejo.*/i;
settings.smoothScroll = true;
settings.stealFocusOnLoad = true;
`;
