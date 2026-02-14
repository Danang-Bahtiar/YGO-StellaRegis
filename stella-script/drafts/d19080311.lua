-- Stella-Regis "Giant" R Leonis
-- Level 10 DARK Machine-Type / Effect Monster
-- ATK 2800 / DEF 2000
-- Cannot be Normal Summon/Set. Must first be Special Summon by its own effect. You can only Special Summon "Stella-Regis "Giant" R Leonis" by its (1)st effect once per turn.
-- You can only use the (2)nd and (3)rd effect of "Stella-Regis "Giant" R Leonis" once per turn.
-- (1) If your opponent control a level 10 or higher monster, you can special summon this card from your hand in attack position.
-- (2) If this card is Special Summon, you can take 1 "Therion Irregular" from your deck and add it to your hand.
-- (3) During your Main Phase, if you control "Therion Irregular": Xyz Summon 1 "Stella-Regis "Authority" Eclipse Leo" Xyz Monster using this card, "Therion Irregular" and 1 level 10 or higher monster your opponent control as material.

local s,id=GetID()
local AUTH_ID = 19080312 -- REPLACE THIS with the actual ID of Authority Eclipse Leo

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetStatus(STATUS_PROC_COMPLETE,false)

    -- (1) Special Summon from hand
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- (2) Search Therion Irregular
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- (3) Specific Xyz Summon (Non-Targeting)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.xyzcon)
    e3:SetTarget(s.xyztg)
    e3:SetOperation(s.xyzop)
    c:RegisterEffect(e3)
end

s.listed_names={75290703, AUTH_ID}

-- (1) Summon Condition
function s.spfilter(c)
    return c:IsFaceup() and c:IsLevelAbove(10)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_MZONE,1,nil)
end

-- (2) Search Logic
function s.thfilter(c)
    return c:IsCode(75290703) and c:IsAbleToHand()
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

-- (3) Specific Xyz Logic
function s.irrfilter(c)
    return c:IsFaceup() and c:IsCode(75290703)
end

function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.irrfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Check if there is a LV10+ on opponent's field
        local g3=Duel.GetMatchingGroup(s.spfilter,tp,0,LOCATION_MZONE,nil)
        return #g3>0 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_EXTRA,0,1,nil,AUTH_ID)
            -- Use MustPlayerCanSpecialSummon for Xyz
            and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local irr=Duel.GetFirstMatchingCard(s.irrfilter,tp,LOCATION_MZONE,0,nil)
    local g_opp=Duel.GetMatchingGroup(s.spfilter,tp,0,LOCATION_MZONE,nil)
    
    if not c:IsRelateToEffect(e) or not irr or #g_opp==0 then return end
    
    -- Pick 1 opponent monster (Non-targeting)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local opp_mat=g_opp:Select(tp,1,1,nil)
    
    -- Prepare materials
    local mg=Group.FromCards(c,irr,opp_mat:GetFirst())
    
    -- Find Authority in Extra Deck
    local sc=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_EXTRA,0,nil,AUTH_ID)
    if sc then
        sc:SetMaterial(mg)
        Duel.Overlay(sc,mg)
        Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
    end
end