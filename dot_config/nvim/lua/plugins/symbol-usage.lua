-- symbol-usage.nvim: shows reference/definition counts as virtual text
-- like Rider's "X usages" inline
return {
  "Wansmer/symbol-usage.nvim",
  event = "VeryLazy",
  opts = {
    text_format = function(symbol)
      local kind = (symbol.kind or ""):lower()
      local def = symbol.definition_count
      local ref = symbol.reference_count
      if def > 0 and ref > 0 then
        return string.format(" [%d def | %d ref]", def, ref)
      elseif def > 0 then
        return string.format(" [%d def]", def)
      elseif ref > 0 then
        return string.format(" [%d ref]", ref)
      end
      return ""
    end,
  },
}
