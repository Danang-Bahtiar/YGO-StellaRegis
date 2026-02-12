-- Stella-Regis "Crown" Adhafera
-- Level 8 LIGHT Machine-Type / Effect Monster
-- ATK 1600 / DEF 2200
-- You can only Special Summon with the (1)st effect of this card’s name once per turn.
-- You can only use the (2)nd and (3)rd effect of this card’s name once per turn.
-- (1) If you control "Therion "King" Regulus" or Rank 8 "Stella-Regis" Xyz monster, you can Special Summon this card (from your hand or GY).
-- (2) You can discard this card; add 1 "Stella-Regis" monster or "Therion" monster from your Deck to your hand, except "Stella-Regis "Crown" Adhafera". For the rest of this turn, you cannot Special Summon monster(s) from the Extra Deck, except Xyz monster(s).
-- (3) If this card is in your Graveyard: you can target 1 "Stella-Regis" Xyz monster on your field; Equip this card to that target.
-- A "Stella-Regis" or "Therion" monster equipped with this card gain the following effect:
-- • This card cannot be tributed or used as material for Fusion, Synchro, Xyz or Link summon.
-- • Once per turn, When your opponent active a card or effect; detach 1 material or send one equip card to graveyard, and if you do, destroy 1 card on your opponent field.

local s, id=GetID()
s.listed_series={0x1908, 0x17b}
s.listed_names={id, 10604644}

function s.initial_effect(c)
    -- (1) Special Summon from hand or GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- (2) Discard to search Monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- (3) Equip from GY (Ignition)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.eqtg)
    e3:SetOperation(s.eqop)
    c:RegisterEffect(e3)

    -- GRANTING SYSTEM (Therion-style)
    -- Effect 1: Protection (Applied to the monster it is equipped to)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_UNRELEASABLE_SUM)
    e4:SetValue(1)
    c:RegisterEffect(e4)
    
    local e4b=e4:Clone()
    e4b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e4b)

    -- Material Protections
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_EQUIP)
    e5:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    e5:SetValue(s.matval)
    c:RegisterEffect(e5)
    
    local e5b=e5:Clone() e5b:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL) c:RegisterEffect(e5b)
    local e5c=e5:Clone() e5c:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL) c:RegisterEffect(e5c)
    local e5d=e5c:Clone() e5d:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL) c:RegisterEffect(e5d)


    -- Effect 2: Destroy 1 card on opponent's field (Granted to the Xyz)
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,4))
    e6:SetCategory(CATEGORY_DESTROY)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_CHAINING) -- Triggers when a chain is forming
    e6:SetRange(LOCATION_MZONE) -- Range must be MZONE for the granted monster to use it
    e6:SetCountLimit(1)
    e6:SetCondition(s.descon)
    e6:SetCost(s.negcost)
    e6:SetTarget(s.destg)
    e6:SetOperation(s.desop)
    
    -- The Grant Effect
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e7:SetRange(LOCATION_SZONE)
    e7:SetTargetRange(LOCATION_MZONE,0)
    e7:SetTarget(s.eftg)
    e7:SetLabelObject(e6)
    c:RegisterEffect(e7)
end

-- (1) Condition: King Regulus or Rank 8 Stella-Regis
function s.spfilter(c)
    return (c:IsFaceup() and c:IsCode(10604644)) 
        or (c:IsFaceup() and c:IsSetCard(0x1908) and c:IsType(TYPE_XYZ) and c:IsRank(8))
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- (2) Search Monster & Lock
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

function s.monfilter(c)
    return (c:IsSetCard(0x1908) or c:IsSetCard(0x17b)) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    -- Xyz Lock
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

-- (3) Equip logic
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x1908) and c:IsType(TYPE_XYZ)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.xyzfilter(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Equip(tp,c,tc)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(function(e,c) return c:IsSetCard(0x1908) end)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end

-- Granting Conditions (Restricted to Stella-Regis or Therion)
function s.efcon(e)
    return e:GetHandler():GetEquipTarget()~=nil
end
function s.eftg(e,c)
    return e:GetHandler():GetEquipTarget()==c 
        and (c:IsSetCard(0x1908) or c:IsSetCard(0x17b))
end

-- Destruction Effect (Gained)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp -- Opponent only
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler() -- This is the Xyz monster granted the effect
    local b1=c:CheckRemoveOverlayCard(tp,1,REASON_COST)
    local b2=Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_SZONE,0,1,nil,TYPE_EQUIP)
    if chk==0 then return b1 or b2 end
    
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,5))
        op=0
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,6))
        op=1
    end
    
    if op==0 then
        c:RemoveOverlayCard(tp,1,1,REASON_COST)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_SZONE,0,1,1,nil,TYPE_EQUIP)
        Duel.SendtoGrave(g,REASON_COST)
    end
end


function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.HintSelection(g)
        Duel.Destroy(g,REASON_EFFECT)
    end
end

-- Material value function: prevents opponent from using it
function s.matval(e,c)
    if not c then return false end
    return c:GetControler()~=e:GetHandlerPlayer()
end
