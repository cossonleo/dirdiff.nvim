local api = vim.api

local M = {
	float_win_id = 0,
}

function M:create_float_win(buf_id)
	self.float_win_id = api.nvim_open_win(buf_id, true, self:get_float_win_config())
    api.nvim_win_set_option(self.float_win_id, 'winhl', 'Normal:Pmenu,NormalNC:Pmenu')
    api.nvim_win_set_option(self.float_win_id, 'foldenable', false)
    api.nvim_win_set_option(self.float_win_id, 'wrap', true)
    api.nvim_win_set_option(self.float_win_id, 'statusline', '')
    api.nvim_win_set_option(self.float_win_id, 'number', true)
    api.nvim_win_set_option(self.float_win_id, 'relativenumber', false)
    api.nvim_win_set_option(self.float_win_id, 'cursorline', true)
    api.nvim_win_set_option(self.float_win_id, 'signcolumn', "no")
end

function M:get_float_win_config()
	local columns = api.nvim_get_option('columns')
	local lines = api.nvim_get_option("lines")
	local float_win_config = {}
	float_win_config.relative = "editor"
	float_win_config.height = math.floor(lines * 3 / 4)
	float_win_config.width = math.floor(columns / 2)
	float_win_config.row = math.floor(lines / 8)
	float_win_config.col = math.floor(columns / 4)
	return float_win_config
end

function M:close_float_win()
	if self.float_win_id == 0 then
		return
	end
	api.nvim_win_close(self.float_win_id, false)
	self.float_win_id = 0
end

return M
