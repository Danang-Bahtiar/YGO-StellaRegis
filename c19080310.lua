-- Stella-Regis "Void" Wolf 359
-- Level 10 DARK Machine-Type / Effect Monster
-- ATK 3000 / DEF 1500
-- Cannot be Normal Summoned/Set. Must first be Special Summon by its own effect. You can only Special Summon "Stella-Regis "Void" Wolf 359" once per turn.
-- During either player turn (Quick Effect) on chain link 3 or higher, send 1 "Therion "King" Regulus" from Hand or Deck; Special Summon this card from your hand to your Opponent's field and then, activate the following effect depending on whose turn currently is.
-- • Your Opponent's Turn: Destroy all monster on the field, this card gain atk equal to the destroyed monster multiple by 500.
-- • Your Turn: Destroy both player's hand and then both player draw equal to the destroyed card(s).
-- During the End Phase of the turn where this card is Special Summoned, activate one of the following effect:
-- • Send 5 cards from top of your oppponent's deck to graveyard and if you do, give control of this card to your opponent.
-- • Banish 3 cards from top of your deck.

local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Cannot be Normal Summoned/Set
    c:EnableUnsummonable()
    
    -- (1) Special Summon Logic (The Kuriboh LV9 Method)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- (2) End Phase Choice
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.epcon)
    e2:SetTarget(s.eptg)
    e2:SetOperation(s.epop)
    c:RegisterEffect(e2)
end

s.listed_names={10604644} -- King Regulus

-- (1) Condition: Must be Chain Link 2 or higher (Kuriboh LV9 style)
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentChain(true)>=2
end

-- (1) Cost Filter
function s.tgfilter(c)
    return c:IsCode(10604644) and c:IsAbleToGrave()
end

-- (1) Cost: Moved to s.spcost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    -- IMPORTANT: We check MZONE count for 1-tp (the opponent)
    if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,1-tp) end
    
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local x = Duel.SpecialSummon(c,0,tp,1-tp,true,false,POS_FACEUP)
    
    -- Special Summon to Opponent's field
    if x>0 then
        c:RegisterFlagEffect(id+100,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
        Duel.BreakEffect()
        
        -- Effect based on Turn Player
        if Duel.GetTurnPlayer()~=tp then
            -- Opponent's Turn: Monster Nuke
            local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_MZONE,LOCATION_MZONE,c)
            local ct=Duel.Destroy(g,REASON_EFFECT)
            if ct>0 and c:IsFaceup() then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(ct*500)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
                c:RegisterEffect(e1)
            end
        else
            -- Your Turn: Hand Nuke
            local h1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
            local h2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
            local g=h1:Clone()
            g:Merge(h2)
            local ct1=#h1
            local ct2=#h2
            if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
                Duel.BreakEffect()
                if ct1>0 then Duel.Draw(tp,ct1,REASON_EFFECT) end
                if ct2>0 then Duel.Draw(1-tp,ct2,REASON_EFFECT) end
            end
        end
    end
end

-- (2) End Phase Choice (Logic is solid)
function s.epcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id+100)~=0
end
function s.eptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.epop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local p=c:GetControler() 
    local owner=c:GetOwner()
    
    local op=Duel.SelectOption(p,aux.Stringid(id,2),aux.Stringid(id,3))
    
    if op==0 then
        if Duel.DiscardDeck(owner,5,REASON_EFFECT)>0 then
            Duel.GetControl(c,owner)
        end
    else
        local g=Duel.GetDecktopGroup(p,3)
        if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
    end
end