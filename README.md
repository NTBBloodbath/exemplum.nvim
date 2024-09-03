# exemplum.nvim
Seamlessly refactor code chunks within your projects while keeping an eye on the initial
implementation. By providing an intuitive interface, it simplifies the process of modifying
functions, variables, structs, enums, and other code elements without disrupting your workflow.

![exemplum demo](https://github.com/user-attachments/assets/b6a2c395-a6ce-4a6b-9990-43ac4db05d0e)

> [!IMPORTANT]
>
> 1. The plugin is in early development, so it may not work with certain languages. If your
> language is not supported, please create an issue.
> 2. For the same reason above, you may encounter a bug at some point (I hope you don't!). Please
> report it with reproduction steps if possible.

## Key features

- **Code chunk identification**: automatically identifies the current code chunk based on your
cursor position or the desired code chunk type.
- **Refactoring in a separate window**: opens a dedicated floating window or split for editing and
refactoring the code chunk, keeping your original code intact until you finish the modifications.
- **Syntax highlighting and completion**: provides syntax highlighting and code completion within
the refactoring window for a smooth editing experience.

## Benefits of using exemplum

- **Improved code quality**: easily refactor code to enhance readability, maintainability and
performance.
- **Increased productivity**: streamline the refactoring process, saving time and effort.
- **Reduced errors**: minimize the risk of introducing errors during code modifications thanks to
the side-to-side view of your codebase.

## Installation

- [rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim) (recommended):
```vim
:Rocks install exemplum.nvim
```

- [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
require("lazy").setup({
  {
    "NTBBloodbath/exemplum.nvim",
    dependencies = { "NTBBloodbath/logging.nvim" },
  },
})
```

> [!NOTE]
>
> If you are going for lazy-loading, it would be recommended to load by `filetype`. Below you can
> find the languages that are currently supported.

### Configuration

`exemplum.nvim` is configured through the `vim.g.exemplum` global variable. The following is the
default configuration:

```lua
---@type ExemplumConfig
vim.g.exemplum = {
  window = {
    style = "split",
    border = "single",
  },
  disable_diagnostics = false,
}
```

The configuration is annotated, so you should have a good experience editing it.

## Usage

`exemplum.nvim` does not require a `setup` function to work and automatically creates the `:Exemplum`
command when loaded.

- **Refactor nearest code chunk**: use `:Exemplum` command to refactor the nearest code chunk under
  your cursor position.
- **Refactor a specific code chunk**: use `:Exemplum <code_type>` to refactor the `code_type`
  tree-sitter node that is near to your cursor position. For example, to refactor a
  function place your cursor anywhere inside the function and run `:Exemplum function`.

Currently available `code_type` arguments:
- `function`
- `variable`
- `struct`
- `enum`

After performing a refactoring you can either save the buffer so it will be closed and the changes
will be applied or you can close the buffer using `:q` to close it without applying the changes.

> [!NOTE]
>
> 1. Exemplum works with a `look_behind` method. Therefore, it will always iterate over the current
> node and the parent node of the current node to find the code chunk.
> 2. The inference method (`:Exemplum` without arguments) depends heavily on the current position of
> your cursor, and prioritizes variables over functions.

### Supported languages

- `C++`
- `Lua` (does not support `enum`s)
- `Rust`
- `Python`

## License

This project is licensed under the GNU General Public License v3 (GPLv3). You can find the license details in the [LICENSE](./LICENSE) file.
