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
    StellaRegis.AddProcedure(c, id)
    -- (1) Special Summon from hand
    -- local e1=Effect.CreateEffect(c)
    -- e1:SetDescription(aux.Stringid(id,0))
    -- e1:SetType(EFFECT_TYPE_FIELD)
    -- e1:SetCode(EFFECT_SPSUMMON_PROC)
    -- e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    -- e1:SetRange(LOCATION_HAND)
    -- e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    -- e1:SetCondition(s.spcon)
    -- c:RegisterEffect(e1)

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
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_EQUIP)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCountLimit(1,{id,2})
    e4:SetTarget(s.eqtg)
    e4:SetOperation(s.eqop)
    c:RegisterEffect(e4)
end

-- (1) SS Condition
function s.spconfilter(c)
    return c:IsFaceup() and not c:IsRace(RACE_MACHINE)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and not Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- (2) Errata Search/Bounce logic
function s.thfilter(c)
    return c:IsSetCard(0x1908) and c:IsLevel(4) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
    local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
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
    -- Universal Lock
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id,5))
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    if op==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) end
    else
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then Duel.Draw(tp,1,REASON_EFFECT) end
    end
end
function s.splimit(e,c) return not (c:IsLevel(4,8) or c:IsRank(4,8)) end

-- (3) Equip logic
function s.eqfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x1908) or c:IsSetCard(0x17b))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        if Duel.Equip(tp,c,tc) then
            -- Equip limit
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_EQUIP_LIMIT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(s.eqlimit)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e1)
            
            -- (4) Granted Effects to the TARGET (tc)
            -- Piercing
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_PIERCE)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            e2:SetCondition(s.grantcon)
            tc:RegisterEffect(e2)
            
            -- Ignition: Granted to the Monster
            local e3=Effect.CreateEffect(c)
            e3:SetDescription(aux.Stringid(id,6))
            e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
            e3:SetType(EFFECT_TYPE_IGNITION)
            e3:SetRange(LOCATION_MZONE)
            -- IMPORTANT: Use a different ID offset for the granted effect's Count Limit
            -- This prevents it from conflicting with the monster's original HOPT.
            e3:SetCountLimit(1,{id+100,1}) 
            e3:SetTarget(s.sptg2)
            e3:SetOperation(s.spop2)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            e3:SetCondition(s.grantcon)
            tc:RegisterEffect(e3)
        end
    end
end

function s.eqlimit(e,c)
    return c:IsSetCard(0x1908) or c:IsSetCard(0x17b)
end

-- (4) Grant Logic (Helper functions)
function s.grantcon(e)
    return e:GetHandler():GetEquipGroup():IsExists(Card.IsCode,1,nil,id)
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