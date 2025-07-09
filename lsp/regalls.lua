return {
	cmd = { "regal", "language-server" },
	filetypes = { "rego" },
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local hit = vim.fs.find({ ".git", "rego.mod" }, { upward = true, path = fname })[1]
		local dir = vim.fs.dirname(hit or fname)

		dir = vim.uv.fs_realpath(dir) or dir
		dir = dir
			:gsub("^\\\\", "") -- strip accidental UNC “\\”
			:gsub("^\\\\%?\\", "") -- strip \\?\ variant
			:gsub("\\", "/") -- forward slashes are safest
		vim.print("regal: root_dir", dir)
		on_dir(dir)
	end,
}
