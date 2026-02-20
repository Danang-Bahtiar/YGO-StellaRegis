-- Stella-Regis "Castellan" Zosma
-- Xyz Monster
-- Rank 4 EARTH Machine-Type / Effect Monster
-- ATK 2000 / DEF 1000
-- 2 Level 4 "Stella-Regis" monsters
-- You can only Special Summon "Stella-Regis "Castellan" Zosma" once per turn.
-- You can only use the (1)st, (2)nd and (3)rd effect of "Stella-Regis "Castellan" Zosma" once per turn.
-- (1) During the Main Phase (Quick Effect): You can detach 1 material from this card; Special Summon 1 "Stella-Regis" Xyz Monster from your Extra Deck with Rank 8 or 10, by using this card as the material. (This Special Summon is treated as an Xyz Summon.)
-- (2) During your Main Phase: If this card is in your Graveyard: You can return this card to Extra Deck and shuffle 1 "Stella-Regis" card from Graveyard to Deck; Special Summon 1 Level 4 or Level 8 "Stella-Regis" or "Therion" monster from your hand.
-- (3) If this card is detached from an Xyz Monster and sent to the Graveyard to activate "Stella-Regis" monster's effect; Add 1 "Stella-Regis" monster from your Deck to your hand.

local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Procedure: 2 Level 4 "Stella-Regis" monsters
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x1908),4,2)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)

    -- (1) Quick Rank-Up (Rank 8 or 10)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.rkcon)
    e1:SetCost(Cost.DetachFromSelf(1)) -- Detach 1 material
    e1:SetTarget(s.rktg)
    e1:SetOperation(s.rkop)
    c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)

    -- (2) Recycle and SS from Hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- (3) Search when detached
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

s.listed_series={0x1908, 0x17b}

-- (1) Rank-Up Logic
function s.rkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.rkfilter(c,e,tp,mc)
    return c:IsType(TYPE_XYZ) and c:IsSetCard(0x1908)
        and (c:IsRank(8) or c:IsRank(10))
        and mc:IsCanBeXyzMaterial(c,tp)
        and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.rktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.rkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.rkfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
    local sc=g:GetFirst()
    if sc then
        local mg=c:GetOverlayGroup()
        if #mg~=0 then Duel.Overlay(sc,mg) end
        sc:SetMaterial(Group.FromCards(c))
        Duel.Overlay(sc,Group.FromCards(c))
        if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
            sc:CompleteProcedure()
        end
    end
end

-- (2) Return to Extra and SS
function s.tdfilter(c)
    return c:IsSetCard(0x1908) and c:IsAbleToDeck()
end
function s.spfilter2(c,e,tp)
    return (c:IsSetCard(0x1908) or c:IsSetCard(0x17b)) 
        and (c:IsLevel(4) or c:IsLevel(8)) 
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToExtra() 
        and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,c)
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sp=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
        if #sp>0 then
            Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- (3) Search when detached
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Check if detached for cost or effect of a Stella-Regis monster
    return c:IsPreviousLocation(LOCATION_OVERLAY) 
        and re and re:GetHandler():IsSetCard(0x1908)
end
function s.thfilter(c)
    return c:IsSetCard(0x1908) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end