---------------------------------------------------------------------
-- Fix minimap position on wide screen displays
---------------------------------------------------------------------
local hasMinimapChanged = false

function UpdateMinimapLocation()
  Citizen.CreateThread(function()
    -- Get screen aspect ratio
    local ratio = GetScreenAspectRatio(true)

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
-- Toggle big map with "Z"
---------------------------------------------------------------------
RegisterCommand('bigmap', function()
  -- Get the current state of the bigmap.
  local bigmapActive = IsBigmapActive()

  -- Toggle the state of the bigmap.
  if bigmapActive then
    SetBigmapActive(false, false)
  else
    SetBigmapActive(true, false)
  end
end, false)

-- Add the key binding to the key map.
RegisterKeyMapping('bigmap', 'Toggle minimap size', 'keyboard', 'z')
TriggerEvent("chat:addSuggestion", "/bigmap", "Toggle minimap size")

---------------------------------------------------------------------
-- Zoom minimap with "G"
---------------------------------------------------------------------
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
---------------------------------------------------------------------
RegisterCommand('map', function()
  ActivateFrontendMenu("FE_MENU_VERSION_MP_PAUSE", false, -1)
  while not IsPauseMenuActive() or IsPauseMenuRestarting() do
      Wait(0)
  end
  PauseMenuceptionGoDeeper(0)
  PauseMenuceptionTheKick()
  while not IsControlJustPressed(2,202) and not IsControlJustPressed(2,200) and not IsControlJustPressed(2,199) do
      Wait(0)
  end
  PauseMenuceptionTheKick()
  SetFrontendActive(false)
end, false)

RegisterKeyMapping('map', 'Open Map', 'keyboard', 'M')
TriggerEvent("chat:addSuggestion", "/map", "Open Map of San Andreas")
-------------------------------------------------------------------------------
-- buh bye!
-------------------------------------------------------------------------------
