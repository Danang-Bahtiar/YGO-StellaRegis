-- Stella-Regis "Strike" Subra
-- Level 4 EARTH Machine-Type / Effect Monster
-- ATK 1700 / DEF 1300
-- You can only Special Summon with the (1)st effect of this card’s name once per turn.
-- You can only use the (2)nd and (3)rd effect of this card’s name once per turn.
-- (1) If you control no monster or all monsters you control are Machine type monsters, you can Special Summon this card (from your hand).
-- (2) If this card is Normal or Special Summoned: you can add 1 level 4 "Stella-Regis" monster from deck to hand, except "Stella-Regis "Strike" Subra", or, if this card is Special Summoned while you control another Machine type monster(s) on the field, you can Target 1 monster on opponent's field, return it to hand and if you do, draw 1 card. For the rest of this turn, you cant special summon monster(s), except level/rank 4 or 8 monster(s).
-- (3) If this card is in your Graveyard: you can target 1 "Stella-Regis" or "Therion" monster on your field; Equip this card to that target as an Equip Spell.
-- (4) "Stella-Regis" or "Therion" monster equipped with this card gain following effect:
-- • If the equipped monster attacks a Defense Position monster, inflict piercing battle damage to your opponent.
-- • Once per turn during your Main Phase, return 1 "Stella-Regis" card on the field to hand; Special Summon 1 "Stella-Regis" monster from your hand in defense position.

local s, id=GetID()
-- Stella-Regis: 0x1908, Therion: 0x17b
s.listed_series={0x1908, 0x17b}
s.listed_names={id}

function s.initial_effect(c)
    --Special Summon this card (from your hand)
    StellaRegis.AddProcedure(c, id, 4)

    -- (2) Normal or Special Summon: Search or (Bounce & Draw)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
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

    -- (3) Equip from GY
    -- Add (c) to each function in the table so they execute and return the effect
    StellaRegis.AddEquipProcedure(c, id, {StellaRegis.GrantPiercing(c), s.grantswap(c)})
end

-- (2) Errata Search/Bounce logic
function s.thfilter(c)
    return c:IsSetCard(0x1908) and c:IsLevel(4) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()

    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end

    -- option 1: Search
    local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    -- option 2: Bounce + Draw 1
    local b2=c:IsSpecialSummoned() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,1,c)
        and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil)

    if chk==0 then return b1 or b2 end

    local op=Duel.SelectEffect(tp, {b1, aux.Stringid(id,3)}, {b2, aux.Stringid(id,4)})

    e:SetLabel(op)

    if op==1 then
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    else
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local op=e:GetLabel()
    StellaRegis.ApplyLevelLock(c, tp)

    if op==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
    else
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then Duel.Draw(tp,1,REASON_EFFECT) end
    end
end

-- (3) Equip logic
function s.grantswap(c)
    local e=Effect.CreateEffect(c)
    e:SetDescription(aux.Stringid(id,6))
    e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e:SetType(EFFECT_TYPE_IGNITION)
    e:SetRange(LOCATION_MZONE)
    e:SetCountLimit(1,{id+100,1}) 
    e:SetTarget(s.sptg2)
    e:SetOperation(s.spop2)
    return e
end

function s.rtfilter(c)
    return c:IsSetCard(0x1908) and c:IsAbleToHand()
end

function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x1908) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
        end
    end
end