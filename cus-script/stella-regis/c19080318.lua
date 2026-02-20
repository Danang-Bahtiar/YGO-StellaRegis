-- Stella-Regis "Paladin" Subra
-- Rank 4 LIGHT Machine-Type / Xyz Effect Monster
-- ATK 2500 / DEF 2000
-- 2+ Level 4 monsters
-- You can only Special Summon card with this name once per turn.
-- If you use "Stella-Regis "Strike" Subra" as material, you can use one monster in your Hand as one of material for this card Xyz Summon.
-- You can only use the (1)st and (3)rd effect of this card once per turn.
-- (1) During the Main Phase, you can detach 1 material from this card; until the end of your opponent's next turn, the Level of all face-up monsters currently on the field becomes 4, also any monster Summoned to the field until the end of your opponent's next turn becomes Level 4.
-- (2) If this card battles a level 4 or higher monster (Quick Effect), you can detach 1 material from this card; Double this card Attack during the damage calculation only.
-- (3) During either player turn, if this card is in GY (Quick Effect): return this card to your Extra Deck and Target 1 Xyz Monster you control; Banish 1 "Stella-Regis" monster from your GY, and if you do, for each Level/Rank of the banished monster, the Targeted monster gains 1000 ATK. This effect cannot be negated if you target "Stella-Regis "Sovereign" Regulus".

local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon Procedure
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
    Xyz.AddProcedure(c,nil,4,2,nil,nil,Xyz.InfiniteMats)
    
    -- Custom Xyz Summon using Hand as Material (Strike Subra synergy)
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

    -- (1) Level 4 Aura
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(Cost.DetachFromSelf(1)) -- Updated to standard Detach logic
    e1:SetOperation(s.lvop)
    c:RegisterEffect(e1)

    -- (2) Battle ATK Double (Quick Effect during Damage Calc)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.atkcon)
    e2:SetCost(Cost.DetachFromSelf(1)) -- Updated to standard Detach logic
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- (3) GY Buff (Regulus Un-negatable)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end

s.listed_names={19080301, 19080309}
s.strike_id = 19080301
s.regulus_id = 19080309

-- Custom Xyz: Use Hand if Strike Subra is on Field
function s.mfilter(c)
    return c:IsLevel(4) and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_HAND))
end
function s.xyzcon(e,c,og,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    -- Verifies Strike Subra is ON THE FIELD specifically
    local mg = Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,s.strike_id),tp,LOCATION_MZONE,0,1,nil)
        and #mg>=2
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
    local mg = Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
    -- Must pick the Strike Subra on the field first
    local g1 = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,s.strike_id),tp,LOCATION_MZONE,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg1 = g1:Select(tp,1,1,nil)
    -- Then pick any other Level 4 from Field or Hand
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg2 = mg:FilterSelect(tp,function(tc) return not sg1:IsContains(tc) end,1,1,nil)
    sg1:Merge(sg2)
    if #sg1==2 then
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
    Duel.ShuffleHand(tp)
end
-- Operation 1: Level Aura
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_LEVEL)
        e1:SetValue(4)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
        tc:RegisterEffect(e1)
    end
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_LEVEL)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
    e2:SetValue(4)
    e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
    Duel.RegisterEffect(e2,tp)
end

-- Operation 2: ATK Double
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsLevelAbove(4)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(c:GetAttack()*2)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
        c:RegisterEffect(e1)
    end
end

-- Operation 3: GY Shuffle & Un-negatable Buff
function s.gyfilter(c)
    return c:IsSetCard(0x1908) and c:IsMonster() and c:IsAbleToRemove()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsType(TYPE_XYZ) end
    if chk==0 then return e:GetHandler():IsAbleToExtra() 
        and Duel.IsExistingTarget(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_XYZ)
        and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_MZONE,0,1,1,nil,TYPE_XYZ)
    if g:GetFirst():IsCode(s.regulus_id) then
        e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE)
    else
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.gyfilter),tp,LOCATION_GRAVE,0,nil):Select(tp,1,1,nil)
        local sc=g:GetFirst()
        if sc and Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)~=0 then
            if tc:IsRelateToEffect(e) and tc:IsFaceup() then
                local lv=sc:GetLevel()
                if lv==0 then lv=sc:GetRank() end
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(lv*1000)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
        end
    end
end