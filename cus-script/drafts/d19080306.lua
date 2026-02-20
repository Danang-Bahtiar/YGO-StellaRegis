-- Stella-Regis "Chevalier" Chertan
-- Xyz Monster
-- Rank 4 EARTH Machine-Type / Effect Monster
-- ATK 2500 / DEF 1500
-- 2 Level 4 monsters
-- You can only Special Summon "Stella-Regis "Chevalier" Chertan" once per turn.
-- You can only use the (1)st and (2) effect of "Stella-Regis "Chevalier" Chertan" once per turn.
-- (1) During the Main Phase (Quick Effect): You can detach 1 material from this card; Special Summon 1 Level 4 or Level 8 "Stella-Regis" or "Therion" monster from your hand, and if you do, treat this card as same level as the Special Summoned monster, then Xyz Summon from your Extra Deck one Xyz Monster that has the same Rank as the Special Summoned monster, by using card(s) you control as material including both this card and the Special Summoned monster. (This Special Summon is treated as an Xyz Summon.) You can only use this effect of "Stella-Regis "Chevalier" Chertan" once per turn.
-- (2) During your Main Phase: If this card is in your Graveyard: You can return this card to Extra Deck and shuffle 1 "Stella-Regis" card from Graveyard to Deck; Attach 1 "Stella-Regis" monsters to one of your "Stella-Regis" Xyz monster from your Deck or Graveyard.
-- (3) If this card is detached from an Xyz Monster and sent to the Graveyard to activate "Stella-Regis" monster's effect; Equip 1 "Stella-Regis" monster from your Deck or Graveyard to one of your Xyz monster as Equip Spell with following effect:
-- • The Equipped Monster treated as "Stella-Regis" monster.
-- • If this card is sent to graveyard, you can add this card to your hand and then shuffle 1 card from Hand to your Deck.

local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Procedure: 2 Level 4 monsters
    Xyz.AddProcedure(c,nil,4,2)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)

    -- (1) Special Summon and Force Xyz Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.rkcon)
    e1:SetCost(Cost.DetachFromSelf(1))
    e1:SetTarget(s.rktg)
    e1:SetOperation(s.rkop)
    c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)

    -- (2) Recycle and Attach from Deck/GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.attgtg)
    e2:SetOperation(s.attop)
    c:RegisterEffect(e2)

    -- (3) Equip when detached
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.eqcon)
    e3:SetTarget(s.eqtg)
    e3:SetOperation(s.eqop)
    c:RegisterEffect(e3)
end

s.listed_series={0x1908, 0x17b}

-- (1) Special Summon and Force Xyz Summon
function s.rkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

-- Fixed xyzfilter: added 'e' and 'tp' to allow checking summon legality
function s.xyzfilter(c,e,tp,rk,mg)
    return c:IsType(TYPE_XYZ) and c:IsRank(rk) 
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
        and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end

-- Fixed spfilter: correctly passing e and tp for the check
function s.spfilter(c,e,tp,mc)
    local lv=c:GetLevel()
    if not ((c:IsSetCard(0x1908) or c:IsSetCard(0x17b)) and (lv==4 or lv==8)) then return false end
    if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
    
    local mg=Group.FromCards(c,mc)
    -- Must pass e and tp into xyzfilter here
    return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv,mg)
end

function s.rktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        local c=e:GetHandler()
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c) 
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.rkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsFacedown() then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,c)
    local sc=g:GetFirst()
    
    if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
        local lv=sc:GetLevel()
        
        -- Apply Level Change so the Xyz Summon is legal
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(lv)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
        
        local mg=Group.FromCards(c,sc)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local xyzg=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv,mg)
        local xyz=xyzg:GetFirst()
        
        if xyz then
            Duel.BreakEffect()
            xyz:SetMaterial(mg)
            Duel.Overlay(xyz,mg)
            Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
            xyz:CompleteProcedure()
        end
    end
end


-- (2) Attach Logic
function s.tdfilter(c)
    return c:IsSetCard(0x1908) and c:IsAbleToDeck()
end
function s.xyztarget(c)
    return c:IsFaceup() and c:IsSetCard(0x1908) and c:IsType(TYPE_XYZ)
end
function s.matfilter(c)
    return c:IsSetCard(0x1908) and c:IsMonster()
end
function s.attgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToExtra()
        and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,c)
        and Duel.IsExistingMatchingCard(s.xyztarget,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local xyz=Duel.SelectMatchingCard(tp,s.xyztarget,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
        if xyz then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
            local mat=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
            if mat then Duel.Overlay(xyz,mat) end
        end
    end
end

-- (3) Equip Logic
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Triggers if detached by a Stella-Regis monster
    return c:IsPreviousLocation(LOCATION_OVERLAY) 
        and re and re:GetHandler():IsSetCard(0x1908)
end

-- This filter defines WHAT can be equipped (Monsters from Deck/GY)
function s.eqfilter(c)
    return (c:IsSetCard(0x1908) and c:IsMonster())
end

-- This filter defines WHO it can be equipped to (Any Xyz on field)
function s.xyztarget(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ)
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.xyztarget,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.SelectMatchingCard(tp,s.xyztarget,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if not tc then return end
    local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
    
    if ec and Duel.Equip(tp,ec,tc) then
        -- (1) Standard Equip Limit
        local e0=Effect.CreateEffect(e:GetHandler())
        e0:SetType(EFFECT_TYPE_SINGLE)
        e0:SetCode(EFFECT_EQUIP_LIMIT)
        e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e0:SetValue(function(e,c) return c==e:GetLabelObject() end)
        e0:SetLabelObject(tc)
        e0:SetReset(RESET_EVENT+RESETS_STANDARD)
        ec:RegisterEffect(e0)

        -- (2) Treat the EQUIPPED MONSTER (tc) as Stella-Regis
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_EQUIP)
        e1:SetCode(EFFECT_ADD_SETCODE)
        e1:SetValue(0x1908)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        ec:RegisterEffect(e1)

        -- (3) To Hand Effect (Survives movement to GY)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetDescription(aux.Stringid(id,3))
        e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
        e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
        e2:SetProperty(EFFECT_FLAG_DELAY)
        e2:SetCode(EVENT_TO_GRAVE)
        -- Removing RESET_EVENT+RESETS_STANDARD allows it to trigger IN the GY
        e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) end)
        e2:SetTarget(s.rehandtg)
        e2:SetOperation(s.rehandop)
        ec:RegisterEffect(e2)
    end
end

function s.rehandtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.rehandop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,c)
        Duel.ShuffleHand(tp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
        if #g>0 then Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
    end
end