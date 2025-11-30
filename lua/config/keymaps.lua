local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>pv", vim.cmd.Ex)

map("n", "<leader>q", vim.diagnostic.setloclist)

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

map("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
map("n", "<right>", '<cmd>echo "Use l to move!!"')
map("n", "<up>", '<cmd>echo "Use k to move!!"')
map("n", "<down>", '<cmd>echo "Use j to move!!"')

map("n", "<C-h>", "<C-w><C-h>")
map("n", "<C-l>", "<C-w><C-l>")
map("n", "<C-j>", "<C-w><C-j>")
map("n", "<C-k>", "<C-w><C-k>")

map("i", "jj", "<Esc>", { desc = "exit insert mode" })

