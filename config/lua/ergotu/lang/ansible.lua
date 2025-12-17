local linting = require("ergotu.config.linting")

-- Ansible Linter
linting.add_linter("ansible", { "ansible_lint" })

-- Ansible plugin for syntax highlighting and filetype detection
---@type lz.n.Spec[]
return {
  {
    "ansible-vim",
    ft = "ansible",
  },
}
