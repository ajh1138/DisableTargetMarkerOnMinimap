local ADDON = "DisableTargetMarkerOnMinimap"

-- Localized name of the "Target" tracking entry (Focus Target is a different entry).
local TARGET_NAMES = { ["Target"] = true }
if TRACKING_TARGET then TARGET_NAMES[TRACKING_TARGET] = true end

local function GetInfo(i)
    if C_Minimap and C_Minimap.GetTrackingInfo then
        local info = C_Minimap.GetTrackingInfo(i)
        if type(info) == "table" then
            return info.name, info.active
        end
        -- legacy multi-return shape: name, texture, active, ...
        local name, _, active = C_Minimap.GetTrackingInfo(i)
        return name, active
    end
    local name, _, active = GetTrackingInfo(i)
    return name, active
end

local function SetTrack(i, enabled)
    if C_Minimap and C_Minimap.SetTracking then
        C_Minimap.SetTracking(i, enabled)
    else
        SetTracking(i, enabled)
    end
end

local function NumTypes()
    if C_Minimap and C_Minimap.GetNumTrackingTypes then
        return C_Minimap.GetNumTrackingTypes()
    end
    return GetNumTrackingTypes()
end

local function DisableTarget()
    for i = 1, NumTypes() do
        local name, active = GetInfo(i)
        if name and TARGET_NAMES[name] then
            if active then SetTrack(i, false) end
            DTMOMDB.done = true
            return true
        end
    end
    return false
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self)
    DTMOMDB = DTMOMDB or {}
    self:UnregisterAllEvents()
    if DTMOMDB.done then return end
    C_Timer.After(2, DisableTarget)
end)

SLASH_DTMOM1 = "/dtmom"
SlashCmdList.DTMOM = function(msg)
    DTMOMDB = DTMOMDB or {}
    if (msg or ""):lower() == "reset" then
        DTMOMDB.done = nil
        print("|cff33ff99" .. ADDON .. "|r: reset; Target will be unchecked at next login.")
    else
        print("|cff33ff99" .. ADDON .. "|r: /dtmom reset - re-run the one-time uncheck at next login.")
    end
end
