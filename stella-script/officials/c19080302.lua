-- Stella-Regis "Scout" Algenubi
-- Level 4 EARTH Machine-Type / Effect Monster
-- ATK 1300 / DEF 1700
-- You can only Special Summon with the (1)st effect of this card’s name once per turn.
-- You can only use the (2)nd and (3)rd effect of this card’s name once per turn.
-- (1) If you control no monster or all monsters you control are Machine type monsters, you can Special Summon this card (from your hand).
-- (2) If this card is Normal or Special Summoned: you can set 1 "Stella-Regis" Spell/Trap from deck to field, or, if this card is Special Summoned while you control another Machine type monster(s) on the field, you can Target 1 Spell/Trap on opponent's field, return it to hand and if you do, draw 1 card. For the rest of this turn, you cant special summon monster(s), except level/rank 4 or 8 monster(s).
-- (3) if this card is in your Graveyard: you can target 1 "Stella-Regis" or "Therion" monster on your field; Equip this card to that target as an Equip Spell.
-- (4) "Stella-Regis" or "Therion" monster equipped with this card gain following effect:
-- • If the equipped monster attacks a Defense Position monster, inflict piercing battle damage to your opponent.
-- • Once per turn during your Main Phase, return 1 "Stella-Regis" card in graveyard to deck; Draw 1 card.

local s, id=GetID()
s.listed_series={0x1908, 0x17b}
s.listed_names={id}

function s.initial_effect(c)
    -- (1) Special Summon Procedure (Utility)
    StellaRegis.AddProcedure(c, id, 4)

    -- (2) Normal or Special Summon: Set S/T OR (Bounce & Draw)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DRAW) -- Category for the draw part
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- (3) Equip Procedure (Utility)
    StellaRegis.AddEquipProcedure(c, id, {StellaRegis.GrantPiercing(c), s.grantrecdraw(c)})
end

-- (2) Logic
function s.stfilter(c)
    return c:IsSetCard(0x1908) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
    
    -- Choice 1: Set from Deck
    local b1=Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil)
    
    -- Choice 2: Bounce & Draw
    local b2=c:IsSpecialSummoned() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,1,c)
        and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_SZONE,1,nil)
    
    if chk==0 then return b1 or b2 end
    
    local op=Duel.SelectEffect(tp, 
        {b1, aux.Stringid(id,3)}, -- "Set Stella-Regis Spell/Trap"
        {b2, aux.Stringid(id,4)}) -- "Bounce Opponent S/T & Draw"
    
    e:SetLabel(op)
    if op==1 then
        e:SetCategory(CATEGORY_SET) -- Setting doesn't have a specific category, but you can use CATEGORY_SPECIAL_SUMMON if it were a monster
    else
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_SZONE,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local op=e:GetLabel()
    StellaRegis.ApplyLevelLock(c, tp)

    if op==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SSet(tp,g:GetFirst())
        end
    else
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end

-- (4) Granted Effects
function s.grantrecdraw(c)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,6))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id+100,1}) 
    e3:SetTarget(s.drtg)
    e3:SetOperation(s.drop)
    return e3
end

function s.tdfilter(c)
    return c:IsSetCard(0x1908) and c:IsAbleToDeck()
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
        and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.HintSelection(g)
        if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
            Duel.ShuffleDeck(tp) -- Explicit shuffle for safety
            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end