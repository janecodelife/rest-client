# rest-client.nvim (STEEL UNDER WORKING)
# NOW SUPPORT (GET REQUEST ONLY)
A lightweight, minimal, and fast HTTP REST client for **Neovim 0.12+** built entirely on top of Neovim's native networking APIs . 
support all kind of files . so run it anywhere , everywhere in a blink

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

---

## 💝 Support the Project

> *This plugin is built entirely on developer insights gathered over **years of building real-world software** to catch common pain points, combined with **months of dedicated building and rigorous testing** to ensure it operates flawlessly.*

If this utility boosts your everyday speed and eliminates annoying file search clutter, please consider buying me a coffee or supporting my continuous maintenance!

You can tip or donate directly to my **TRON (TRX / USDT-TRC20)** crypto wallet address:
## ☕☕☕☕ Support Me (Buy Devlopment Labtop ) By Coffee Via USDT ☕☕☕☕

- **Network:** `TRX Tron (TRC20)`
- **Address:** `TAFFjBP39Z86weL5dDU1A2251VrgPprDUj`

> *Every bit of support fuels the expansion of this ecosystem and helps me write cleaner tools for all of us. Thank you for standing behind independent developers!* 🙏

---

