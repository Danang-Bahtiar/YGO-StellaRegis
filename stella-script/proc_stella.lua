StellaRegis = StellaRegis or {}

-- Filter for Level 4: Check for non-Machines
function StellaRegis.FourSummonFilter(c)
    return c:IsFaceup() and not c:IsRace(RACE_MACHINE)
end

-- Condition for Level 4
function StellaRegis.FourCondition(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and not Duel.IsExistingMatchingCard(StellaRegis.FourSummonFilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Filter for Level 8: Check for King Regulus or Stella-Regis Xyz
function StellaRegis.EightSummonFilter(c)
    return c:IsFaceup() and (c:IsCode(10604644) or (c:IsSetCard(0x1908) and c:IsType(TYPE_XYZ)))
end

-- Condition for Level 8
function StellaRegis.EightCondition(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(StellaRegis.EightSummonFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

-- Updated Procedure Adder
function StellaRegis.AddProcedure(c, id, level)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    
    if level == 4 then
        e1:SetRange(LOCATION_HAND)
        e1:SetCondition(StellaRegis.FourCondition)
    elseif level == 8 then
        e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
        e1:SetCondition(StellaRegis.EightCondition)
    end
    
    c:RegisterEffect(e1)
end

-- Level Lock
function StellaRegis.ApplyLevelLock(c,tp)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(c:GetCode(),5))
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,tc) return not (tc:IsLevel(4,8) or tc:IsRank(4,8)) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

-- Xyz Lock
function StellaRegis.ApplyXyzLock(c,tp)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(c:GetCode(),5))
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

-- c: The card
-- id: The card ID
-- grant_table: A table containing all effects the monster should gain
-- The Master Equip Procedure
function StellaRegis.AddEquipProcedure(c, id, grant_table)
    -- 1. The Ignition effect to move from GY to SZone
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,{id,2})
    e1:SetTarget(StellaRegis.EquipTarget)
    e1:SetOperation(StellaRegis.EquipOperation) -- Use the internal utility op
    c:RegisterEffect(e1)

    -- 2. The Universal Watcher (Grants the buffs)
    for _,eff in ipairs(grant_table) do
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
        e2:SetRange(LOCATION_SZONE)
        e2:SetTargetRange(LOCATION_MZONE,0)
        e2:SetTarget(StellaRegis.GrantTarget)
        e2:SetLabelObject(eff)
        c:RegisterEffect(e2)
    end
end

-- Internal: Handles the actual equipping and the Limit
function StellaRegis.EquipOperation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
        if Duel.Equip(tp,c,tc) then
            -- Set the Equip Limit automatically
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_EQUIP_LIMIT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(StellaRegis.EquipLimit)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e1)
        end
    end
end

-- The Limit Filter
function StellaRegis.EquipLimit(e,c)
    return c:IsSetCard(0x1908) or c:IsSetCard(0x17b)
end

-- Fixed GrantTarget: Checks if tc is the monster this card is currently equipping
function StellaRegis.GrantTarget(e,tc)
    return tc==e:GetHandler():GetEquipTarget()
end

-- Shared Equip Target
function StellaRegis.EquipTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and StellaRegis.EquipFilter(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(StellaRegis.EquipFilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,StellaRegis.EquipFilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function StellaRegis.EquipFilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x1908) or c:IsSetCard(0x17b))
end

-- SHARED EFFECTS
-- 1. Piercing (Strike Scout)
function StellaRegis.GrantPiercing(c)
    local e=Effect.CreateEffect(c)
    e:SetType(EFFECT_TYPE_SINGLE)
    e:SetCode(EFFECT_PIERCE)
    return e
end

-- 2. Cards in your GY cannot be banished by opponent's card effects
function StellaRegis.GrantGraveProtection(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_REMOVE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,1) -- Protect against the opponent
    e1:SetTarget(StellaRegis.GraveTarget)
    return e1
end

-- The Target Filter
function StellaRegis.GraveTarget(e,c,tp,r,re)
    -- e:GetHandlerPlayer() is YOU (the player who controls the monster)
    -- c:IsLocation(LOCATION_GRAVE) checks if the card being targeted is in the GY
    return c:IsLocation(LOCATION_GRAVE) and c:IsControler(e:GetHandlerPlayer())
end

-- 3. No Tribute / No Extra Deck Material (Crown)
function StellaRegis.GrantProtectionMaterial(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UNRELEASABLE_SUM)
    e1:SetValue(1)
    
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    
    local e3=e1:Clone()
    e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e3:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
    
    return e1, e2, e3
end

-- 4. Indestructible by Effects (Throne)
function StellaRegis.GrantProtectionEffect(c)
    local e=Effect.CreateEffect(c)
    e:SetType(EFFECT_TYPE_SINGLE)
    e:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e:SetValue(1)
    return e
end

-- 5. Second Attack (Courier)
function StellaRegis.GrantSecondAttack(c)
    local e=Effect.CreateEffect(c)
    e:SetType(EFFECT_TYPE_SINGLE)
    e:SetCode(EFFECT_EXTRA_ATTACK)
    e:SetValue(1)
    return e
end