-- SPDX-FileCopyrightText: 2026 barny
-- SPDX-License-Identifier: Artistic-2.0

local LIB_NAME = "LibAbilities"
local LIB_VERSION = 1

local lib = LibAbilities or {}
lib.name = LIB_NAME
lib.version = LIB_VERSION

_G[LIB_NAME] = lib

------------------------------------------------------
-- Internal state (private)
------------------------------------------------------

lib._state = {
	initialized = false,
	cache = { skillLines = {}, abilities = {}, actionSlots = {}, weaponAbilities = {} },
	weaponSwap = 0,
	lastCache = { complete = 0, weaponAbilities = 0 },
	callbacks = {},
}

------------------------------------------------------
-- Initialization
------------------------------------------------------

function lib:_CreateLoggers()
	self._loggers = {}
	self._loggers.log = LibDebugLogger("LibAbilities")
	self._loggers.slLog = self._loggers.log:Create("SkillLines")
	self._loggers.aLog = self._loggers.log:Create("Abilities")
	self._loggers.asLog = self._loggers.log:Create("ActionSlots")
end

function lib:_Initialize()
    if self._state.initialized then return end
    self._state.initialized = true
	
	self:_CreateLoggers()

    self:_BuildCache()
	
	self:_RegisterEvents()
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= LIB_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(LIB_NAME, EVENT_ADD_ON_LOADED)
    lib:_Initialize()
end

EVENT_MANAGER:RegisterForEvent(LIB_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)