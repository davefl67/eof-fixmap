local hasMinimapChanged = false

function UpdateMinimapLocation()
  Citizen.CreateThread(function()
    -- Get screen aspect ratio
    local ratio = GetScreenAspectRatio()

    -- Default values for 16:9 monitors
    local posX = -0.0045
    local posY = 0.002

    if tonumber(string.format("%.2f", ratio)) >= 2.3 then
      -- Ultra wide 3440 x 1440 (2.39)
      -- Ultra wide 5120 x 2160 (2.37)
      posX = -0.185
      posY = 0.002
      print('Detected ultra-wide monitor, adjusted minimap')
    else 
      posX = -0.0045
      posY = 0.002
    end

    SetMinimapComponentPosition('minimap', 'L', 'B', posX, posY, 0.150, 0.188888)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', posX + 0.0155, posY + 0.03, 0.111, 0.159)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', posX - 0.0255, posY + 0.02, 0.266, 0.237)

    DisplayRadar(false)
    SetRadarBigmapEnabled(true, false)
    Citizen.Wait(0)
    SetRadarBigmapEnabled(false, false)
    DisplayRadar(true)
  end)
end

RegisterCommand('reload-map', function(src, args)
  UpdateMinimapLocation()
end, false)

UpdateMinimapLocation()

TriggerEvent("chat:addSuggestion", "/reload-map", "Update the minimap's screen location")

---------------------------------------------------------------------
-- Register a key binding for the z key.
RegisterCommand('bigmap', function()
  -- Get the current state of the bigmap.
  local bigmapActive = IsBigmapActive()

  -- Toggle the state of the bigmap.
  if bigmapActive then
    SetBigmapActive(false, false)
  else
    SetBigmapActive(true, true)
  end
end)

-- Add the key binding to the key map.
RegisterKeyMapping('bigmap', 'Toggle minimap size', 'keyboard', 'z')
TriggerEvent("chat:addSuggestion", "/bigmap", "Toggle minimap size")

---------------------------------------------------------------------
-- Zoom minimap with "G"
local zoomed = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if zoomed then
            SetRadarZoomToDistance(500.0)
        end
    end
end)
RegisterCommand("+zoom", function()
    zoomed = true
end, false)
RegisterCommand("-zoom", function()
    zoomed = false
end, false)
RegisterKeyMapping("+zoom", "zoom on minmap", "keyboard", "g")

---------------------------------------------------------------------
-- Use "M" to go straight to the map

RegisterCommand('map', function(source, args)
  ActivateFrontendMenu("FE_MENU_VERSION_MP_PAUSE", false, -1) --Opens a frontend-type menu. Scaleform is already loaded, but can be changed.
  while not IsPauseMenuActive() or IsPauseMenuRestarting() do --Making extra-sure that the frontend menu is fully loaded
      Wait(0)
  end
  PauseMenuceptionGoDeeper(0) --Setting up the context menu of the Pause Menu. For other frontend menus, use https://docs.fivem.net/natives/?_0xDD564BDD0472C936
  PauseMenuceptionTheKick()
  while not IsControlJustPressed(2,202) and not IsControlJustPressed(2,200) and not IsControlJustPressed(2,199) do --Waiting for any of frontend cancel buttons to be hit. Kinda slow but whatever.
      Wait(0)
  end
  PauseMenuceptionTheKick() --doesn't really work, but the native's name is funny.
  SetFrontendActive(false) --Force-closing the entire frontend menu. I wanted a simple back button, but R* forced my hand.
end)

RegisterKeyMapping('map', 'Open Map', 'keyboard', Config.OpenKey)
TriggerEvent("chat:addSuggestion", "/map", "Open Map of San Andreas")
-------------------------------------------------------------------------------
