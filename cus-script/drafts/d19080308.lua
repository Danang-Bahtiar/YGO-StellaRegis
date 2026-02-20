-- Stella-Regis "Vanguard" Denebola
-- Rank 8 LIGHT Machine-Type / Effect Xyz Monster
-- ATK 2800 / DEF 1600
-- 2 or more Level 8 monsters
-- You can only Special Summon Stella-Regis "Vanguard" Denebola once per turn.
-- You can only use the (1)st and (3)rd effect of Stella-Regis "Vanguard" Denebola once per turn.
-- (1) During your turn (Quick Effect): When your opponent active a monster card or effect, you can detach 1 material from this card; negate its activation or effect and destroy it. You can use this effect during either player turn if "Therion "King" Regulus" or "Stella-Regis "Sovereign" Regulus" is on the field.
-- (2) If "Stella-Regis" or "Therion" card(s) will be destroyed by battle or effect, you can detach one material from Xyz Monster you control on the field instead.
-- (3) During your Main Phase: If this card is in your Graveyard: You can return this card to Extra Deck and shuffe 2 "Stella-Regis" and/or "Therion" cards to Deck; attach 2 cards from the top of your deck to one Xyz monster you control.

local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Procedure: 2+ Level 8 monsters
    Xyz.AddProcedure(c,nil,8,2,nil,nil,Xyz.InfiniteMats)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)

    -- (1) Monster Effect Negation
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
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

    -- (2) Destruction Substitution
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetTarget(s.subtg)
    e2:SetValue(s.subval)
    e2:SetOperation(s.subop)
    c:RegisterEffect(e2)

    -- (3) GY Recovery & Reload
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.attgtg)
    e3:SetOperation(s.attop)
    c:RegisterEffect(e3)
end

s.listed_names={10604644, 19080309}

-- (1) Negate Logic
function s.regulus_filter(c)
    return c:IsFaceup() and (c:IsCode(10604644) or c:IsCode(19080309))
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)

    if rp==tp then return false end

    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    if not (re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)) then return false end
    -- Same logic as Algieba: Your turn OR Regulus is present
    return Duel.GetTurnPlayer()==tp or Duel.IsExistingMatchingCard(s.regulus_filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

-- (2) Substitution Logic
function s.subtg(e,c)
    local tp=e:GetHandlerPlayer()
    return c:IsControler(tp) and c:IsOnField() 
        and (c:IsSetCard(0x1908) or c:IsSetCard(0x17b)) and not c:IsReason(REASON_REPLACE)
end
function s.subval(e,re,r,rp)
    -- Check if any Xyz monster has materials to detach
    return Duel.IsExistingMatchingCard(Card.CheckRemoveOverlayCard,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,e:GetHandlerPlayer(),1,REASON_EFFECT)
end
function s.subop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
    local g=Duel.SelectMatchingCard(tp,Card.CheckRemoveOverlayCard,tp,LOCATION_MZONE,0,1,1,nil,tp,1,REASON_EFFECT)
    if #g>0 then
        g:GetFirst():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
        Duel.Hint(HINT_CARD,0,id)
    end
end

-- (3) GY Logic
function s.tdfilter(c)
    return (c:IsSetCard(0x1908) or c:IsSetCard(0x17b)) and c:IsAbleToDeck()
end
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.attgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToExtra() 
        and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,2,c)
        and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2 end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
        if #g==2 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
            if xyz and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2 then
                local dg=Duel.GetDecktopGroup(tp,2)
                Duel.Overlay(xyz,dg)
            end
        end
    end
end