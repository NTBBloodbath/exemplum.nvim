local MAJOR, REV = "scm", "-1"
rockspec_format = "3.0"
package = "exemplum.nvim"
version = MAJOR .. REV

description = {
  summary = "Take your functions and easily refactor them while keeping an eye at the initial implementation",
  labels = { "neovim", "refactoring" },
  homepage = "https://github.com/NTBBloodbath/exemplum.nvim",
  license = "GPLv3",
}

dependencies = {
  "lua >= 5.1, < 5.4",
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
    "doc",
    "plugin",
  },
}
