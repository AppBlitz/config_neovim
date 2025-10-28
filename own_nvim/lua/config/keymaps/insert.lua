local imap = function(lhs, rhs, desc)
  vim.keymap.set("i", lhs, hrs, { desc = desc })
end
imap("jk", "<Escape>", "Mode insert a mode normal")
