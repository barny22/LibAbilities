-- SPDX-FileCopyrightText: 2026 barny
-- SPDX-License-Identifier: Artistic-2.0

local LIB_NAME = "LibAbilities"

-- Version protection
local existing = _G[LIB_NAME]
if existing and existing.version and existing.version >= LIB_VERSION then
    return
end

local lib = existing or {}
_G[LIB_NAME] = lib

lib._util = {}
local u = lib._util
local a = lib._constants.abilities
local str = lib._constants.strings

------------------------------------------------------
-- Internal utility
------------------------------------------------------

local GetAbilityBuffType = GetAbilityBuffType
local GetAbilityCastInfo = GetAbilityCastInfo
local GetAbilityDuration = GetAbilityDuration
local GetAbilityIcon = GetAbilityIcon
local GetAbilityIdForCraftedAbilityId = GetAbilityIdForCraftedAbilityId
local GetAbilityName = GetAbilityName
local GetAbilityProgressionAbilityId = GetAbilityProgressionAbilityId
local GetAbilityProgressionInfo = GetAbilityProgressionInfo
local GetAbilityProgressionXPInfoFromAbilityId = GetAbilityProgressionXPInfoFromAbilityId
local GetAbilityRoles = GetAbilityRoles
local GetAbilityTargetDescription = GetAbilityTargetDescription
local GetNumSkillAbilities = GetNumSkillAbilities
local GetNumSkillTypes = GetNumSkillTypes
local GetNumSkillLines = GetNumSkillLines
local GetSkillLineDynamicInfo = GetSkillLineDynamicInfo
local GetSkillLineId = GetSkillLineId
local GetSkillLineNameById = GetSkillLineNameById
local GetSkillAbilityInfo = GetSkillAbilityInfo
local GetSkillAbilityId = GetSkillAbilityId

local function CacheAbility(id)

	local o = { }
	
    o.id = id
    o.name = zo_strformat(SI_ABILITY_NAME, GetAbilityName(id))
    local channeled, duration = GetAbilityCastInfo(id)
    o.channeled = channeled
    if channeled then
        o.channelTime = duration
        o.castTime = 0
    else
        o.castTime = duration
        o.channelTime = 0
    end
	
    o.delay = duration or 0
    o.instant = not (o.castTime > 0 or (o.channeled and o.channelTime > 0))
    o.casted = not (o.instant or o.channeled)
    o.target = GetAbilityTargetDescription(id)
	o.icon = GetAbilityIcon(id)

    o.duration = GetAbilityDuration(id)
    o.buffType = GetAbilityBuffType(id)
    o.isTankAbility, 
    o.isHealerAbility, 
    o.isDamageAbility = GetAbilityRoles(id)
	
	o.isUltimate = IsAbilityUltimate(id)

    o.ground = o.target == str.TARGET_CONSTANTS.ground
    o.enemy = o.target == str.TARGET_CONSTANTS.enemy
    o.ally = o.target == str.TARGET_CONSTANTS.ally
    
    o.isMendWounds = a.MEND_WOUNDS[id] or false
    o.isMeditate = a.MEDITATE[id] or false
    if o.isMeditate then o.delay = 1000 end
    
    o.checkForDeadTarget = ((o.enemy or o.ally) and duration > 1000) or (o.isMendWounds)

    o.hasProgression,
    o.progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(id)

    if o.hasProgression then
        o.baseName,
        o.morph,
        o.rank = GetAbilityProgressionInfo(o.progressionIndex)

        o.baseId = GetAbilityProgressionAbilityId(o.progressionIndex, 0, 1)
    end

    return o
end

function u.CacheAbility(id)
	return CacheAbility(id)
end

