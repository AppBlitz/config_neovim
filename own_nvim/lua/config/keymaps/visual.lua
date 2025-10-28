local vmap = function(lhs, rhs, desc)
  vim.keymap.set("v", lhs, rhs, { desc = desc })
end
