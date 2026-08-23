import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

// =============================================================================
// PassageLauncher.qml
// Plugin de launcher DMS para gestionar la bóveda de contraseñas passage.
//   - Trigger: #pw (configurable en ajustes del plugin)
//   - Lista las entradas de la bóveda y ofrece acciones CRUD:
//       🔑 copiar contraseña | 6️⃣ copiar 2FA | ✏️ editar | 🗑️ borrar
//   - Acciones de gestión: ➕ nueva contraseña / 2FA, 🔄 refrescar
// =============================================================================
QtObject {
    id: root

    property var pluginService: null
    property string pluginId: "passage"
    property string trigger: "#pw"
    property var entries: []

    signal itemsChanged

    // ── Carga de la lista de entradas (async, vía passage-launcher list) ────
    function loadEntries() {
        listProcess.command = ["sh", "-c", "$HOME/.local/bin/passage-launcher list"];
        listProcess.running = true;
    }

    Process {
        id: listProcess
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.entries = JSON.parse(text().trim() || "[]");
                } catch (e) {
                    console.log("[Passage] fallo al parsear lista:", e.message);
                    root.entries = [];
                }
            }
        }
        onExited: function (code) {
            if (root.pluginService && typeof root.pluginService.requestLauncherUpdate === "function")
                root.pluginService.requestLauncherUpdate(root.pluginId);
        }
    }

    Component.onCompleted: {
        if (pluginService)
            trigger = pluginService.loadPluginData("passage", "trigger", "#pw");
        loadEntries();
    }

    // ── Items del launcher ──────────────────────────────────────────────────
    function getItems(query) {
        var items = [
            { name: "➕ Nueva contraseña", icon: "material:add", comment: "Crear una entrada de contraseña", action: "add_pw", categories: ["Passage"] },
            { name: "➕ Nuevo 2FA", icon: "material:key", comment: "Registrar un código 2FA (otpauth://)", action: "add_otp", categories: ["Passage"] },
            { name: "🔄 Refrescar bóveda", icon: "material:refresh", comment: "Recargar la lista de entradas", action: "refresh", categories: ["Passage"] }
        ];

        var entries = root.entries;
        for (var i = 0; i < entries.length; i++) {
            var n = entries[i].name;
            items.push({ name: n + "  🔑", icon: "material:lock", comment: "Copiar contraseña", action: "copy_pw:" + n, categories: ["Passage"] });
            if (entries[i].otp)
                items.push({ name: n + "  6", icon: "material:password", comment: "Copiar código 2FA", action: "copy_otp:" + n, categories: ["Passage"] });
            items.push({ name: n + "  ✏️", icon: "material:edit", comment: "Editar en el editor", action: "edit:" + n, categories: ["Passage"] });
            items.push({ name: n + "  🗑️", icon: "material:delete", comment: "Eliminar entrada", action: "del:" + n, categories: ["Passage"] });
        }

        if (query && query.trim().length) {
            var q = query.trim().toLowerCase();
            items = items.filter(function (it) {
                return it.name.toLowerCase().indexOf(q) !== -1 ||
                       it.comment.toLowerCase().indexOf(q) !== -1;
            });
        }
        return items;
    }

    // ── Ejecución de acciones ───────────────────────────────────────────────
    function executeItem(item) {
        if (!item || !item.action)
            return;
        var p = item.action.split(":");
        var type = p[0];
        var data = p.slice(1).join(":");

        switch (type) {
        case "copy_pw":
            run(["sh", "-c", "passage -c " + shellQuote(data)]);
            showToast("Contraseña copiada: " + data);
            break;
        case "copy_otp":
            run(["sh", "-c", "passage otp -c " + shellQuote(data)]);
            showToast("2FA copiado: " + data);
            break;
        case "edit":
            run(["sh", "-c", "$HOME/.local/bin/passage-launcher edit " + shellQuote(data)]);
            break;
        case "del":
            run(["sh", "-c", "$HOME/.local/bin/passage-launcher delete " + shellQuote(data)]);
            break;
        case "add_pw":
            run(["sh", "-c", "$HOME/.local/bin/passage-launcher add-password"]);
            break;
        case "add_otp":
            run(["sh", "-c", "$HOME/.local/bin/passage-launcher add-otp"]);
            break;
        case "refresh":
            loadEntries();
            showToast("Actualizando bóveda...");
            break;
        }
    }

    function shellQuote(s) {
        return "'" + s.replace(/'/g, "'\\''") + "'";
    }

    function run(args) {
        Quickshell.execDetached(args);
    }

    function showToast(m) {
        if (typeof ToastService !== "undefined")
            ToastService.showInfo("Passage", m);
    }

    onTriggerChanged: {
        if (pluginService)
            pluginService.savePluginData("passage", "trigger", trigger);
    }
}
