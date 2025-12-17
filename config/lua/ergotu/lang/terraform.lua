local formatting = require("ergotu.config.formatting")
local linting = require("ergotu.config.linting")
local lsp = require("ergotu.config.lsp")

-- Terraform LSP Server
lsp.add_server("terraformls", {})

-- Terraform Formatters
formatting.add_formatter("terraform", { "terraform_fmt" })
formatting.add_formatter("tf", { "terraform_fmt" })
formatting.add_formatter("terraform-vars", { "terraform_fmt" })
formatting.add_formatter("hcl", { "packer_fmt" })

-- Terraform Linter
linting.add_linter("terraform", { "terraform_validate" })
linting.add_linter("tf", { "terraform_validate" })
