-- Rounds of The Stella-Regis
-- Spell
-- You can only active "Rounds of The Stella-Regis" once per turn.
-- You cannot Special Summon monster(s) from Extra Deck except "Stella-Regis" monster(s), Discard 1 card from your hand; Add 1 "Stella-Regis" monster from your Deck to your hand and sent 1 card from top of your Deck to GY. Also, until your opponent next End Phase, their monster gains Attack equal to their own Original Attack.

local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_LIMIT_OATH)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

s.listed_series={0x1908}

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
    -- Extra Deck Lock (Stella-Regis only)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    -- LUA hint for the lock
    aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2))
end
function s.splimit(e,c,sump,sumty,sumpos,targetp,se)
    return not c:IsSetCard(0x1908) and c:IsLocation(LOCATION_EXTRA)
end

function s.thfilter(c)
    return c:IsSetCard(0x1908) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.IsPlayerCanDiscardDeck(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- 1. Search Stella-Regis
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
        
        -- 2. Send top card to GY
        Duel.BreakEffect()
        Duel.DiscardDeck(tp,1,REASON_EFFECT)
        
        -- 3. Opponent's monsters gain ATK (Lingering)
        local c=e:GetHandler()
        -- Apply to current monsters
        local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
        for tc in aux.Next(og) do
            s.atkup(tc,c,tp)
        end
        -- Lingering effect for newly summoned monsters
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_SUMMON_SUCCESS)
        e2:SetOperation(s.atkop)
        e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
        Duel.RegisterEffect(e2,tp)
        local e3=e2:Clone()
        e3:SetCode(EVENT_SPSUMMON_SUCCESS)
        Duel.RegisterEffect(e3,tp)
    end
end

function s.atkup(tc,c,tp)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(tc:GetBaseAttack())
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
    tc:RegisterEffect(e1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(Card.IsFaceup,nil)
    local tc=g:GetFirst()
    while tc do
        if tc:IsControler(1-tp) then
            s.atkup(tc,e:GetOwner(),tp)
        end
        tc=g:GetNext()
    end
end