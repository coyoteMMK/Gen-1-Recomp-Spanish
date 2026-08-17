-- Spanish mod entry point.
-- Keep the existing main.lua intact and layer the long-tail Spanish fixes on top.
return function(mod)
  local function load_table(path)
    local body = mod:read(path)
    if not body then return nil end
    local chunk, err = loadstring(body, path)
    if not chunk then
      mod.log:warn("%s has a syntax error: %s", path, tostring(err))
      return nil
    end
    local ok, value = pcall(chunk)
    if not ok or type(value) ~= "table" then
      mod.log:warn("%s did not return a table", path)
      return nil
    end
    return value
  end

  -- First run the mod's existing translation entry point unchanged.
  local base_body = mod:read("main.lua")
  if base_body then
    local base_chunk, err = loadstring(base_body, "main.lua")
    if base_chunk then
      local ok, base = pcall(base_chunk)
      if ok and type(base) == "function" then
        local ran, base_err = pcall(base, mod)
        if not ran then mod.log:warn("main.lua failed: %s", tostring(base_err)) end
      else
        mod.log:warn("main.lua did not return a function: %s", tostring(base_err))
      end
    else
      mod.log:warn("main.lua has a syntax error: %s", tostring(err))
    end
  end

  -- Apply the long-tail catalog after the generated catalog so these values
  -- intentionally win over incomplete/blank generated translations.
  local extra = load_table("lang/extra_strings.lua")
  if extra then
    local count = 0
    for source, value in pairs(extra) do
      if type(source) == "string" and type(value) == "string" and value ~= "" then
        mod.content.strings:override(source, value)
        count = count + 1
      end
    end
    mod.log:info("Español: %d extra engine strings applied", count)
  end

  -- literal_handlers.lua contains map/NPC text that cannot be represented
  -- as ordinary engine-string overrides. It is optional so this wrapper does
  -- not break if a future API removes map_scripts.
  local handlers = mod:read("lang/literal_handlers.lua")
  if handlers and mod.content.map_scripts then
    local chunk, err = loadstring(handlers, "lang/literal_handlers.lua")
    if chunk then
      local ok, installer = pcall(chunk)
      if ok and type(installer) == "function" then
        local installed, install_err = pcall(installer, mod)
        if not installed then
          mod.log:warn("literal_handlers.lua failed: %s", tostring(install_err))
        end
      else
        mod.log:warn("literal_handlers.lua did not return a function")
      end
    else
      mod.log:warn("literal_handlers.lua has a syntax error: %s", tostring(err))
    end
  end
end
