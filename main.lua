-- SPDX-FileCopyrightText: 2026 barny
-- SPDX-License-Identifier: Artistic-2.0

local LIB_NAME = "LibAbilities"
local LIB_VERSION = 1

-- Version protection
local existing = _G[LIB_NAME]
if existing and existing.version and existing.version >= LIB_VERSION then
    return
end

local lib = existing or {}
lib.name = LIB_NAME
lib.version = LIB_VERSION

_G[LIB_NAME] = lib

local u = lib._util

------------------------------------------------------
-- Internal state (private)
------------------------------------------------------

lib._state = {
	initialized = false,
	cache = { skillLines = {}, abilities = {}, actionSlots = {}, weaponAbilities = {} },
	callbacks = {},
}

------------------------------------------------------
-- Core scan logic
------------------------------------------------------

function lib:_BuildCache()
	local time = GetFrameTimeMilliseconds()
	
	local prev = lib._state.cache
	
	local skillLines = u.GetSkillLineData(prev.skillLines)
	local abilities = u.GetAbilityData(prev.abilities, skillLines.skillLineIds)
	local actionSlots = u.GetSlottedAbilities(abilities.availableAbilities)
	local weaponAbilities = u.GetWeaponAbilities(prev.weaponAbilities)
	
    local c = {
		skillLines = skillLines,
		abilities = abilities,
		actionSlots = actionSlots,
		weaponAbilities = weaponAbilities,
    }
	
	u.FireCallbacks(prev, c)

    lib._state.cache = c
	d(zo_strformat("Building cache took <<1>>ms", GetFrameTimeMilliseconds()-time))
end

------------------------------------------------------
-- Initialization
------------------------------------------------------

function lib:_Initialize()
    if self._state.initialized then return end
    self._state.initialized = true

    self:_BuildCache()
	
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SKILL_RESPEC_RESULT, function() -- triggers after a respec or when changing abilities on hotbars
        self:_BuildCache()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function() -- triggers after using the armory
        -- callLater needed, since the abilities are only updated after the event fired
		zo_callLater(function() self:_BuildCache() end, 10)
    end)
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_HOTBAR_SLOT_UPDATED, function(_,slot,_,_)
		-- using this to update light and heavy attack abilities when changing weapons
		if slot == 2 then
			local weaponAbilities = self._state.cache.abilities.weaponAbilities or {}
			u.GetWeaponAbilities(weaponAbilities)
		end
    end)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= LIB_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(LIB_NAME, EVENT_ADD_ON_LOADED)
    lib:_Initialize()
end

EVENT_MANAGER:RegisterForEvent(LIB_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)