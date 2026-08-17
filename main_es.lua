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

  -- The Town Map is data-driven: these labels are not ordinary engine strings.
  -- Keep the original map and translate every selectable Gen-I location.
  -- Spanish names follow the Spain terminology used for the original games.
  if mod.content.field then
    local locations = {
      PALLET_TOWN = { name = "PUEBLO PALETA" },
      OAKS_LAB = { name = "PUEBLO PALETA" },
      VIRIDIAN_CITY = { name = "CIUDAD VERDE" },
      PEWTER_CITY = { name = "CIUDAD PLATEADA" },
      CERULEAN_CITY = { name = "CIUDAD CELESTE" },
      LAVENDER_TOWN = { name = "PUEBLO LAVANDA" },
      VERMILION_CITY = { name = "CIUDAD CARMÍN" },
      CELADON_CITY = { name = "CIUDAD AZULONA" },
      FUCHSIA_CITY = { name = "CIUDAD FUCSIA" },
      CINNABAR_ISLAND = { name = "ISLA CANELA" },
      INDIGO_PLATEAU = { name = "MESETA AÑIL" },
      SAFFRON_CITY = { name = "CIUDAD AZAFRÁN" },

      ROUTE_1 = { name = "RUTA 1" },
      ROUTE_2 = { name = "RUTA 2" },
      ROUTE_3 = { name = "RUTA 3" },
      ROUTE_4 = { name = "RUTA 4" },
      ROUTE_5 = { name = "RUTA 5" },
      ROUTE_6 = { name = "RUTA 6" },
      ROUTE_7 = { name = "RUTA 7" },
      ROUTE_8 = { name = "RUTA 8" },
      ROUTE_9 = { name = "RUTA 9" },
      ROUTE_10 = { name = "RUTA 10" },
      ROUTE_11 = { name = "RUTA 11" },
      ROUTE_12 = { name = "RUTA 12" },
      ROUTE_13 = { name = "RUTA 13" },
      ROUTE_14 = { name = "RUTA 14" },
      ROUTE_15 = { name = "RUTA 15" },
      ROUTE_16 = { name = "RUTA 16" },
      ROUTE_17 = { name = "RUTA 17" },
      ROUTE_18 = { name = "RUTA 18" },
      ROUTE_19 = { name = "RUTA MARÍTIMA 19" },
      ROUTE_20 = { name = "RUTA MARÍTIMA 20" },
      ROUTE_21 = { name = "RUTA MARÍTIMA 21" },
      ROUTE_22 = { name = "RUTA 22" },
      ROUTE_23 = { name = "RUTA 23" },
      ROUTE_24 = { name = "RUTA 24" },
      ROUTE_25 = { name = "RUTA 25" },
      SEA_ROUTE_19 = { name = "RUTA MARÍTIMA 19" },
      SEA_ROUTE_20 = { name = "RUTA MARÍTIMA 20" },
      SEA_ROUTE_21 = { name = "RUTA MARÍTIMA 21" },

      VIRIDIAN_FOREST = { name = "BOSQUE VERDE" },
      MT_MOON = { name = "MONTE MOON" },
      ROCK_TUNNEL = { name = "TÚNEL ROCA" },
      SEA_COTTAGE = { name = "CASA DEL MAR" },
      SS_ANNE = { name = "S.S. ANNE" },
      POKEMON_LEAGUE = { name = "LIGA POKÉMON" },
      UNDERGROUND_PATH = { name = "VÍA SUBTERRÁNEA" },
      POKEMON_TOWER = { name = "TORRE POKÉMON" },
      SEAFOAM_ISLANDS = { name = "ISLAS ESPUMA" },
      VICTORY_ROAD = { name = "CALLE VICTORIA" },
      DIGLETTS_CAVE = { name = "CUEVA DIGLETT" },
      ROCKET_HQ = { name = "GUARIDA ROCKET" },
      SILPH_CO = { name = "SILPH S.A." },
      POKEMON_MANSION = { name = "MANSIÓN POKÉMON" },
      SAFARI_ZONE = { name = "ZONA SAFARI" },
      CERULEAN_CAVE = { name = "CUEVA CELESTE" },
      POWER_PLANT = { name = "CENTRAL ENERGÍA" },
    }

    mod.content.field:patch("townMap", { locations = locations })
    mod.log:info("Español: Town Map locations translated")
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
