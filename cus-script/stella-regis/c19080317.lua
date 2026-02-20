-- Stella-Regis "Infiltrator" Algenubi
-- Rank 4 LIGHT Machine-Type / Xyz Effect Monster
-- ATK 1800 / DEF 2000
-- 2+ Level 4 Monster
-- You can only Special Summon card with this name once per turn.
-- If you use "Stella-Regis "Scout" Algenubi" for this card Xyz Summon, you can treat one level 4 or lower monster on your opponent field as one of the materials.
-- You can only use (1)st and (3)rd effect of this card's name once per turn.
-- (1) If this card is Summoned: your opponent reveal their hand until end of turn.
-- (2) During the End Phase after this card is Special Summoned, discard 1 random card from your opponent hand.
-- (3) During your Main Phase: If this card is in GY, return this card to your Extra Deck; Shuffle 2 "Stella-Regis" card from your GY to your Deck and if you do, banish 1 random card from your opponent's hand or Extra Deck face down.

local s,id=GetID()

s.listed_names={19080302} -- Scout Algenubi
s.listed_series={0x1908} -- Stella-Regis
s.scout_id = 19080302 

function s.initial_effect(c)
    -- Xyz Summon Procedure
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
    Xyz.AddProcedure(c,nil,4,2,nil,nil,Xyz.InfiniteMats)
    
    -- Custom Xyz Summon Logic (Scout Algenubi synergy)
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

    -- (1) Reveal Hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.revcon)
    e1:SetOperation(s.revop)
    c:RegisterEffect(e1)

    -- (2) End Phase Discard
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_HANDES)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.discon)
    e2:SetOperation(s.disop)
    c:RegisterEffect(e2)

    -- (3) GY Shuffle & Banish Face-down
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end

-- Custom Xyz Logic Fix
function s.mfilter(c,tp)
    return c:IsFaceup() and ((c:IsControler(tp) and c:IsLevel(4)) or (c:IsControler(1-tp) and c:IsLevelBelow(4)))
end
function s.xyzcon(e,c,og,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    local mg = Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
    -- Fixed: Use GetCount() or #mg instead of Count()
    return mg:IsExists(Card.IsCode,1,nil,s.scout_id) and mg:GetCount()>=2
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
    local mg = Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
    local g1 = mg:Filter(Card.IsCode,nil,s.scout_id)
    if g1:GetCount()==0 then return false end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg1 = g1:Select(tp,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg2 = mg:FilterSelect(tp,function(tc) return not sg1:IsContains(tc) end,1,1,nil)
    sg1:Merge(sg2)
    if sg1:GetCount()==2 then
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

-- Reveal Logic
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PUBLIC)
    e1:SetTargetRange(0,LOCATION_HAND)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

-- Discard Logic
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnCount()==e:GetHandler():GetTurnID() and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    if #g>0 then
        local sg=g:RandomSelect(tp,1)
        Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
    end
end

-- (3) Banish
function s.gyfilter(c)
    return c:IsSetCard(0x1908) and c:IsAbleToDeck()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToExtra() 
        and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,2,c) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND+LOCATION_EXTRA)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.gyfilter),tp,LOCATION_GRAVE,0,nil)
        if #g>=2 then
            local sg=g:Select(tp,2,2,nil)
            if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
                Duel.ShuffleDeck(tp)
                Duel.BreakEffect()
                local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
                local exg=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
                local b1=#hg>0
                local b2=#exg>0
                if not (b1 or b2) then return end
                local opt=2
                if b1 and b2 then opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
                elseif b1 then opt=0 else opt=1 end
                local res
                if opt==0 then res=hg:RandomSelect(tp,1) else res=exg:RandomSelect(tp,1) end
                if res then Duel.Remove(res,POS_FACEDOWN,REASON_EFFECT) end
            end
        end
    end
end