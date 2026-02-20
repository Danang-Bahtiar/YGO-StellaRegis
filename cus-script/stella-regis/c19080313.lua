-- Astral Colosseum - Leo's Sanctuary
-- Field Spell
-- (This card always treated as "Stella-Regis" card)
-- You can only active "Astral Colosseum - Leo's Sanctuary" once per turn.
-- You can only use the (3)rd and (4)th effect of this card once per turn.
-- (1) If you control either "Therion "King" Regulus" or "Stella-Regis "Sovereign" Regulus", your Spell/Trap card(s) are uneffected by your opponent's card effects.
-- (2) All monster on the field and GY become Machine monsters.
-- (3) If a card(s) on the field is destroyed, you can attach 1 of the destroyed card to one of you "Stella-Regis" Xyz monster OR add 1 "Stella-Regis" or "Therion" monster from GY or Banishement to your hand.
-- (4) During the Battle Phase (Quick Effect): Banish 1 "Stella-Regis" card from your GY; Until the end of this turn, neither players can active card or effect during a battle that involve a "Stella-Regis" monster.


local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_LIMIT_OATH)
    c:RegisterEffect(e1)

    -- (1) S/T Protection
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_SZONE,0)
    e2:SetCondition(s.protcon)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)

    -- (2) Type Change (Machine)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCode(EFFECT_CHANGE_RACE)
    e3:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
    e3:SetValue(RACE_MACHINE)
    c:RegisterEffect(e3)

    -- (3) Attach or Salvage on Destruction
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetTarget(s.rectg)
    e4:SetOperation(s.recop)
    c:RegisterEffect(e4)

    -- (4) Battle Lock (Quick Effect)
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1,{id,2})
    e5:SetCondition(function() return Duel.IsBattlePhase() end)
    e5:SetCost(s.batcost)
    e5:SetOperation(s.batop)
    c:RegisterEffect(e5)
end

s.listed_names={10604644, 19080309} -- King Regulus, Sovereign Regulus

-- (1) Logic: Shielding S/T
function s.protcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,10604644,19080309),tp,LOCATION_MZONE,0,1,nil)
end
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- (3) Logic: Attach/Salvage
function s.recfilter(c,tp)
    return (c:IsSetCard(0x1908) or c:IsSetCard(0x17b)) and c:IsMonster() and c:IsAbleToHand()
end
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x1908) and c:IsType(TYPE_XYZ)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) and eg:IsExists(Card.IsCanBeXyzMaterial,1,nil,nil)
    local b2=Duel.IsExistingMatchingCard(s.recfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    if chk==0 then return b1 or b2 end
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) and eg:IsExists(Card.IsCanBeXyzMaterial,1,nil,nil)
    local b2=Duel.IsExistingMatchingCard(s.recfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    
    local op=0
    if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b1 then op=0 else op=1 end

    if op==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
        if xyz then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
            local mat=eg:FilterSelect(tp,Card.IsCanBeXyzMaterial,1,1,nil,xyz)
            Duel.Overlay(xyz,mat)
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sc=Duel.SelectMatchingCard(tp,s.recfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
        if #sc>0 then
            Duel.SendtoHand(sc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sc)
        end
    end
end

-- (4) Logic: Battle Silence
function s.batcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0x1908) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_GRAVE,0,1,1,nil,0x1908)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.batop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(1,1)
    e1:SetCondition(s.actcon)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.actcon(e)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    return (a and a:IsSetCard(0x1908)) or (d and d:IsSetCard(0x1908))
end