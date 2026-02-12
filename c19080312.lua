-- Stella-Regis "Authority" Eclipse Leo
-- Rank 10 DARK Machine-Type / Xyz Effect Monster
-- ATK 4000 / DEF 0
-- 3 or more Level 10 monsters including "Therion Irregular"
-- You can only Special Summon "Stella-Regis "Authority" Eclipse Leo" once per turn.
-- During your Main Phase, if this card has "Therion Irregular" as Xyz material, detach all materials from this card; Send all cards on the field except this card to graveyard, and if you do, apply the following effect:
-- • Neither player can active card or effect until your next Standby Phase.
-- • This card cannot attack until the end of your next turn.
-- • You cannot special summon monster until the end of your next turn.
-- This effect is quick effect if this card has "Stella-Regis "Sovereign" Regulus" or "Therion "King" Regulus".
-- *a little ruling note: 
-- if i use this effect on turn 1 (my turn), no effect can active until turn 3 (my turn again) and this card cant attack until end of turn 3.
-- if i use this effect on turn 2 (opponent turn), no effect can active until turn 3 (my turn) and this card cant attack until end of turn 3.

local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Procedure: 3+ Level 10 monsters (Including Irregular)
    Xyz.AddProcedure(c,nil,10,3,nil,nil,Xyz.InfiniteMats)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)

    -- The Eclipse Authority (Nuke & Triple Lockdown)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.nukecon)
    e1:SetCost(s.nukecost)
    e1:SetTarget(s.nuketg)
    e1:SetOperation(s.nukeop)
    c:RegisterEffect(e1)
    
    -- Quick Effect Upgrade (If Regulus is material)
    local e2=e1:Clone()
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetCondition(s.quickcon)
    c:RegisterEffect(e2)
end

s.listed_names={75290703, 10604644, 19080309} -- Irregular, King, Sovereign

-- Condition check helpers
function s.has_irregular(c)
    return c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,75290703)
end
function s.has_regulus(c)
    return c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,10604644,19080309)
end

function s.nukecon(e,tp,eg,ep,ev,re,r,rp)
    return s.has_irregular(e:GetHandler()) and not s.has_regulus(e:GetHandler())
end

function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
    return s.has_irregular(e:GetHandler()) and s.has_regulus(e:GetHandler())
end

function s.nukecost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,c:GetOverlayCount(),REASON_COST) end
    c:RemoveOverlayCard(tp,c:GetOverlayCount(),c:GetOverlayCount(),REASON_COST)
end

function s.nuketg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end

function s.nukeop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
    
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
        -- RULING LOGIC: Determine reset turn count
        -- If Turn 1 (My Turn): End of Next turn is Turn 3. 
        -- We need 2 "Self-Turn" ends to pass.
        local ct = (Duel.GetTurnPlayer()==tp) and 2 or 1

        -- 1. Neither player can activate cards/effects
        -- Resets at the start of your next Standby Phase
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_ACTIVATE)
        e1:SetTargetRange(1,1)
        e1:SetValue(1)
        e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
        Duel.RegisterEffect(e1,tp)
        
        -- 2. This card Cannot Attack
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CANNOT_ATTACK)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN, ct)
        c:RegisterEffect(e2)

        -- 3. You cannot Special Summon
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e3:SetTargetRange(1,0)
        e3:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN, ct)
        Duel.RegisterEffect(e3,tp)
        
        -- Lock activation message
        Duel.Hint(HINT_CARD,0,id)
    end
end