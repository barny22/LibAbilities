-- SPDX-FileCopyrightText: 2026 barny
-- SPDX-License-Identifier: Artistic-2.0

local lib = LibAbilities or {}

local function GetCache()
	return lib._state.cache
end
local function GetCallbacks()
	return lib._state.callbacks
end

local cache = GetCache()
local callbacks = GetCallbacks()
local sl = cache.skillLines
local a = cache.abilities
local sa = cache.actionSlots
local wa = cache.weaponAbilities

--------------------
---- Public API ----
--------------------

function lib.GetAllData()
	return cache
end

function lib.GetSkillLineData()
	return sl
end

function lib.GetAbilityData()
	return a
end

function lib.GetSlottedAbilities()
	return sa
end

function lib.GetWeaponAbilities()
	return wa
end

function lib.GetAvailableSkillLines()
	return sl.skillLineIds
end

function lib.GetAvailableSkillLineNames()
	return sl.skillLineNames
end

function lib.GetAvailableClassSkillLines()
	return sl.classSkillLineIds
end

function lib.GetCurrentSkillLineClassIds()
	return sl.activeSkillLineClassIds
end

function lib.GetCurrentSkillLineClasses()
	return sl.activeSkillLineClasses
end

function lib.GetAvailableAbilities()
	return a.availableAbilities
end

function lib.GetAvailableActiveAbilities()
	return a.availableActiveAbilities
end

function lib.GetAvailablePassives()
	return a.availablePassives
end

function lib.GetAvailableUltimates()
	return a.availableUltimates
end

function lib.IsSkillLineAvailable(skillLineId)
	return sl.skillLineIds[skillLineId] and true or false
end

function lib.IsAbilityAvailable(abilityId)
	return a.availableAbilities[abilityId] and true or false
end

function lib.IsPlayerSubclassing()
	return not sl.isPureClass
end

function lib.IsAbilitySlotted(abilityId)
	return sa.list[abilityId] and true or false
end

------------------------------
-- CALLBACKS
------------------------------

function lib.RegisterCallback(eventName, func)
	if not callbacks[eventName] then callbacks[eventName] = {} end
	table.insert(callbacks[eventName], func)
end