# Changelog

## 1.0.0 (2024-09-03)


### Features

* add `plugin/exemplum.lua` ([33b3e05](https://github.com/NTBBloodbath/exemplum.nvim/commit/33b3e05890be00d6b86c77bce1933a55e2f72c88))
* add `winbuf` module (empty atm) ([a55dbe4](https://github.com/NTBBloodbath/exemplum.nvim/commit/a55dbe42e6651623ed6c424d9f9a123275b6fb2a))
* add C support ([2b2f1d9](https://github.com/NTBBloodbath/exemplum.nvim/commit/2b2f1d91aada5805be47274f4ffd7dcc14f560a9))
* add Go support ([c820462](https://github.com/NTBBloodbath/exemplum.nvim/commit/c820462338ed6a684b3574e083e33763ac3bbb92))
* add initial `config` module, not working atm ([09c8986](https://github.com/NTBBloodbath/exemplum.nvim/commit/09c8986b851b84863b94909abd475468d59ef6ff))
* add scm rockspec ([363c06a](https://github.com/NTBBloodbath/exemplum.nvim/commit/363c06a2c31b4c5382b955e07a54fec7457d81d2))
* add skeleton for exemplum Lua module ([ee60016](https://github.com/NTBBloodbath/exemplum.nvim/commit/ee600168d6f9d048de6942abe4de140b4e92dc24))
* add support for structs and enums ([f869fe4](https://github.com/NTBBloodbath/exemplum.nvim/commit/f869fe4ebcecc7f9bb795de01ba1e1ba6e8ee6ba))
* allow `:Exemplum!` execution (command with bang), at the moment this disables diagnostics in the refactoring buffer ([253a992](https://github.com/NTBBloodbath/exemplum.nvim/commit/253a99285df89c4c87ff6e48677bf6cbba289d18))
* **ci:** add formatting workflow ([51d29e6](https://github.com/NTBBloodbath/exemplum.nvim/commit/51d29e6ff32fdfe41d2c137359dd17a61857be6f))
* **ci:** add release and luarocks CIs ([550b3dc](https://github.com/NTBBloodbath/exemplum.nvim/commit/550b3dc2aeab79e799f7a3b89945a42b41d81950))
* **components:** add C++ support ([3e7f9c7](https://github.com/NTBBloodbath/exemplum.nvim/commit/3e7f9c75b7f86b2db4a6692c2acae047c1247cfd))
* **components:** add Python support ([ecbf53b](https://github.com/NTBBloodbath/exemplum.nvim/commit/ecbf53be51496ed4e5ed841b884fa558fa3e2bb7))
* initial working version, currently only works with Lua and Rust files ([1625386](https://github.com/NTBBloodbath/exemplum.nvim/commit/16253864ff831ef3369c395dd546b2b7875b5ce1))
* **rockspec:** add `logging.nvim` as a dependency ([3706ae6](https://github.com/NTBBloodbath/exemplum.nvim/commit/3706ae62efd0596f2b431d1fc5e84ac40dd46029))


### Bug Fixes

* adapt codebase to latest config syntax changes ([4197aae](https://github.com/NTBBloodbath/exemplum.nvim/commit/4197aae30ea3e69ee487a2a07c5d41b97d4b44dc))
* **components:** apply refactoring changes only when saved the refactor buffer using a command to write (e.g. `:w`), discard the refactoring when leaving without saving (e.g. `:q`) ([d23c33b](https://github.com/NTBBloodbath/exemplum.nvim/commit/d23c33b6ff2437c7db3f3500d6780eff3f022a9e))
* **components:** better error handling when outside the desired refactoring scope, make refactor functions return the node range ([4b4020b](https://github.com/NTBBloodbath/exemplum.nvim/commit/4b4020b7c0db3875866937de5d00d560e40e1331))
* **components:** invalid buffer ID when modifying the `modified` option state on `BufLeave` ([d0659a1](https://github.com/NTBBloodbath/exemplum.nvim/commit/d0659a1211bd42cf3c2f48ac501f789585f82901))
* **components:** set `modified` status to `false` when closing the refactor window ([fad572a](https://github.com/NTBBloodbath/exemplum.nvim/commit/fad572a1dee104945c28da521c635e63234637c6))
* **components:** use exemplum logger instead of `error` function for the filetype support errors ([2164bb7](https://github.com/NTBBloodbath/exemplum.nvim/commit/2164bb7969d72151c946276a8987a6604d7502da))
* **rockspec:** remove non-existent directory ([1457c26](https://github.com/NTBBloodbath/exemplum.nvim/commit/1457c26c6a1a1c7c245d538ef2aed52c2c0ff624))
* **winbuf:** split right, set window focus ([0f4d587](https://github.com/NTBBloodbath/exemplum.nvim/commit/0f4d587f95de3851c7f25e6be15a3a318f787fb6))


### Reverts

* **components:** make refactor functions return the node range ([fe121a1](https://github.com/NTBBloodbath/exemplum.nvim/commit/fe121a1671f936c9a5c527724f2c5a27a9fb2e06))
