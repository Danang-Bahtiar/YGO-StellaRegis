StellaRegis = StellaRegis or {}

-- Filter for the summon condition
function StellaRegis.FourSummonFilter(c)
    return c:IsFaceup() and not c:IsRace(RACE_MACHINE)
end

-- The condition check
function StellaRegis.FourCondition(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and not Duel.IsExistingMatchingCard(StellaRegis.FourSummonFilter,tp,LOCATION_MZONE,0,1,nil)
end

-- The actual Procedure Adder
-- We add 'id' as a parameter here!
function StellaRegis.AddProcedure(c, id)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0)) -- Now it knows which card's string to use
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- Now it knows which ID to lock
    e1:SetCondition(StellaRegis.FourCondition)
    c:RegisterEffect(e1)
end
