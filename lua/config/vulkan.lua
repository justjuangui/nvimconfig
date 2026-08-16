vim.filetype.add({
	extension = {
		vert = "glsl",
		frag = "glsl",
		comp = "glsl",
		geom = "glsl",
		tesc = "glsl",
		tese = "glsl",
		rgen = "glsl",
		rchit = "glsl",
		rmiss = "glsl",
	}
})

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "*.vert", "*.frag", "*.comp" },
	callback = function(args)
		vim.fn.jobstart({ "glslc", args.file, "-o", args.file .. ".spv" })
	end,
})
