// =============================================================================
// SURFINGKEYS CONFIG - REFINADO (ESTILO TELESCOPE / MINIMALISTA)
// =============================================================================

// --- 1. ESTÉTICA AVANZADA (OMNIBAR CENTRADA) ---
settings.theme = `
#sk_omnibar {
    width: 50%;
    left: 25%;
    top: 15%;
    background: #1e1e2e; /* Catppuccin Mocha Background */
    border: 1px solid #45475a;
    box-shadow: 0px 10px 30px rgba(0,0,0,0.5);
    border-radius: 8px;
    font-family: "JetBrainsMono Nerd Font", "FiraCode Nerd Font", monospace;
}
.sk_theme input {
    color: #cdd6f4;
    font-size: 16px;
    padding: 10px;
}
.sk_theme #sk_omnibarSearchResult ul li {
    padding: 8px 12px;
    font-size: 14px;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
    background: #181825;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
    background: #313244;
}
.sk_theme .url {
    color: #89b4fa;
    font-weight: normal;
}
.sk_theme .omnibar_highlight {
    color: #f38ba8;
}
#sk_status, #sk_find {
    font-size: 10pt;
    background: #1e1e2e;
    color: #cdd6f4;
    border: 1px solid #45475a;
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

// Desactivar en sitios donde los atajos nativos son mejores (Evita conflictos)
settings.blacklistPattern = /.*mail.google.com.*|.*docs.google.com.*|.*github.com.*|.*forgejo.*/i;

// Suavizar el scroll
settings.smoothScroll = true;

// Permitir que las webs roben el foco (útil para buscadores nativos)
settings.stealFocusOnLoad = true;
