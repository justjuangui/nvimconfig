vim.cmd([[
let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf-8'';Remove-Alias -Force -ErrorAction SilentlyContinue tee;'
let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
let &shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
set shellquote= shellxquote=
]])
-- terminal settings
-- vim.opt.shell = vim.fn.executable('pwsh') and 'pwsh' or 'powershell'
-- vim.opt.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
-- vim.opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
-- vim.opt.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
-- vim.opt.shellquote = ''
-- vim.opt.shellxquote = ''
-- vim: ts=2 sts=2 sw=2 et
