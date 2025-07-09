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
				includePaths = {
					"C:/Users/JUANGUI/Downloads/Divi/Divi/",
					"C:/Users/JUANGUI/AppData/Roaming/Composer/vendor/php-stubs/wordpress-globals/",
					"C:/Users/JUANGUI/AppData/Roaming/Composer/vendor/php-stubs/acf-pro-stubs/",
					"C:/Users/JUANGUI/AppData/Roaming/Composer/vendor/php-stubs/wordpress-stubs/",
				},
			},
		},
	},
}