local function GetSkillLineData(prevSL)
	local sl = {
		skillLineIds = {},
		skillLineNames = {},
		classSkillLineIds = {},
		activeSkillLineClassIds = {},
		activeSkillLineClasses = {},
		isPureClass = false,
	}
	
    for skillType = 1, GetNumSkillTypes() do
		local skillTypeString = str.SKILL_TYPE_STRING[skillType]
		
        for skillLineIndex = 1, GetNumSkillLines(skillType) do
            local _, _, isActive = GetSkillLineDynamicInfo(skillType, skillLineIndex)
			local classId
			local isClassSkillLine = false
            if isActive then
                local skillLineId = GetSkillLineId(skillType, skillLineIndex)

                local name = prevSL.skillLineNames and prevSL.skillLineNames[skillLineId] or zo_strformat(SI_SKILL_LINE_TOOLTIP_NAME, GetSkillLineNameById(skillLineId))
                
				if skillType == SKILL_TYPE_CLASS then
					isClassSkillLine = true
                    classId = GetSkillLineClassId(skillType, skillLineIndex)
					if not sl.activeSkillLineClassIds[classId] then
						sl.activeSkillLineClassIds[classId] = {}
						sl.activeSkillLineClasses[str.CLASS[classId]] = {}
					end
					sl.activeSkillLineClasses[str.CLASS[classId]][skillLineId] = true
					sl.activeSkillLineClassIds[classId][skillLineId] = true
                    sl.classSkillLineIds[skillLineId] = str.CLASS[classId]
                end
				
                sl.skillLineNames[skillLineId] = name
                sl.skillLineIds[skillLineId] = 	prevSL.skillLineIds and prevSL.skillLineIds[skillLineId] or 
												{ name = name, isClassSkillLine = isClassSkillLine, classId = classId, classString = str.CLASS[classId], skillLineIndex = skillLineIndex, skillType = skillType, skillTypeString = skillTypeString }
            end
        end
    end

    if NonContiguousCount(sl.activeSkillLineClassIds) == 1 then
        sl.isPureClass = true
    end
	
	return sl
end

function u.GetSkillLineData(prevSL)
	return GetSkillLineData(prevSL)
end

local function GetAbilityData(prevA, skillLineIds)
	local a = {
		availableActiveAbilities = {},
		availablePassives = {},
		availableUltimates = {},
		availableAbilities = {},
	}
	
	for id, sl in pairs(skillLineIds) do
		local skillType, skillLineIndex, isClassSkillLine, classId, classString, skillTypeString = sl.skillType, sl.skillLineIndex, sl.isClassSkillLine, sl.classId, sl.classString, sl.skillTypeString
		
		for j = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
			local aName, _, _, _, _, purchased = GetSkillAbilityInfo(skillType, skillLineIndex, j)

			if purchased then
				local abilityId = GetSkillAbilityId(skillType, skillLineIndex, j, false)
				
				aName = prevA.availableAbilities and prevA.availableAbilities[abilityId] and prevA.availableAbilities[abilityId].name or zo_strformat(SI_ABILITY_NAME, aName)
				
				local ability = prevA.availableAbilities and prevA.availableAbilities[abilityId] or {}

				if IsAbilityPassive(abilityId) then
					if not next(ability) then
						ability = { name = aName }
						
						if isClassSkillLine then
							ability.classId = classId
							ability.class = classString
						end
					end
					
					a.availablePassives[abilityId] = ability
					a.availableAbilities[abilityId] = ability
					a.availableAbilities[abilityId].isPassive = true
					a.availableAbilities[abilityId].skillLineId = id
					a.availableAbilities[abilityId].skillLineIndex = skillLineIndex
					a.availableAbilities[abilityId].skillType = skillTypeString
				else
					if not next(ability) then
						ability = CacheAbility(abilityId)
						
						if isClassSkillLine then
							ability.classId = classId
							ability.class = classString
						end
					end
					
					a.availableActiveAbilities[abilityId] = ability
					a.availableActiveAbilities[abilityId].skillLineId = id
					a.availableActiveAbilities[abilityId].skillType = skillTypeString
					a.availableActiveAbilities[abilityId].skillLineIndex = skillLineIndex
					a.availableAbilities[abilityId] = ability
					a.availableAbilities[abilityId].skillLineId = id
					a.availableAbilities[abilityId].skillLineIndex = skillLineIndex
					a.availableAbilities[abilityId].skillType = skillTypeString
					if ability.isUltimate then a.availableUltimates[abilityId] = ability end
				end
				
				if not sl.abilities then sl.abilities = {} end
				
				sl.abilities[abilityId] = ability
			end
		end
	end
	
	return a
end

function u.GetAbilityData(prevA, skillLineIds)
	return GetAbilityData(prevA, skillLineIds)
end

