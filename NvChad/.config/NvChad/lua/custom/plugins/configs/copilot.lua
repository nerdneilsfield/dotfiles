return {
	method = "getCompletionsCycling",
	force_autofmt = false,
	clear_after_cursor = true,
	formatters = {
		label = require("copilot_cmp.format").format_label_text,
		insert_text = require("copilot_cmp.format").format_insert_text,
		preview = require("copilot_cmp.format").deindent,
	},
}
