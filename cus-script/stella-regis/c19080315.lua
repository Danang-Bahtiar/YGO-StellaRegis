-- Stella-Regis "Page" Rasalas
-- Level 4 EARTH Machine-Type / Effect Monster
-- ATK 500 / DEF 2000
-- You can only Special Summon with the (1)st effect of this card’s name once per turn.
-- You can only use the (2)nd and (3)rd effect of this card’s name once per turn.
-- (1) If you control no monster or all monsters you control are Machine type monsters, you can Special Summon this card (from your hand).
-- (2) If this card is Normal or Special Summoned: you can Special Summon 1 level 4 "Stella-Regis" monster from Deck except "Stella-Regis "Page" Rasalas", or, if this card is Special Summoned while you control another Machine type monster(s) on the field, Special Summon 1 level 4 "Stella-Regis" monster from Hand or GY and excavate 3 cards from top of your Deck; add 1 excavated "Stella-Regis" card to hand then shuffle the rest back to your Deck. For the rest of this turn, you cant special summon monster(s), except level/rank 4 or 8 monster(s).
-- (3) If this card is in your Graveyard: you can target 1 "Stella-Regis" or "Therion" monster on your field; Equip this card to that target as an Equip Spell.
-- (4) "Stella-Regis" or "Therion" monster equipped with this card gain following effect:
-- • While the equipped card is on field, card(s) in your GY cannot be banished by your opponent's card effect.
-- • Once per turn during your Main Phase, Reveal 3 "Stella-Regis" card(s) from your Deck; your opponent randomly choose 1 to be add to your hand then sent the rest to GY.

-- stringid list sorted 0 to 6
-- [Page] Special Summon from Hand
-- [Page] Normal/Special Summon Effect
-- [Page] Equip from GY
-- [Page] Special Summon 1 level 4 "Stella-Regis" monster from Deck
-- [Page] Special Summon 1 level 4 "Stella-Regis" monster from Hand or GY and Excavate 3 cards from top of your Deck and add 1 excavated "Stella-Regis" card to hand
-- [Page] Restrict SP Summon: Level/Rank 4/8
-- [Page] Reveal 3 "Stella-Regis" card(s) from your Deck

local s, id = GetID()
s.listed_series={0x1908, 0x17b}
s.listed_names={id}

function s.initial_effect(c)
    -- (1) Special Summon Procedure (Utility)
    StellaRegis.AddProcedure(c, id, 4)

    -- (2) Normal or Special Summon: SS from Deck OR (SS from Hand/GY + Excavate)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.sstg)
    e2:SetOperation(s.ssop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- (3) Equip Procedure (Utility)
    -- Using the utility Grave Protection + Unique Pantheism-style reveal
    StellaRegis.AddEquipProcedure(c, id, {StellaRegis.GrantGraveProtection(c), s.grantreveal(c)})
end

-- (2) Logic
function s.ssfilter(c,e,tp)
    return c:IsSetCard(0x1908) and c:IsLevel(4) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local b1=Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    local b2=c:IsSpecialSummoned() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,1,c)
        and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    
    if chk==0 then return b1 or b2 end
    local op=Duel.SelectEffect(tp, {b1, aux.Stringid(id,3)}, {b2, aux.Stringid(id,4)})
    e:SetLabel(op)

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local op=e:GetLabel()
    StellaRegis.ApplyLevelLock(c, tp)

    if op==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.BreakEffect()
            local exc=Duel.GetDecktopGroup(tp,3)
            if #exc<3 then return end
            Duel.ConfirmCards(tp,exc)
            if exc:IsExists(Card.IsSetCard,1,nil,0x1908) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local sg=exc:FilterSelect(tp,Card.IsSetCard,1,1,nil,0x1908)
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
                exc:RemoveCard(sg:GetFirst())
            end
            Duel.SendtoDeck(exc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end

-- (4) Granted Effect: Reveal 3, Opponent Picks 1
function s.grantreveal(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,6))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id+100,1})
    e1:SetTarget(s.revtg)
    e1:SetOperation(s.revop)
    return e1
end

function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,3,nil,0x1908) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end

function s.revop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,0x1908)
    if #g<3 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local sg=g:Select(tp,3,3,nil)
    Duel.ConfirmCards(1-tp,sg)
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
    local tg=sg:RandomSelect(1-tp,1) -- Opponent randomly chooses
    Duel.SendtoHand(tg,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,tg)
    sg:Sub(tg)
    Duel.SendtoGrave(sg,REASON_EFFECT)
end