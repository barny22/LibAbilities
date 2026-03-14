-- SPDX-FileCopyrightText: 2026 barny
-- SPDX-License-Identifier: Artistic-2.0

local lib = LibAbilities or {}

local function info(arg)
	return lib._loggers.log:Info(arg)
end

local function dbg(arg)
	return lib._loggers.log:Debug(arg)
end

local function warn(arg)
	return lib._loggers.log:Warn(arg)
end

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

function lib.RegisterCallback(eventName, callBackName, func)
	if not callbacks[eventName] then callbacks[eventName] = {} end
	if type(func) ~= "function" then
		warn(string.format("Need function to register callback! You tried to register a %s! No callback was registered", type(func)))
		return
	elseif not lib._constants.events[eventName] then
		warn("No such eventName found! No callback was registered")
		return
	end
	local callback = {callBackName = callBackName, func = func}
	table.insert(callbacks[eventName], callback)
	dbg(string.format("Callback successfully registered for %s by %s.", eventName, callBackName))
end