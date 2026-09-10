# rest-client.nvim (STEEL UNDER WORKING)
# NOW SUPPORT (GET REQUEST ONLY)

# rest-client.nvim

A lightweight, asynchronous, and pure Lua REST client plugin for Neovim built on top of `vim.system`. Test your HTTP requests (GET, POST, PUT, DELETE, etc.) directly from your active buffers without leaving Neovim.

## Features

- **No Heavy Dependencies:** Works out of the box using Neovim's modern native `vim.system` execution API (No external Lua HTTP libraries needed).
- **Asynchronous & Non-Blocking:** Requests run entirely in the background—Neovim will never freeze or hang during slow network transfers.
- **Smart Multiline Block Parsing:** Place your cursor anywhere inside an HTTP instruction block, and the plugin will dynamically find the correct method, headers, and payload.
- **Error-Tolerant Feedback:** Unlike standard internal wrappers, server faults (like `401 Unauthorized` or `404 Not Found`) do not fail silently—the plugin splits the accurate raw payload into a standalone scratchpad buffer for debugging.
- **Human-Centric Layout:** The response view prioritizes the **Formatted Response Body** right at the top for faster code focus, shifting verbose network headers down to a secondary scrollable view.

---

## Installation

### Using [lazy.nvim](https://github.com)

```lua
{
  "your-github-username/rest-client.nvim",
  config = function()
    require("rest-client").setup({
      keymap = "<leader>hr" -- Customize your favorite trigger key here
    })
  end
}
```

### Using Native Vim Packages (`pack/`)

Clone the repository directly inside your packet start loop folder structure:

```bash
git clone https://github.com ~/.local/share/nvim/site/pack/plugins/start/rest-client.nvim
```

Then initialize it in your primary `init.lua` config file:

```lua
require("rest-client").setup({
  keymap = "<leader>hr" -- Specify your preferred keyboard shortcut
})
```

---

## Configuration

You can fully customize the behavior of the plugin by passing options to the `.setup()` module function:

```lua
require("rest-client").setup({
  -- The global shortcut string used to trigger requests under the cursor
  keymap = "<leader>hr", 
  
  -- The visual description text used by Neovim's mapping system
  mapping_desc = "Execute REST client request under cursor",
})
```

---

## Usage Guide

Create a test file (e.g., `test.http` or `api.rest`) and format your endpoints sequentially. Put your cursor anywhere inside or directly below the block you want to test and press your configured keymap (default: `<leader>hr`).

### Example File Layout:

```http
GET https://dummyjson.com

GET https://dummyjson.com

POST https://dummyjson.com
header: {"Content-Type": "application/json"}
body: {
    "username": "emilys",
    "password": "emilyspass",
    "expiresInMins": 60
}
```

### Scratchpad View Interactivity
When a request completes successfully, a new vertical split window opens dynamically. Inside the response buffer view:
- Press `q` or `<Esc>` to quickly close the response window.
- Syntax highlighting is auto-applied to `json` or `html` data blueprints seamlessly.

---

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

