------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = "DP-2",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

hl.monitor({
	output = "HDMI-A-3",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

-- Workspace on monitors
hl.workspace_rule({ workspace = "1", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "DP-2", persistent = true })
hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-3", persistent = true })
hl.workspace_rule({ workspace = "7", monitor = "HDMI-A-3", persistent = true })
hl.workspace_rule({ workspace = "8", monitor = "HDMI-A-3", persistent = true })
hl.workspace_rule({ workspace = "9", monitor = "HDMI-A-3", persistent = true })
hl.workspace_rule({ workspace = "10", monitor = "HDMI-A-3", persistent = true })
