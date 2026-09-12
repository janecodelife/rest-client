# rest-client.nvim 

[![Follow on X](https://img.shields.io/badge/Follow-@janecodelife-000000?style=for-the-badge&logo=x)](https://x.com/janecodelife)
[![Subscribe on YouTube](https://img.shields.io/badge/Subscribe-@JaneCodeLife-FF0000?style=for-the-badge&logo=youtube)](https://www.youtube.com/@JaneCodeLife)

A lightweight, minimal, and fast HTTP requests (GET, POST, PUT, DELETE, etc.) REST client for Neovim 0.12+ built entirely on top of Neovim's native networking APIs . support all kind of files . so run it anywhere , everywhere in a blink

--- 

💝 Support me by the only available way now: USDT to buy a new dev laptop. Info is below, 
or contact me by 
📩 email: janecodelife@gmail.com

---

## ✨ Features

- ⚡ **Run it directly from under the cursor** hover about url and run the keymap <leader>hr.
- 🔄 **Asynchronous Execution:** Your UI will never freeze or lock while waiting for an API response.
- 🎛️ **Smart Multiline Block Parsing:** Place your cursor anywhere inside an HTTP instruction block, and the plugin will dynamically find the correct method, headers, and payload.
- 🎨 **Smart Auto-formatting:** Automatically formats and pretty-prints JSON responses in a vertical split window.

--- 

## 📦 Prerequisites 

```bash
curl

```

---

## 📥 Installation & Configuration


```lua
vim.pack.add({
	"https://github.com/janecodelife/rest-client.nvim",
})

require("rest-client").setup({
	keymap = "<leader>hr", -- Specify your preferred keyboard shortcutto run the request when you above url
})

```

---

## How To Use

Create a test file (e.g., `test.http` or `api.rest` or `test.txt` or `test.php` or `test.lua` or even `whatever.whatever :D`) and format your endpoints sequentially. Put your cursor anywhere inside or directly below the block you want to test and press your configured keymap (default: `<leader>hr`).

### Example File Layout:

```http

GET https://dummyjson.com/products
GET https://dummyjson.com/todos

POST https://dummyjson.com/auth/login
header: {"Content-Type": "application/json"}
body: {
  "username":"emilys","password":"emilyspass","expiresInMins":100
}

```
---

## 📦 Installation & Setup

---

## Video 📺

<p align="center">
  <img src="assets/make_http_request_in_blink_without_leaving_buffer.gif" alt="make_http_request_in_blink_without_leaving_buffer-video" width="100%">
</p>

or in 

- **YouTube**: [https://www.youtube.com/watch?v=jBUKpSBhoxI](https://www.youtube.com/watch?v=jBUKpSBhoxI) 

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

##  If Have A Question🤝 (Contact Me)

I will be there i am answer to all messages

- **X (Twitter)**: [https://x.com/janecodelife](https://x.com/janecodelife)
- **YouTube**: [https://www.youtube.com/@JaneCodeLife](https://www.youtube.com/@JaneCodeLife) 
- **Email**: [janecodelife@gmail.com](janecodelife@gmail.com)

---

## 🔗 My Other Plugins

Check out my other open-source tools to supercharge your Neovim environment:
- **[livewire-secure-properties](https://github.com/janecodelife/livewire-secure-properties)** - Secure livewire app properties by default and void headache.
- **[todo-tracker.nvim](https://github.com/janecodelife/todo-tracker.nvim)** - Assign and list app todos in a blink
- **[folders-bookmark.nvim](https://github.com/janecodelife/folders-bookmark.nvim)** - Bookmark folders and accessing them by keymap in a blink
- **[copy-history.nvim](https://github.com/janecodelife/copy-history.nvim)** - Access your copy (Yank) history and paste it again by 1 click in a blink.
- **[rest-client.nvim](https://github.com/janecodelife/rest-client.nvim)** - run http request from anywhere in a blink

---

## Upcoming 🚀 (Stay Tuned!)

### The Ultimate Neovim Config for Modern Web & Laravel Devs ⚡

I am currently cooking a comprehensive guide and boilerplate configuration on **How to turn Neovim into a (Powerful) IDE** explicitly optimized for:

- **Backend & Frameworks**: PHP (Intelephense) & Full Laravel & Livewire Integration (With Preformance)
- **Frontend & Tooling**: HTML, CSS, JavaScript, TypeScript, and Livewire SFCs
- **Speed**: Blazing fast autocompletion, lightning-speed code navigation, and fuzzy finding.

