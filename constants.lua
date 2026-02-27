-- SPDX-FileCopyrightText: 2026 barny
-- SPDX-License-Identifier: Artistic-2.0

local lib = LibAbilities or {}

lib._constants = { abilities = {}, strings = {}, events = {} }
local a = lib._constants.abilities
local str = lib._constants.strings
local e = lib._constants.events

------------------------------------------------------
-- CALLBACK ENUMS
------------------------------------------------------

local ABILITIES_CHANGED = 1
local SKILLLINES_CHANGED = 2
local SLOTTED_ABILITIES_CHANGED = 3
local WEAPON_ABILITIES_CHANGED = 4
	
e = {
	ABILITIES_CHANGED = ABILITIES_CHANGED,
	SKILLLINES_CHANGED = SKILLLINES_CHANGED,
	SLOTTED_ABILITIES_CHANGED = SLOTTED_ABILITES_CHANGED,
	WEAPON_ABILITIES_CHANGED = WEAPON_ABILITIES_CHANGED,
}

------------------------------------------------------
-- Internal constants
------------------------------------------------------

str.SKILL_TYPE_STRING = {
	[1] = "SKILL_TYPE_CLASS",
	[2] = "SKILL_TYPE_WEAPON",
	[3] = "SKILL_TYPE_ARMOR",
	[4] = "SKILL_TYPE_WORLD",
	[5] = "SKILL_TYPE_GUILD",
	[6] = "SKILL_TYPE_AVA",
	[7] = "SKILL_TYPE_RACIAL",
	[8] = "SKILL_TYPE_TRADESKILL",
	[9] = "SKILL_TYPE_CHAMPION",
}

str.CLASS = {
	[1] = "DK",
	[2] = "SORC",
	[3] = "NB",
	[4] = "WARDEN",
	[5] = "NECRO",
	[6] = "TEMPLAR",
	[117] = "ARCANIST",
}

str.TARGET_CONSTANTS = {
    ["ground"] = GetString(SI_ABILITY_TOOLTIP_TARGET_TYPE_GROUND),
    ["enemy"] = GetString(SI_TARGETTYPE0),
    ["ally"] = GetString(SI_TARGETTYPE1),
    ["self"] = GetString(SI_TARGETTYPE2)
}

a.MEND_WOUNDS = {
	[107579] = true,
	[107583] = true,
	[107629] = true,
	[107630] = true,
	[107636] = true,
	[107637] = true,
	[107638] = true,
	[114990] = true,
	[114991] = true,
	[114992] = true,
	[118617] = true,
	[118638] = true,
	[118645] = true
}
	
a.MEDITATE = {
	[103665] = true,
	[103492] = true,
	[103652] = true
}