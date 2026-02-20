-- Stella-Regis "Proto" Armor
-- Link Monster / Link-1 / Machine-Type / Effect Monster
-- 1 "Stella-Regis" monster
-- ATK 0
-- You can only Special Summon "Stella-Regis 'Proto' Armor" once per turn.
-- Once per turn, You can target 1 "Stella-Regis" monster that is equipped to this card; Immediately after this effect resolves, you can Xyz Summon 1 "Stella-Regis" Xyz Monster from your Extra Deck with same Rank as the targeted monster level, using only that monster and this card as material.

local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon Procedure
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
    Link.AddProcedure(c,s.matfilter, 1, 1)

    -- Xyz Summon effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1)
    e1:SetTarget(s.xyztg)
    e1:SetOperation(s.xyzop)
    c:RegisterEffect(e1)
end

s.stellaRegis=0x1908

function s.matfilter(c)
    return c:IsSetCard(s.stellaRegis)
end

function s.eqfilter(c,ec,tp)
    local lv=c:GetOriginalLevel()
    -- Create the material group 'mg'
    local mg=Group.FromCards(ec,c)
    return c:IsSetCard(0x1908) and c:IsType(TYPE_MONSTER)
        -- Pass 'mg' as the final parameter instead of 'ec,c' separately
        and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,lv,mg)
end


function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return c:GetEquipGroup():IsContains(chkc) end
    -- SIMPLE CHECK: Do I have an equip? Is my Extra Deck not full?
    if chk==0 then return c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x1908) 
        and Duel.GetLocationCountFromEx(tp,tp,c)>0 end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=c:GetEquipGroup():FilterSelect(tp,Card.IsSetCard,1,1,nil,0x1908)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) then return end
    
    -- 1. Special Summon the Equip card to the field temporarily
    if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
        local rank = tc:GetOriginalLevel()

        -- 2. CRITICAL: Give the Link-1 the correct Level for the engine
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL) -- Use CHANGE_LEVEL for stability
        e1:SetValue(rank)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD) -- Lasts long enough for the summon check
        c:RegisterEffect(e1)

        -- Complete all pending summons
        Duel.SpecialSummonComplete()

        -- 3. Now perform the official Xyz Summon
        local mg=Group.FromCards(c,tc)
        
        -- Use your custom filter 's.xyzfilter' and pass 'rank' and 'mg' correctly
        local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,rank,mg) 
        
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sc=g:Select(tp,1,1,nil):GetFirst()
            Duel.XyzSummon(tp,sc,nil,mg)
        end
    end
end


-- Update your xyzfilter to only accept the material group as one argument
function s.xyzfilter(c,rank,mg) 
    -- mg is now a Group object
    return c:IsSetCard(0x1908) and c:IsType(TYPE_XYZ) and c:IsRank(rank)
        and c:IsXyzSummonable(nil,mg)
end

