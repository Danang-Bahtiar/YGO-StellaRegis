-- Stella-Regis "Herald" Algeliache
-- Rank 4 LIGHT Machine-Type / Xyz Effect Monster
-- ATK 1500 / DEF 1800
-- 2 Level 4 "Stella-Regis" monster
-- You can only Special Summon card with this name once per turn.
-- If you use "Stella-Regis "Courier" Algeliache" as material, you can treat any other monster you control as level 4 "Stella-Regis" monster as material to Xyz Summon this card.
-- You can only use the (1)st, (2)nd effect of this card's name once per turn.
-- (1) During the Main Phase (Quick Effect): Detach 1 Material from this card; Xyz Summon 1 Rank 8 LIGHT Xyz monster from your extra deck using this card as material (Transfer this card's materials to the summoned monster) but return it to Extra Deck during End Phase.
-- (2) During your Main Phase: If this card is in the GY: Return this card to Extra Deck; Shuffle 1 "Stella-Regis" card from your GY to your Deck, then Special Summon 1 "Stella-Regis "Courier" Algeliache" from your deck but negate it's effect.

local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon Procedure
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
    -- 2 Level 4 "Stella-Regis" monsters
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x1908),4,2)
    
    -- Custom Xyz Summon: Courier Synergy (Treats ANY monster as Level 4 Stella-Regis)
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,5))
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.xyzcon)
    e0:SetTarget(s.xyztg)
    e0:SetOperation(s.xyzop)
    e0:SetValue(SUMMON_TYPE_XYZ)
    c:RegisterEffect(e0)

    -- (1) Rank-Up Leap (Quick Effect)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCondition(function() return Duel.IsMainPhase() end)
    e1:SetCost(Cost.DetachFromSelf(1))
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- (2) GY Recycle & Summon Courier
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.rettg)
    e2:SetOperation(s.retop)
    c:RegisterEffect(e2)
end

s.listed_names={19080314} -- Courier Algeliache
s.courier_id = 19080314

-- Custom Xyz Logic: One Courier + Literally anything else
function s.mfilter1(c,tp)
    -- Must be the Courier on the field
    return c:IsFaceup() and c:IsCode(s.courier_id) and c:IsControler(tp)
end

function s.mfilter2(c,tp)
    -- Any other face-up monster (Doesn't need to be Level 4 or Stella-Regis)
    return c:IsFaceup() and c:IsControler(tp)
end

function s.xyzcon(e,c,og,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    -- Check for Courier
    local has_courier=Duel.IsExistingMatchingCard(s.mfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
    -- Check for at least one other monster
    local has_other=Duel.IsExistingMatchingCard(s.mfilter2,tp,LOCATION_MZONE,0,2,nil,tp)
    return has_courier and has_other
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
    local g1=Duel.GetMatchingGroup(s.mfilter1,tp,LOCATION_MZONE,0,nil,tp)
    if #g1==0 then return false end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg1=g1:Select(tp,1,1,nil) -- Forced selection of Courier
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    -- Select any other monster to treat as Level 4 Stella-Regis
    local sg2=Duel.SelectMatchingCard(tp,s.mfilter2,tp,LOCATION_MZONE,0,1,1,sg1:GetFirst(),tp)
    
    sg1:Merge(sg2)
    if #sg1==2 then
        sg1:KeepAlive()
        e:SetLabelObject(sg1)
        return true
    end
    return false
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
    local mg=e:GetLabelObject()
    if not mg then return end
    c:SetMaterial(mg)
    Duel.Overlay(c,mg)
    mg:DeleteGroup()
end

-- Rank-Up Leap Logic
function s.rkfilter(c,e,tp,mc)
    return c:IsRank(8) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ)
        and mc:IsCanBeXyzMaterial(c)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
        and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.GetMatchingGroup(s.rkfilter,tp,LOCATION_EXTRA,0,nil,e,tp,c)
    if #g>0 then
        local sc=g:Select(tp,1,1,nil):GetFirst()
        local mg=c:GetOverlayGroup()
        if #mg~=0 then Duel.Overlay(sc,mg) end
        sc:SetMaterial(Group.FromCards(c))
        Duel.Overlay(sc,Group.FromCards(c))
        if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
            sc:CompleteProcedure()
            -- Add the return to Extra Deck during End Phase effect
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_END)
            e1:SetCountLimit(1)
            e1:SetLabelObject(sc)
            e1:SetOperation(s.retop_ep)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
        end
    end
end
function s.retop_ep(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc then Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
end

-- GY Effect: Shuffle 1 and Summon Courier
function s.gyfilter(c)
    return c:IsSetCard(0x1908) and c:IsAbleToDeck()
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToExtra() 
        and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,c)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsCode,s.courier_id),tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil):Select(tp,1,1,nil)
        if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
            Duel.ShuffleDeck(tp)
            Duel.BreakEffect()
            local sc=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,s.courier_id):GetFirst()
            if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_DISABLE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                sc:RegisterEffect(e1)
                local e2=e1:Clone()
                e2:SetCode(EFFECT_DISABLE_EFFECT)
                sc:RegisterEffect(e2)
            end
            Duel.SpecialSummonComplete()
        end
    end
end
