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

--------------------------------------------------------------------------------------
-- Generally abilities are being scanned for these values and stored in a table:	--
-- ability = {	id number,															--
--				name string,														--
--				classId nilable number,												--
--				class nilable string,												--
--				channeled nilable boolean,											--
--				channelTime nilable number,											--
--				castTime nilable number,											--
--				delay nilable number,												--
--				instant nilable boolean,											--
--				casted nilable boolean,												--
--				target nilable string,												--
--				ground nilable boolean,												--
--				enemy nilable boolean,												--
--				ally nilable boolean,												--
--				icon nilable string,												--
--				duration nilable number,											--
--				buffType nilable string,											--
--				isTankAbility nilable boolean,										--
--				isHealerAbility nilable boolean,									--
--				isDamageAbility nilable boolean,									--
--				isUltimate nilable boolean,											--
--				isPassive nilable boolean,											--
--				isMendWounds nilable boolean,										--
--				isMeditate nilable boolean,											--
--				checkForDeadTarget nilable boolean,									--
--				hasProgression nilable boolean,										--
--				progressionIndex nilable number,									--
--				hasProgression nilable boolean,										--
--				baseName nilable string,											--
--				morph nilable number,												--
--				rank nilable number,												--
--				baseId nilable number,												--
--				abilityIndex number,												--
--				skillIndex number,													--
--				skillLineId number,													--
--				skillLineIndex number,												--
--				skillType string,													--
--				light boolean														--
--				heavy boolean														--
--------------------------------------------------------------------------------------


--Returns a table of all gathered data with additional indices such as skillLineId, classId, classString, abilityId and slot
--
--> Returns:    table: {	skillLines table = {	skillLineIds table = { skillLineId number = table {	name string,
--																										isClassSkillLine boolean,
--																										classId number,
--																										classString string,
--																										skillLineIndex number,
--																										skillType number,
--																										skillTypeString string,
--																										abilities table = { abilityId number = ability table, }, }, },
--													skillLineNames table = { skillLineId number = name string, },
--													classSkillLineIds table = { skillLineId number = classString string, },
--													activeSkillLineClassIds table = { classId number = table {skillLineId = true, }, },
--													activeSkillLineClasses table = { classString string = table {skillLineId = true, }, },
--													isPureClass boolean},
--							abilities table = {		availableActiveAbilities table = { abilityId number = ability table, },
--													availablePassives table = { abilityId number = ability table, },
--													availableUltimates table = { abilityId number = ability table, },
--													availableAbilities table = { abilityId number = ability table, }, },
--							actionSlots table = {	frontbar table  = { slot number = ability table, },
--													backbar table = { slot number = ability table, },
--													list table = { abilityId number = ability1 table }, },
--							weaponAbilities table = { abilityId number = ability table, }
--						}
function lib.GetAllData()
	return cache
end

--Returns the skillLines table with additional idices such as skillLineId, classId and classString
--
--> Returns:	skillLines table = {	skillLineIds table = { skillLineId number = table {	name string,
--																							isClassSkillLine boolean,
--																							classId number,
--																							classString string,
--																							skillLineIndex number,
--																							skillType number,
--																							skillTypeString string,
--																							abilities table = { abilityId number = ability table, }, }, },
--										skillLineNames table = { skillLineId number = name string, },
--										classSkillLineIds table = { skillLineId number = classString string, },
--										activeSkillLineClassIds table = { classId number = table {skillLineId = true, }, },
--										activeSkillLineClasses table = { classString string = table {skillLineId = true, }, },
--										isPureClass boolean},
function lib.GetSkillLineData()
	return sl
end

--Returns the abilities table with an abilityId index
--
--> Returns:	abilities table = {		availableActiveAbilities table = { abilityId number = ability table, },
--										availablePassives table = { abilityId number = ability table, },
--										availableUltimates table = { abilityId number = ability table, },
--										availableAbilities table = { abilityId number = ability table, }, },
function lib.GetAbilityData()
	return a
end

--Returns the slottedAbilities table with a slot index
--
--> Returns:	actionSlots table = {	frontbar table  = { slot number = ability table, },
--										backbar table = { slot number = ability table, },
--										list table = { abilityId number = ability1 table }, },
function lib.GetSlottedAbilities()
	return sa
end

--Returns the weaponAbilities table with an abilityId index
--
--> Returns:	weaponAbilities table = { abilityId number = ability table, }
--since you always have light and heavy abilities the table contains either 2 entries (before lvl 15, when weaponswap is not available yet) or 4 entries (two for each bar)
function lib.GetWeaponAbilities()
	return wa
end

--Returns a table containing all available skillLineIds with a skillLineId index
--
--> Returns:	skillLineIds table = { skillLineId number = table {	name string,
--																	isClassSkillLine boolean,
--																	classId number,
--																	classString string,
--																	skillLineIndex number,
--																	skillType number,
--																	skillTypeString string,
--																	abilities table = { abilityId number = ability table, }, }, },
function lib.GetAvailableSkillLines()
	return sl.skillLineIds
end

--Returns a table containing all available skillLineNames with a skillLineId index
--
--> Returns:	skillLineNames table = { skillLineId number = name string, },
function lib.GetAvailableSkillLineNames()
	return sl.skillLineNames
end

--Returns a table containing all active classStrings using their class skillLineIds as index
--
--> Returns:	classSkillLineIds table = { skillLineId number = classString string, },
function lib.GetAvailableClassSkillLines()
	return sl.classSkillLineIds
end

--Returns a table containing all active class skillLineIds using their classId as index
--
--> Returns:	activeSkillLineClassIds table = { classId number = table {skillLineId = true, }, },
function lib.GetCurrentSkillLineClassIds()
	return sl.activeSkillLineClassIds
end

--Returns a table containing all active class specific skillLineIds using their classString as index
--
--> Returns:	activeSkillLineClasses table = { classString string = table {skillLineId = true, }, },
function lib.GetCurrentSkillLineClasses()
	return sl.activeSkillLineClasses
end

--Returns a table containing all available abilities using their abilityId as index
--
--> Returns:	availableAbilities table = { abilityId number = ability table, }, },
function lib.GetAvailableAbilities()
	return a.availableAbilities
