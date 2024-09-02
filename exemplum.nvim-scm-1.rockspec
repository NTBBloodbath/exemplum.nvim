local MAJOR, REV = "scm", "-1"
rockspec_format = "3.0"
package = "exemplum.nvim"
version = MAJOR .. REV

description = {
  summary = "Seamlessly refactor code chunks within your projects while keeping an eye on the initial implementation",
  labels = { "neovim", "tree-sitter", "refactoring-tools" },
  homepage = "https://github.com/NTBBloodbath/exemplum.nvim",
  license = "GPLv3",
}

dependencies = {
  "lua >= 5.1, < 5.4",
  "logging.nvim >= 1.1.0",
}

source = {
  url = "https://github.com/NTBBloodbath/exemplum.nvim/archive/" .. MAJOR .. ".zip",
  dir = "exemplum.nvim-" .. MAJOR,
}

if MAJOR == "scm" then
  source = {
    url = "git://github.com/NTBBloodbath/exemplum.nvim",
  }
end

build = {
  type = "builtin",
  copy_directories = {
    "plugin",
  },
}
