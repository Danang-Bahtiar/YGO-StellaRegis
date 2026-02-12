-- Stella-Regis "Chancellor" Algieba
-- Rank 8 LIGHT Machine-Type / Effect Xyz Monster
-- ATK 2900 / DEF 1800
-- 2 or more Level 8 monsters
-- You can only Special Summon "Stella-Regis "Chancellor" Algieba" once per turn.
-- You can only use the (1)st, (2)nd and (3)rd effect of "Stella-Regis "Chancellor" Algieba" once per turn.
-- (1) During your turn (Quick Effect): When your opponent active a Spell/Trap card, you can detach 1 material from this card; negate its activation and banish it. You can use this effect during either player turn if "Therion "King" Regulus" or "Stella-Regis "Sovereign" Regulus" is on the field.
-- (2) If "Stella-Regis" or "Therion" card(s) is destroyed by battle or effect, draw 1 card.
-- (3) During your Main Phase: If this card is in your Graveyard: You can return this card to Extra Deck and shuffle 2 "Stella-Regis" and/or "Therion" cards to Deck; add 1 "Stella-Regis" monster and 1 "Stella-Regis" Spell/Trap from Deck or GY to hand.

local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Procedure: 2+ Level 8 monsters
    Xyz.AddProcedure(c,nil,8,2,nil,nil,Xyz.InfiniteMats)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)

    -- (1) Spell/Trap Negation
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.negcon)
    e1:SetCost(Cost.DetachFromSelf(1))
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)

    -- (2) Draw on Destruction
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)

    -- (3) GY Recovery & Search
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,3})
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

s.listed_names={10604644, 19080309} -- King Regulus, Sovereign Regulus

-- (1) Negate Logic
function s.regulus_filter(c)
    return c:IsFaceup() and (c:IsCode(10604644) or c:IsCode(19080309))
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    -- 1. Must be the opponent activating the effect
    if rp==tp then return false end
    
    -- 2. Basic safety and "Can it be negated?" checks
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    if not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)) then return false end
    
    -- 3. Check if it's your turn OR Regulus is on the field (anywhere)
    return Duel.GetTurnPlayer()==tp or Duel.IsExistingMatchingCard(s.regulus_filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
    end
end

-- (2) Draw Logic
function s.drfilter(c,tp)
    return (c:IsSetCard(0x1908) or c:IsSetCard(0x17b))
        and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.drfilter,1,nil,tp)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(p,d,REASON_EFFECT)
end

-- (3) GY Logic
function s.tdfilter(c)
    return (c:IsSetCard(0x1908) or c:IsSetCard(0x17b)) and c:IsAbleToDeck()
end
function s.thmonfilter(c)
    return c:IsSetCard(0x1908) and c:IsMonster() and c:IsAbleToHand()
end
function s.thstfilter(c)
    return c:IsSetCard(0x1908) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToExtra() 
        and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,2,c)
        and Duel.IsExistingMatchingCard(s.thmonfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.thstfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
        if #g==2 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local h1=Duel.SelectMatchingCard(tp,s.thmonfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local h2=Duel.SelectMatchingCard(tp,s.thstfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
            local hg=Group.CreateGroup()
            hg:Merge(h1)
            hg:Merge(h2)
            if #hg==2 then
                Duel.SendtoHand(hg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,hg)
            end
        end
    end
end