return {
	cmd = { "glsl_analyzer" },
	-- lua/config/vulkan.lua maps every shader extension to the `glsl` filetype;
	-- the rest are upstream's defaults, harmless if they never match.
	filetypes = { "glsl", "vert", "tesc", "tese", "frag", "geom", "comp" },
	root_markers = { ".git" },
}
