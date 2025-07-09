return {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
	root_margers = { ".git" },
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = {
			schemaStore = {
				enable = true,
			},
		},
	},
}
