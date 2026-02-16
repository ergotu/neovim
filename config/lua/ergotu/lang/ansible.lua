local linting = Ergovim.langs.linting

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
