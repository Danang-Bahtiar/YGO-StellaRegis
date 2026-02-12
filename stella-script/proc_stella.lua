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