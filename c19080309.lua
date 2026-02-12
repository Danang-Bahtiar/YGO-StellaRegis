-- Stella-Regis "Sovereign" Regulus
-- Xyz Monster
-- Rank 8 Light Machine-Type / Effect Monster
-- ATK 3500 / DEF 3000
-- 3 or more Level 8 monsters
-- Must first be Xyz Summoned, or Special Summoned by using 1 "Therion 'King' Regulus" you control as material. You can only Special Summon "Stella-Regis "Sovereign" Regulus" once per turn. You can only control 1 "Stella-Regis "Sovereign" Regulus" on field.
-- If this card has "Therion "King" Regulus" as material, This card is unaffected by your opponent's card effects.
-- (Quick Effect): You can detach 1 material from this card OR send 1 Equip Card equipped to this card to the GY; Declare 1 type of card (Spell, Trap, or Monster) and activate 1 of these effects. If you detached 2 materials to activate this effect while this card had "Therion "King" Regulus" as material, you can declare 2 type instead.
-- ● Your opponent cannot add the declared type(s) from Graveyard or Deck to their hand until your next Standby Phase.
-- ● Your opponent cannot activate the declared type(s) effects in their GY until your next Standby Phase.
-- ● Your "Stella-Regis" and "Therion" cards are unaffected by effects of the declared type(s) activated by your opponent until your next Standby Phase.
-- You can only use the effect of "Stella-Regis 'Sovereign' Regulus" once per turn, and cannot activate it during the next turn.

local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Procedure: 3+ Level 8 monsters
    Xyz.AddProcedure(c,nil,8,3,nil,nil,Xyz.InfiniteMats)
    c:EnableReviveLimit()
    
    -- Special Summon via Regulus
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.altcon)
    e0:SetTarget(s.alttg)
    e0:SetOperation(s.altop)
    c:RegisterEffect(e0)

    -- Unique Control/Summon Limits
    c:SetSPSummonOnce(id)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetCondition(s.immcon)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)

    -- Decree Effect (Quick Effect)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.effcon)
    e2:SetCost(s.effcost)
    e2:SetTarget(s.efftg)
    e2:SetOperation(s.effop)
    c:RegisterEffect(e2)
end

s.listed_names={10604644} -- Therion "King" Regulus

-- Unaffected Condition (If has Regulus as material)
function s.immcon(e)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,10604644)
end
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- Alternative Summon via Regulus
function s.altfilter(c,tp,xyzc)
    return c:IsFaceup() and c:IsCode(10604644) and c:IsCanBeXyzMaterial(xyzc,tp)
end
function s.altcon(e,c,og,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        and Duel.IsExistingMatchingCard(s.altfilter,tp,LOCATION_MZONE,0,1,nil,tp,c)
end
function s.alttg(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
    local g=Duel.SelectMatchingCard(tp,s.altfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
    if #g>0 then
        e:SetLabelObject(g:GetFirst())
        return true
    end
    return false
end
function s.altop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
    local sc=e:GetLabelObject()
    local mg=sc:GetOverlayGroup()
    if #mg>0 then Duel.Overlay(c,mg) end
    c:SetMaterial(Group.FromCards(sc))
    Duel.Overlay(c,Group.FromCards(sc))
end

-- Decree Logic
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end

function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local has_regulus = c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,10604644)
    local b1 = c:CheckRemoveOverlayCard(tp,1,REASON_COST)
    local b2 = Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_SZONE,0,1,nil,TYPE_EQUIP)
    local b3 = has_regulus and c:CheckRemoveOverlayCard(tp,2,REASON_COST)

    if chk==0 then return b1 or b2 end

    local ops={}
    local index={}
    if b1 then 
        table.insert(ops,aux.Stringid(id,2)) -- Detach 1
        table.insert(index,0)
    end
    if b2 then 
        table.insert(ops,aux.Stringid(id,3)) -- Send Equip
        table.insert(index,1)
    end
    if b3 then 
        table.insert(ops,aux.Stringid(id,4)) -- Detach 2
        table.insert(index,2)
    end

    local op=Duel.SelectOption(tp,table.unpack(ops))
    local choice=index[op+1]

    if choice==0 then
        c:RemoveOverlayCard(tp,1,1,REASON_COST)
        e:SetLabel(1)
    elseif choice==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_SZONE,0,1,1,nil,TYPE_EQUIP)
        Duel.SendtoGrave(g,REASON_COST)
        e:SetLabel(1)
    else
        c:RemoveOverlayCard(tp,2,2,REASON_COST)
        e:SetLabel(2)
    end
end


function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local count = e:GetLabel()
    local final_types = 0
    
    for i=1,count do
        -- 70: Monster, 71: Spell, 72: Trap
        local res = Duel.SelectOption(tp,70,71,72)
        local t = (res==0 and TYPE_MONSTER) or (res==1 and TYPE_SPELL) or TYPE_TRAP
        -- Bitwise OR to combine types if count is 2
        final_types = final_types | t
    end
    e:SetLabel(final_types)
end


function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local ty = e:GetLabel()
    local c=e:GetHandler()
    
    -- Flag for "Cannot activate next turn"
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,2)

    -- New Menu: Choose which of the 3 effects to apply
    -- aux.Stringid(id, 5): Cannot add to hand
    -- aux.Stringid(id, 6): Cannot activate in GY
    -- aux.Stringid(id, 7): Protection for archetype
    local op = Duel.SelectOption(tp, aux.Stringid(id,5), aux.Stringid(id,6), aux.Stringid(id,7))

    if op == 0 then
        -- 1. Cannot add from GY/Deck to hand
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_TO_HAND)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(0,1)
        e1:SetTarget(function(e,card) return card:IsType(ty) and card:IsLocation(LOCATION_DECK+LOCATION_GRAVE) end)
        e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
        Duel.RegisterEffect(e1,tp)

    elseif op == 1 then
        -- 2. Cannot activate effects in GY
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CANNOT_ACTIVATE)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e2:SetTargetRange(0,1)
        e2:SetValue(function(e,re,tp) 
            return re:IsActiveType(ty) and re:GetActivateLocation()==LOCATION_GRAVE 
        end)
        e2:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
        Duel.RegisterEffect(e2,tp)

    elseif op == 2 then
        -- 3. Stella-Regis/Therion unaffected by declared type
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_IMMUNE_EFFECT)
        e3:SetTargetRange(LOCATION_ONFIELD,0)
        e3:SetTarget(function(e,card) return card:IsSetCard(0x1908) or card:IsSetCard(0x17b) end)
        e3:SetValue(function(e,te) 
            return te:IsActiveType(ty) and te:GetOwnerPlayer()~=e:GetHandlerPlayer() 
        end)
        e3:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
        Duel.RegisterEffect(e3,tp)
    end
end