end

--Returns a table containing all available active abilities using their abilityId as index
--
--> Returns:	availableActiveAbilities table = { abilityId number = ability table, },
function lib.GetAvailableActiveAbilities()
	return a.availableActiveAbilities
end

--Returns a table containing all available passive abilities using their abilityId as index
--
--> Returns:	availablePassives table = { abilityId number = ability table, },
function lib.GetAvailablePassives()
	return a.availablePassives
end

--Returns a table containing all available ultimate abilities using their abilityId as index
--
--> Returns:	availableUltimates table = { abilityId number = ability table, },
function lib.GetAvailableUltimates()
	return a.availableUltimates
end

--Returns true/false if the skillLineId is currently selected
--> Parameters: skillLineId number: The skillLine's skillLineId
--> Returns:    isAvailable boolean
function lib.IsSkillLineAvailable(skillLineId)
	return sl.skillLineIds[skillLineId] and true or false
end

--Returns true/false if the ability is available
--> Parameters: abilityId number: The ability's abilityId
--> Returns:    isAvailable boolean
function lib.IsAbilityAvailable(abilityId)
	return a.availableAbilities[abilityId] and true or false
end

--Returns true/false if the player is using a subclassing build
--> Returns:    isSubclassing boolean
function lib.IsPlayerSubclassing()
	return not sl.isPureClass
end

--Returns true/false if the ability is currently slotted on either hotbar
--> Parameters: abilityId number: The ability's abilityId
--> Returns:    isSlotted boolean
function lib.IsAbilitySlotted(abilityId)
	return sa.list[abilityId] and true or false
end

------------------------------
-- CALLBACKS
------------------------------

--Logger functions to get feedback via LibDebugLogger
local function info(arg)
	return lib._loggers.log:Info(arg)
end

local function dbg(arg)
	return lib._loggers.log:Debug(arg)
end

local function warn(arg)
	return lib._loggers.log:Warn(arg)
end

--Callbacks are executed when the corresponding events happen and only if a change has been registered
-- available eventNames are:
-- "Skillline_Available" -- SKILLLINES_CHANGED
-- "Ability_Available" -- AVAILABLE_ABILITIES_CHANGED
-- "Ability_Slotted" -- ABILITIES_SLOTTED_CHANGED
-- "Actively_Slotted" -- ACTIVELY_SLOTTED_ABILITES_CHANGED
--
-- Parameters:	callbackName string: your chosen identifier string
--				func function: your chosen function to be executed
--				id number: the skillLineId/abilityId to check for
-- Executes func(eventName, isAvailable/isSlotted boolean)

function lib.RegisterCallback(eventName, callbackName, func, id)
	if not callbacks[eventName] then callbacks[eventName] = {} end
	if type(id) ~= "number" or type(callbackName) ~= "string" or type(func) ~= "function" then
		if type(id) ~= "number" then warn(string.format("Need 'id' to be a number to register callback! 'id' was a '%s'. No callback was registered!", type(id))) end
		if type(callbackName) ~= "string" then warn(string.format("Need 'callbackName' to be a string to register callback! 'callbackName' was a '%s'. No callback was registered!", type(callbackName))) end
		if type(func) ~= "function" then warn(string.format("Need 'func' to be a function to register callback! 'func' was a '%s'. No callback was registered!", type(func))) end
		return false
	elseif not lib._constants.events[eventName] then
		warn(string.format("No such eventName found! No callback was registered under '%s'", callbackName))
		return false
	end
	local callback = {callbackName = callbackName, id = id, func = func}
	table.insert(callbacks[eventName], callback)
	dbg(string.format("Callback successfully registered for '%s' under '%s'.", eventName, callbackName))
	return true
end