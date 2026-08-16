return {
	cmd = { "intelephense", "--stdio" },
	filetypes = { "php" },
	root_markers = { ".git", "composer.json" },
	settings = {
		intelephense = {
			files = {
				maxSize = 10000000, -- 10MB
			},
			environment = {
				phpVersion = "8.2",
				-- includePaths took a list of absolute Windows paths to WordPress/ACF
				-- stubs that do not exist on this machine. Add per-project stub dirs
				-- here (or in a project-local .nvim.lua) if you need them again.
			},
		},
	},
}
