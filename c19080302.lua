-- Stella-Regis "Scout" Algenubi
-- Level 4 EARTH Machine-Type / Effect Monster
-- ATK 1300 / DEF 1700
-- You can only Special Summon with the (1)st effect of this card’s name once per turn.
-- You can only use the (2)nd and (3)rd effect of this card’s name once per turn.
-- (1) If you control no monster or all monsters you control are Machine type monsters, you can Special Summon this card (from your hand).
-- (2) If this card is Normal or Special Summoned: you can set 1 "Stella-Regis" Spell/Trap from deck to field, or, if this card is Special Summoned while you control another Machine type monster(s) on the field, you can Target 1 Spell/Trap on opponent's field, return it to hand and if you do, draw 1 card. For the rest of this turn, you cant special summon monster(s), except level/rank 4 or 8 monster(s).
-- (3) if this card is in your Graveyard: you can target 1 "Stella-Regis" or "Therion" monster on your field; Equip this card to that target as an Equip Spell.
-- (4) "Stella-Regis" or "Therion" monster equipped with this card gain following effect:
-- • If the equipped monster attacks a Defense Position monster, inflict piercing battle damage to your opponent.
-- • Once per turn during your Main Phase, return 1 "Stella-Regis" card in graveyard to deck; Draw 1 card.

local s, id=GetID()
s.listed_series={0x1908,0x17B}
s.listed_names={id}

function s.initial_effect(c)
    --Special Summon this card (from your hand)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)    
    c:RegisterEffect(e1)

    --Add 1 "Stella-Regis" spell from deck to hand, or destroy 1 spell on opponent's field and draw 1 card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1)) -- "Select an effect"
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    -- Effect 3: Special Summon (Clone)
    local e3=e2:Clone()
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_DRAW)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Equip this card from GY to "Stella-Regis" or "Therion" monster
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,{id,2})
    e4:SetTarget(s.eqtg)
    e4:SetOperation(s.eqop)
    c:RegisterEffect(e4)
end

-- Effect (1)

function s.spconfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_MACHINE)
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and not Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Effect (2)

-- Filter for "Stella-Regis" monsters except itself
function s.thfilter(c)
    return c:IsSetCard(0x1908) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    -- b1: Search
    local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    -- b2: Destroy & Draw
   local b2=e:GetHandler():IsSpecialSummoned() 
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,1,c)
        and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_SZONE,1,nil)
    
    if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) end
    if chk==0 then return b1 or b2 end
    
    -- Proper SelectOption with Strings
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- 0: Search, 1: Destroy
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1))
        op=0
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,2))
        op=1
    end
    
    e:SetLabel(op)
    if op==0 then
        e:SetProperty(EFFECT_FLAG_DELAY) -- Remove Card Target for Search
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    else
        e:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_SZONE,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    local c=e:GetHandler()

    -- Apply the Lock (Always applies regardless of which choice was made)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id,4)) -- "Special Summon restricted"
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    if op==0 then
        --Add 1 "Stella-Regis" spell/trap from deck to hand
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    else
        --Destroy 1 monster on opponent's field and draw 1 card
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end

-- Lock Logic: Level/Rank 4 or 8
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return not (c:IsLevel(4,8) or c:IsRank(4,8))
end

-- Effect (3)

-- Target filter: Face-up "Stella-Regis" or "Therion" monster
function s.eqfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x1908) or c:IsSetCard(0x17B))
end

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    -- This ensures you can ONLY target the specific archetypes
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
    
    -- Check for S/Z space and a valid target on activation
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
        
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    -- Standard check: is the monster still there and is this card still in GY?
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
        if Duel.Equip(tp,c,tc) then
            -- Equip limit: This prevents the card from being equipped to anything else
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_EQUIP_LIMIT)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetValue(s.eqlimit)
            c:RegisterEffect(e1)
            -- ATK boost
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_EQUIP)
            e2:SetCode(EFFECT_UPDATE_DEFENSE)
            e2:SetValue(500)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e2)
        end
    end
end

-- This value function must return true for the target to be valid for the Equip Limit
function s.eqlimit(e,c)
    return c:IsSetCard(0x1908) or c:IsSetCard(0x17B)
end