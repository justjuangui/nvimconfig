--@type vim.lsp.Config
return {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		-- Never auto-insert #include on completion: with Vulkan/GLFW the guess is
		-- usually an internal header rather than the umbrella one you want.
		"--header-insertion=never",
		"--completion-style=detailed",
		-- Fall back to a guessed command for files not in compile_commands.json,
		-- so a brand-new .cpp still gets diagnostics before you re-run CMake.
		"--fallback-style=none",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	-- No `.git` in ~/games/vk-triangle, so the usual git-root marker never fires.
	-- compile_commands.json lives in build/, hence the explicit build path.
	root_markers = {
		".clangd",
		"compile_commands.json",
		"build/compile_commands.json",
		"CMakeLists.txt",
		".git",
	},
	-- No `capabilities` here on purpose: blink.cmp registers its own onto
	-- vim.lsp.config('*') from its plugin/ dir, so every server inherits them.
	-- See lua/plugins/autocompletion.lua.
}
