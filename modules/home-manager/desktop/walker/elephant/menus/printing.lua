Name = "printing"
NamePretty = "Printing"
Icon = "printer"
Cache = false
Action = "%VALUE%"

function GetEntries()
	return {
		{ Text = "Printer Settings", Subtext = "Add and configure printers", Value = "system-config-printer", Icon = "printer" },
		{ Text = "CUPS Web UI", Subtext = "Manage printers in the browser", Value = "xdg-open http://localhost:631", Icon = "preferences-system-network" },
	}
end
