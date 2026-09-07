# rest-client.nvim

A lightweight, minimal, and fast HTTP REST client for **Neovim 0.12+** built entirely on top of Neovim's native networking APIs (`vim.net.request`). 

No heavy external curl dependencies or external Lua wrappers required—just clean, native asynchronous requests.

---

## ✨ Features

- ⚡ **Zero External Dependencies:** Built strictly using native Neovim 0.12 network functions.
- 🔄 **Asynchronous Execution:** Your UI will never freeze or lock while waiting for an API response.
- 🎨 **Smart Auto-formatting:** Automatically formats and pretty-prints JSON responses in a vertical split window.
- 🎛️ **Comment Agnostic:** Safely parses HTTP requests even if they are commented out using Lua (`--`), JavaScript (`//`), or Bash/Env (`#`) comment prefixes.

---

## 📦 Installation & Setup



```lua
vim.pack.add({
	"https://github.com/janecodelife/rest-client",
})

require("rest-client").setup({
	keymap = "<leader>r",
})

-- GET https://dummyjson.com/products
-- GET https://dummyjson.com/todos


```

---

## 🚀 How to Use

Place your cursor on any valid URL line inside any file buffer and press your configured shortcut keymap (or run the user command). 
