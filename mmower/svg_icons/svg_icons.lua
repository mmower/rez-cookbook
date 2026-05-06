-- Convert a folder of .svg icons into inlined SVG icon assets
-- Pass in the local asset folder where the icons are to be processed from
--
-- Usage:
-- @pragma(after_process_ast) mmower/svg_icons ("assets/img/icons")
--
-- Implementation:
-- receives 'compilation' and 'values'
-- values[1] is the path where the Heroicon .svg files should be
-- the plugin will create an inlined asset for each file
-- arrow-path.svg becomes icon_arrow_path
-- whose content attribute is the SVG source

function clean_filename(filename)
  filename = filename:gsub("-", "_")
  filename = filename:gsub("%.svg$", "")
  return filename
end

function make_icon_asset(id, path)
  local asset = rez.asset.make(id, path)
  asset = rez.node.set_attr_value(asset, "$inline", "boolean", true)
  return asset;
end

do
  local icons_path = values[1]

  local files, err = rez.plugin.ls(icons_path)
  if files then
    for i, icon_file in ipairs(files) do
      local icon_name = clean_filename(icon_file)
      local asset_id = "icon_" .. icon_name
      local icon_path = icons_path .. "/" .. icon_file
      local icon_asset = make_icon_asset(asset_id, icon_path)

      compilation = rez.compilation.add_content(compilation, icon_asset)
    end
  end

  return compilation
end