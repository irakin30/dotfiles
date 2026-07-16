return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { image = {} } },
  },
  opts = function(_, opts)
    opts.defaults.preview = {
      mime_hook = function(filepath, bufnr, inner_opts)
        local ext = (filepath:match "%.([^%.]+)$" or ""):lower()
        local images = { png = true, jpg = true, jpeg = true, gif = true, bmp = true, webp = true, tiff = true }
        if images[ext] and Snacks.image.supports(filepath) then
          Snacks.image.buf.attach(bufnr, { src = filepath })
        else
          require("telescope.previewers.utils").set_preview_message(bufnr, inner_opts.winid, "Binary cannot be previewed")
        end
      end,
    }
    return opts
  end,
}
