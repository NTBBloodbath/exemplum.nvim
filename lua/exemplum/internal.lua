---@mod exemplum.internal

local config = require("exemplum.config")

local internal = {}

---Set up the `:Exemplum` command
local function set_up_command()
  vim.api.nvim_create_user_command("Exemplum", function(ctx)
    local fargs = ctx.fargs
    if #fargs > 1 then
      vim.g.exemplum.logger:error("Too many arguments were passed: 1 argument was expected, " .. #fargs .. " were provided")
    end

    if #fargs < 1 then
      vim.notify_once("exemplum.nvim WARN: The inference method is under development and may be inaccurate at times."
        .. " If you need precision in refactoring rather than quick editing, use arguments in the command invocation.",
        vim.log.levels.WARN)
      require("exemplum.components.infer").try_refactor()
    else
      local code_type = fargs[1]
      if vim.iter({ "function", "variable", "struct", "enum" }):find(code_type) then
        require("exemplum.components." .. code_type).refactor()
      else
        vim.g.exemplum.logger:error("Unknown code type to refactor: maybe not supported yet?")
      end
    end
  end, {
    desc = "Run exemplum.nvim",
    nargs = "?",
    complete = function(arg_lead, cmdline, _)
      local valid_arguments = { "function", "variable", "struct", "enum" }
      if cmdline:match("^Exemplum*%s+%w*$") then
        return vim.tbl_filter(function(cmd)
          if cmd:find("^" .. arg_lead) then
            return cmd
            ---@diagnostic disable-next-line missing-return
          end
        end, valid_arguments)
      end
    end
  })
end

---Load exemplum.nvim and set up the configuration, logger and commands
function internal.load()
  -- Setup the configuration and logger
  vim.g.exemplum = vim.tbl_deep_extend("force", config.defaults, vim.g.exemplum or {}, {
    logger = require("logging"):new({
      level = "info",
      plugin_name = "exemplum.nvim",
    }),
  })

  -- Setup the `:Exemplum` command
  set_up_command()

  -- Setup the required autocommand group
  vim.api.nvim_create_augroup("Exemplum", { clear = true })
end

return internal