local function GetSlottedAbilities(abilities)
	local actionSlots = { frontbar = {}, backbar = {} }  -- Create a table to store action slots

    for bar = 0, 1 do
        for slot = 3, 8 do
			local slotType = GetSlotType(slot, bar)
			local slotId = GetSlotBoundId(slot, bar)
			local id = slotType == ACTION_TYPE_CRAFTED_ABILITY and GetAbilityIdForCraftedAbilityId(slotId) or slotId
			local actualSlot = slot - 2
			if id ~= 0 then
				local ability = abilities[id] or CacheAbility(id)
				if bar == 0 then
					actionSlots.frontbar[actualSlot] = ability
				else
					actionSlots.backbar[actualSlot] = ability
				end
			end
        end
    end

    return actionSlots
end

function u.GetSlottedAbilities(abilities)
	return GetSlottedAbilities(abilities)
end

local function GetWeaponAbilities(prev)
	local wa = {}
	
	for bar = 0, 1 do
		for slot = 1, 2 do
			local slotId = GetSlotBoundId(slot, bar)
			if slotId ~= 0 and not wa[slotId] then
				local ability = prev[slotId] or CacheAbility(slotId)
				if slot == 1 then
					ability.light = true
				elseif slot == 2 then
					ability.heavy = true
				end
				wa[slotId] = ability
			end
		end
	end
	
	return wa
end

function u.GetWeaponAbilities(prev)
	return GetWeaponAbilities(prev)
end

local function DidSkillLinesChange(prev, new)
    if not next(prev) or not prev.skillLineIds then
        return true
    end

    local prevSL = prev.skillLineIds
    local newSL  = new.skillLineIds

    if NonContiguousCount(prevSL) ~= NonContiguousCount(newSL) then
        return true
    end

    for skillLineId in pairs(prevSL) do
        if not newSL[skillLineId] then
            return true
        end
    end
	
    for skillLineId in pairs(newSL) do
        if not prevSL[skillLineId] then
            return true
        end
    end

    return false
end

function u.DidSkillLinesChange(prev, new)
	return DidSkillLinesChange(prev, new)
end

local function DidAbilitiesChange(prev, new)
    if not next(prev) or not prev.availableAbilities then
        return true
    end

    local prevA = prev.availableAbilities
    local newA  = new.availableAbilities

    if (NonContiguousCount(prevA) ~= NonContiguousCount(newA)) then
        return true
    end

    for abilityId in pairs(prevA) do
        if not newA[abilityId] then
            return true
        end
    end

    for abilityId in pairs(newA) do
        if not prevA[abilityId] then
            return true
        end
    end

    return false
end

function u.DidAbilitiesChange(prev, new)
	return DidAbilitiesChange(prev, new)
end

local function DidSlottedAbilitiesChange(prev, new)
	if not next(prev) or not prev.frontbar then
		return true
	end
	
	local prevF, prevB = prev.frontbar, prev.backbar
	local newF, newB = new.frontbar, new.backbar
	
	for slot, ability in pairs(prevF) do
		if not newF[slot] or (newF[slot] and newF[slot].id ~= ability.id) then
			return true
		end
	end
	
	for slot, ability in pairs(prevB) do
		if not newB[slot] or (newB[slot] and newB[slot].id ~= ability.id) then
			return true
		end
	end
	
	for slot, ability in pairs(newF) do
		if not prevF[slot] or (prevF[slot] and prevF[slot].id ~= ability.id) then
			return true
		end
	end
	
	for slot, ability in pairs(newB) do
		if not prevB[slot] or (prevB[slot] and prevB[slot].id ~= ability.id) then
			return true
		end
	end
	
	return false
end

function u.DidSlottedAbilitiesChange(prev, new)
	return DidSlottedAbilitiesChange(prev, new)
end

-- local function FireCallbacks(eventName)
    -- local list = lib._state.callbacks[eventName]
    -- if not list then return end
	
    -- for i = 1, #list do
        -- list[i](lib._state.cache)
    -- end
-- end

local function FireCallbacks(prev, cache)
	if DidSkillLinesChange(prev.skillLines, cache.skillLines) then
		-- FireCallbacks(SKILLLINES_CHANGED)
		d("SkillLines changed")
	end
	if DidAbilitiesChange(prev.abilities, cache.abilities) then
		-- FireCallbacks(ABILITIES_CHANGED)
		d("Abilities changed")
	end
	if DidSlottedAbilitiesChange(prev.actionSlots, cache.actionSlots) then
		-- FireCallbacks(SLOTTED_ABILITIES_CHANGED)
		d("Slotted abilities changed")
	end
end

function u.FireCallbacks(prev, cache)
	return FireCallbacks(prev, cache)
end