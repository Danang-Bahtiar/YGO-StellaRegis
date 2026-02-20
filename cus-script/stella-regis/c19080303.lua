-- Stella-Regis "Throne" Denebola
-- Level 8 LIGHT Machine-Type / Effect Monster
-- ATK 2400 / DEF 1700
-- You can only Special Summon with the (1)st effect of this card’s name once per turn.
-- You can only use the (2)nd and (3)rd effect of this card’s name once per turn.
-- (1) If you control "Therion "King" Regulus" or "Stella-Regis" Xyz monster, you can Special Summon this card (from your hand or GY).
-- (2) You can discard this card; add 1 "Stella-Regis" spell/trap or "Therion" spell/trap from your deck to your hand. For the rest of this turn, you cannot Special Summon monster(s) from the Extra Deck, except Xyz monster(s).
-- (3) If this card is in your Graveyard: you can target 1 "Stella-Regis" or "Therion" monster on your field; Equip this card to that target as an Equip Spell.
-- (4) "Stella-Regis" or "Therion" monster equipped with this card gain the following effect:
-- • This card cannot be destroyed by card effect.
-- • Once per turn, When your opponent active a card or effect; detach 1 material or send one equip card to graveyard, and if you do, negate the effect.

local s, id=GetID()
s.listed_series={0x1908, 0x17b}
s.listed_names={id, 10604644}

function s.initial_effect(c)
    -- (1) Special Summon Procedure (Level 8: Hand/GY)
    StellaRegis.AddProcedure(c, id, 8)

    -- (2) Discard to search Spell/Trap
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

    -- (3) Equip from GY (Utility)
    StellaRegis.AddEquipProcedure(c, id, {StellaRegis.GrantProtectionEffect(c), s.omnineg(c)})
end

-- (2) Logic
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

function s.stfilter(c)
    return (c:IsSetCard(0x1908) or c:IsSetCard(0x17b)) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    StellaRegis.ApplyXyzLock(e:GetHandler(), tp)
end

-- (4) Granted Effects
function s.omnineg(c)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetCategory(CATEGORY_NEGATE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id+100,1}) -- Unique ID for granted effect
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    return e3
end

-- Negate logic (Gained)
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    -- The EFFECT_TYPE_GRANT handles the equip check. 
    -- We just need to check the standard negate conditions.
    return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local b1=c:CheckRemoveOverlayCard(tp,1,REASON_COST)
    local b2=Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_SZONE,0,1,nil,TYPE_EQUIP)
    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,6))
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,4))
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

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
end