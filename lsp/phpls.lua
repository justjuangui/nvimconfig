return {
	cmd = { 'intelephense', '--stdio' },
	filetypes = { 'php' },
	root_martkers = { 'composer.json', 'composer.lock', '.git' },
	settings = {
		intelephense = {
			files = {
				maxSize = 1000000, -- 1MB
			},
			stubs ={
				"wordpress-globals",
				"wordpress"
			},
			environment = {
				includePaths = {
					"C:/Users/JUANGUI/Downloads/Divi/Divi/",
					"C:/Users/JUANGUI/AppData/Roaming/Composer/vendor/php-stubs/"
				}
			}
		}
	}
}
