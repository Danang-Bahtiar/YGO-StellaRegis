-- Stella-Regis "Courier" Algeliache
-- Level 4 EARTH Machine-Type / Effect Monster
-- ATK 1000 / DEF 1800
-- You can only Special Summon with the (1)st effect of this card’s name once per turn.
-- You can only use the (2)nd and (3)rd effect of this card’s name once per turn.
-- (1) If you control no monster or all monsters you control are Machine type monsters, you can Special Summon this card (from your hand).
-- (2) If this card is Normal or Special Summoned: you can add 1 "Stella-Regis" Spell/Trap from deck to hand, or, if this card is Special Summoned while you control another Machine type monster(s) on the field, draw 2 cards then discard 1 card from your hand. For the rest of this turn, you cant special summon monster(s), except level/rank 4 or 8 monster(s).
-- (3) If this card is in your Graveyard: you can target 1 "Stella-Regis" or "Therion" monster on your field; Equip this card to that target as an Equip Spell.
-- (4) "Stella-Regis" or "Therion" monster equipped with this card gain following effect:
-- • The equipped can make a second attack during each Battle Phase.
-- • Once per turn during your Main Phase, return "Stella-Regis" card from Field or GY up to number of "Stella-Regis" monster equipped to monster(s) to your Deck; Banish equal number of card(s) from your Opponent's GY.

local s, id = GetID()
s.listed_series={0x1908, 0x17b}
s.listed_names={id}

-- stringid list sorted 0 to 6
-- [Courier] Special Summon from Hand
-- [Courier] Normal/Special Summon Effect
-- [Courier] Equip from GY
-- [Courier] Add 1 "Stella-Regis" Spell/Trap
-- [Courier] Draw 2 cards, Discard 1
-- [Courier] Restrict SP Summon: Level/Rank 4/8
-- [Courier] Return "Stella-Regis" card from Field or GY up to "Stella-Regis" monster equipped to monster(s); Banish equal number of card(s) from Opponent's GY

function s.initial_effect(c)
    -- (1) Special Summon Procedure (Utility)
    StellaRegis.AddProcedure(c, id, 4)

    -- (2) Normal or Special Summon: Search S/T OR (Draw 2, Discard 1)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW+CATEGORY_HANDES)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- (3) Equip Procedure (Utility)
    StellaRegis.AddEquipProcedure(c, id, {StellaRegis.GrantSecondAttack(c), s.grantrecban(c)})
end

-- (2) Logic
function s.thfilter(c)
    return c:IsSetCard(0x1908) and c:IsSpellTrapCard() and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    local b2=c:IsSpecialSummoned() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,1,c)
        and Duel.IsPlayerCanDraw(tp,2)

    if chk==0 then return b1 or b2 end
    local op=Duel.SelectEffect(tp, {b1, aux.Stringid(id,3)}, {b2, aux.Stringid(id,4)})
    e:SetLabel(op)

    if op==1 then
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    else
        e:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
        Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
    end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local op=e:GetLabel()
    StellaRegis.ApplyLevelLock(c, tp)

    if op==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then 
            Duel.SendtoHand(g,nil,REASON_EFFECT) 
            Duel.ConfirmCards(1-tp,g) 
        end
    else
        if Duel.Draw(tp,2,REASON_EFFECT)==2 then
            Duel.ShuffleHand(tp)
            Duel.BreakEffect()
            Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
        end
    end
end

-- (4) Granted Effect: Return to Deck & Banish
function s.grantrecban(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,6))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id+100,1})
    e1:SetTarget(s.rectg)
    e1:SetOperation(s.recop)
    return e1
end

function s.eqfilter(c)
    return c:IsSetCard(0x1908) and c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_SZONE)
end

-- (4) Granted Effect: Return to Deck & Banish
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    -- 1. Count "Stella-Regis" monsters currently in the Spell/Trap Zone (equipped)
    local count=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x1908),tp,LOCATION_SZONE,0,nil)
    
    -- 2. Check if Opponent has cards in GY to banish
    local opp_gy=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)

    if chk==0 then 
        return count>0 
        and opp_gy>0 -- Must have at least 1 target in opponent's GY to activate
        and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil,0x1908) 
    end
    
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end

function s.recop(e,tp,eg,ep,ev,re,r,rp)
    local count=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x1908),tp,LOCATION_SZONE,0,nil)
    local opp_gy=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
    
    if count==0 or #opp_gy==0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    -- Select up to 'count' cards to return to deck
    local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,count,e:GetHandler(),0x1908)
    
    if #g>0 then
        Duel.HintSelection(g)
        -- Explicitly return to Deck (SEQ_DECKSHUFFLE ensures it shuffles in)
        local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        
        if ct>0 then
            -- Shuffle is handled by SEQ_DECKSHUFFLE, but forced here for engine safety
            Duel.ShuffleDeck(tp)
            
            -- Re-check opponent's GY count based on how many actually returned
            local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
            if #rg>0 then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
                -- Select equal number to cards returned (ct)
                local sg=rg:Select(tp,1,ct,nil)
                Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
            end
        end
    end
end