-- Void's of the Lion
-- Counter Trap
-- (This card is always treated as a "Stella-Regis" card.)
-- You can only active card with this name once per turn.
-- If your opponent activate a card or effect while you control "Stella-Regis "Sovereign" Regulus", Apply the following effect for the rest of turn: 
-- ● Change all monster(s) on the field to face-up Attack Position (FLIP effects are not activated)
-- ● All monster(s) on the field are unaffected by other card effects.
-- ● This turn, your opponent must enter their Battle Phase if able, and any monster they control that can attack must attack "Stella-Regis "Sovereign" Regulus".
-- ● All monster(s) ATK/DEF become their original ATK/DEF

local s,id=GetID()
function s.initial_effect(c)
    -- Activate (Counter Trap Speed)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

s.listed_names={19080309} -- Sovereign Regulus

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,19080309),tp,LOCATION_MZONE,0,1,nil)
        and ep~=tp
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    -- 1. Force ALL monsters to Attack Position (Current + Future)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SET_POSITION)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetValue(POS_FACEUP_ATTACK)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    
    -- Change current ones immediately (No FLIP)
    local g=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    Duel.ChangePosition(g,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)

    -- 2. IMMUNITY: Unaffected by other effects EXCEPT its own and THIS Trap
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetValue(s.efilter)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)

    -- 3. BATTLE PHASE: Must enter and Must attack Regulus
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_MUST_ATTACK)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e3,tp)
    
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_MUST_ATTACK_MONSTER)
    e4:SetTargetRange(0,LOCATION_MZONE)
    e4:SetValue(s.atklimit)
    e4:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e4,tp)

    -- 4. ATK/DEF become Original (Continuous for all monsters)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_SET_ATTACK_FINAL)
    e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e5:SetValue(function(e,tc) return tc:GetBaseAttack() end)
    e5:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e5,tp)

    local e6=e5:Clone()
    e6:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e6:SetValue(function(e,tc) return tc:GetBaseDefense() end)
    Duel.RegisterEffect(e6,tp)
end

-- The Filter: te=Effect trying to apply, c=The monster being protected
function s.efilter(e,te,c)
    -- 1. NOT immune to itself
    if te:GetHandler()==c then return false end
    -- 2. NOT immune to the Trap that created this effect (Void's of the Lion)
    if te:GetOwner()==e:GetOwner() then return false end
    -- Otherwise, immune to EVERYTHING else
    return true
end

function s.atklimit(e,c)
    return c:IsCode(19080309) -- Targets Sovereign Regulus
end
