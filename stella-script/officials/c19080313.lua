-- Astral Colosseum - Leo's Sanctuary
-- Field Spell
-- (This card always treated as "Stella-Regis" card)
-- You can only active "Astral Colosseum - Leo's Sanctuary" once per turn.
-- You can only use the (1)st and (2)nd effect of this card once per turn.
-- (1) If a card(s) on field is destroyed, you can attach 1 of the destroyed card to one of you "Stella-Regis" Xyz monster OR add one "Stella-Regis" or "Therion" monster from Graveyard to Hand.
-- (2) Discard 1 card; Equip one card from your deck to one of your "Stella-Regis" or "Therion" monster. The Equip Card treated as "Therion" monster card.
-- (3) If you control either "Therion "King" Regulus", "Stella-Regis "Sovereign" Regulus" or "Stella-Regis "Authority" Eclipse Leo", your Spell/Trap card(s) are uneffected by your opponent's card effects.
-- (4) All monster on Field and Graveyard become Machine monsters.

local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- (1) Attach or Salvage on destruction
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- (2) Discard to Equip from Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,{id,2})
    e2:SetCost(s.eqcost)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)

    -- (3) S/T Protection
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_SZONE,0)
    e3:SetCondition(s.protcon)
    e3:SetValue(s.efilter)
    c:RegisterEffect(e3)

    -- (4a) All monsters on the field become Machine
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e4:SetCode(EFFECT_CHANGE_RACE)
    e4:SetValue(RACE_MACHINE)
    c:RegisterEffect(e4)

    -- (4b) All monsters in the GY become Machine
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetRange(LOCATION_FZONE)
    e5:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
    e5:SetCode(EFFECT_CHANGE_RACE)
    e5:SetValue(RACE_MACHINE)
    c:RegisterEffect(e5)
end

s.listed_names={10604644, 19080309, 19080312} -- King Regulus, Sovereign Regulus, Authority Leo

-- (1) Destruction Logic
function s.desfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x1908)
end
function s.thfilter(c)
    return (c:IsSetCard(0x1908) or c:IsSetCard(0x17b)) and c:IsMonster() and c:IsAbleToHand()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.desfilter,nil,tp)
    if chk==0 then return #g>0 and (Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) 
        or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.desfilter,nil,tp)
    local b1 = #g>0 and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
    local b2 = Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
    
    local op=Duel.SelectEffect(tp,
        {b1, aux.Stringid(id,2)}, -- Attach
        {b2, aux.Stringid(id,3)}) -- Add to Hand
    
    if op==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
        local mat=g:Select(tp,1,1,nil):GetFirst()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
        if xyz and mat then Duel.Overlay(xyz,mat) end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local th=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #th>0 then 
            Duel.SendtoHand(th,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,th)
        end
    end
end

-- (2) Equip from Deck Logic
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
function s.monfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x1908) or c:IsSetCard(0x17b))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(nil,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.eqlimit(e,c)
    return e:GetLabelObject()==c
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local tc=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if not tc then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local ec=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
    if ec and Duel.Equip(tp,ec,tc) then
        -- Add Equip Limit
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(s.eqlimit)
        e1:SetLabelObject(tc)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        ec:RegisterEffect(e1)
        -- (2b) Treated as "Therion" monster card
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_ADD_SETCODE)
        e2:SetValue(0x17b)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        ec:RegisterEffect(e2)
    end
end

-- (3) Protection Logic
function s.protfilter(c)
    return c:IsFaceup() and (c:IsCode(10604644) or c:IsCode(19080309) or c:IsCode(19080312))
end
function s.protcon(e)
    -- You will need to replace 'id_sovereign' and 'id_eclipse_leo' with the actual IDs of those cards
    return Duel.IsExistingMatchingCard(s.protfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end