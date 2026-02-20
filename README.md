# Custom Yu-Gi-Oh!

Welcome to the official repository for the **Custom Yu-Gi-Oh! Card**. Designed for use in the **EDOPro** simulator.

---

## 🛠️ How to Add to EDOPro

To use these cards in your EDOPro client, follow these steps to link this repository:

1. **Locate your EDOPro folder**: Open the main directory where your EDOPro executable is located.
2. **Open the Config folder**: Navigate to `config`.
3. **Edit user_configs.json**: Open the `user_configs.json` file with a text editor (like Notepad++ or VS Code).
4. **Update the Repos Array**: Find the `"repos": [` section and paste the following block inside the square brackets:

```json
{
  "url": "https://github.com/Danang-Bahtiar/YGO-StellaRegis",
  "repo_name": "Dan-Archetype",
  "repo_path": "./repositories/DanKoyuki",
  "has_core": false,
  "data_path": "database",
  "script_path": "cus-script",
  "should_update": true,
  "should_read": true
}
```

5. **Update strings.conf (Only if Strings not loaded)**: Open the `strings.conf` file in the same directory with a text editior.
6. **Add the following to the last line of the file**:
   
```json
!setname 0x1908 Stella-Regis
!setname 0x0504 Krios-Verna
!setname 0x2412 Astral Colosseum
```

# Archetype Database

<details>
<summary><b>✨ [ARCHETYPE] Stella-Regis (Xyz)</b> (Click to Expand)</summary>

<br>

> *A custom archetype themed around the Leo constellation and Therion "King" Regulus.*

---

### 📂 Main Deck Monsters

> - *All Level 4 Monster can be special summoned while controlling no monster or only Machine-type Monster*
> - *All Level 4 Monster can only be special summoned by their own effect once per turn*
> - *After using Level 4 `On Summon` Effect, lock Special Summon except Level/Rank 4/8 monster*
> - *All Level 8 Monster can be Special Summoned while Controlling "Therion "King" Regulus" or "Stella-Regis" Xyz Monster from either GY or Hand.*
> - *All Level 8 Monster can be Discarded to do certain effect.*
> - *After using Level 8 `Discard Effect`, lock Special Summon except Xyz monster.*
> - *All monsters effect is Hard once per turn.*
> - *All monsters can target 1 "Stella-Regis" or "Therion" monster on field to equip themselves to the target and grant the equipped monster certain effect (only to "Stella-Regis" or "Therion" monster).*

<details>
<summary>🦁 <b>Stella-Regis "Strike" Subra</b> (Level 4)</summary>

**Level 4 | EARTH | Machine | Effect**

**ATK 1700 / DEF 1300**
- **On Summon Effect** (Select 1): 
  - Add 1 Level 4 Stella-Regis monster from Deck to Hand.
  - If controlling another Machine-type monster, Target 1 Monster on Opponent's field return it to hand and if you do, Draw 1 card.
- **Granted Effect**:
  - Give Piercing Damage.
  - Once per turn, Return 1 "Stella-Regis" card on the field to hand; Special Summon 1 "Stella-Regis" monster from your hand in defense position.
</details>

<details>
<summary>🦁 <b>Stella-Regis "Scout" Algenubi</b> (Level 4)</summary>

**Level 4 | EARTH | Machine | Effect**

**ATK 1300 / DEF 1700**

- **On Summon Effect** (Select 1): 
  - Set 1 Stella-Regis Spell/Trap from Deck to Field.
  - If controlling another Machine-type monster, Target 1 Spell/Trap on Opponent's field return it to hand and if you do, Draw 1 card.
- **Granted Effect**:
  - Give Piercing Damage.
  - Once per turn, Return 1 "Stella-Regis" card in the GY to Deck; Draw 1 card.
</details>

<details>
<summary>🦁 <b>Stella-Regis "Courier" Algeliache</b> (Level 4)</summary>

**Level 4 | EARTH | Machine | Effect**

**ATK 1000 / DEF 1800**

- **On Summon Effect** (Select 1): 
  - Add 1 Stella-Regis Spell/Trap from Deck to hand.
  - If controlling another Machine-type monster, Draw 2 and discard 1.
- **Granted Effect**:
  - Give Second Attack.
  - Once per turn, Return "Stella-Regis" card on field up to "Stella-Regis" monster equipped to a card; Banish equal number of cards from your opponent's GY.
</details>

<details>
<summary>🦁 <b>Stella-Regis "Page" Rasalas</b> (Level 4)</summary>

**Level 4 | EARTH | Machine | Effect**

**ATK 500 / DEF 2000**

- **On Summon Effect** (Select 1): 
  - Special Summon 1 Stella-Regis Monster from Deck.
  - If controlling another Machine-type monster, Special Summon from GY or hand then excavate 3 cards from top deck and Add 1 "Stella-Regis" card to hand then shuffle the rest back to the Deck.
- **Granted Effect**:
  - Card in your GY cannot be banished by Opponent.
  - Once per turn, Reveal 3 "Stella-Regis" card from your deck; Your opponent select 1 to be add to your hand and sent the rest to GY.
</details>

<details>
<summary>🦁 <b>Stella-Regis "Throne" Denebola</b> (Level 8)</summary>

**Level 8 | LIGHT | Machine | Effect**

**ATK 2400 / DEF 1700**

- **Discard Effect**: Add 1 "Stella-Regis" or "Therion" Spell/Trap from Deck to Hand.
- **Granted Effect**:
  - Cannot be Destroyed by Effect.
  - Once per turn, If opponent active card or effect; detach 1 material or send 1 Equipped card to GY, Negate the effects.
</details>

<details>
<summary>🦁 <b>Stella-Regis "Crown" Algieba</b> (Level 8)</summary>

**Level 8 | LIGHT | Machine | Effect**

**ATK 1600 / DEF 2200**

- **Discard Effect**: Add 1 "Stella-Regis" or "Therion" Monster from Deck to Hand.
- **Granted Effect**:
  - Cannot be used as Material for any Summon and Cannot be Tributed.
  - Once per turn, If opponent active card or effect; detach 1 material or send 1 Equipped card to GY, Destroy 1 card on your opponent field.
</details>

---

### 💠 Extra Deck Monsters

> - *All Rank 4 Monster has Special Summon Condition if the Main Deck version is on field (i.e. "Courier" Algeliache is Main Deck version of "Herald" Algeliache).*
> - *All Rank 4 Monster has `Return from GY to Extra Deck` effect to do action.*
> - *All Extra Deck monster can only be summoned once per turn.*
> - *All Effect is Hard once per turn. except Regulus.*

<details>
<summary>👑 <b>Stella-Regis "Sovereign" Regulus</b> (Rank 8)</summary>

**Rank 8 | LIGHT | Machine | Xyz | Effect**
**ATK 3500 / DEF 3000**

* **Materials:** 3 or more Level 8 monsters.
* **Special Conditio:** Therion "King" Regulus on field (Xyz Change)
* **(1)** Unaffected by opponent's card effects if it has Therion "King" Regulus as material.
* **(2) Quick Effect:** 
  * Detach/Send Equip to declare a card type (Spell/Trap/Monster) (Can declare 2 if have Therion "King" Regulus as material by detaching 2 Materials). Apply 1 of the following:
    * Opponent cannot add the declared type to hand from Deck or GY.
    * Opponent cannot active the declared type in GY
    * Your "Stella-Regis" and "Therion" cards are unaffected by effects of the declared type(s) activated by your opponent.
* **(3) Penalty**: If destroyed by **Battle**, you cannot Special Summon or activate monster effects until the end of your next turn.
</details>

<details>
<summary>⚔️ <b>Stella-Regis "Herald" Algeliache</b> (Rank 4)</summary>

**Rank 4 | LIGHT | Machine | Xyz | Effect**

**ATK 1500 / DEF 1800**

* **Materials:** 2 Level 4 Stella-Regis monster.
* **Special Condition:** other monsters on your field can be treated as Level 4 "Stella-Regis".
* **(1) Quick Effect:** Rank-Up into a Rank 8 LIGHT Xyz during Main Phase. However, return it back to Extra Deck during End Phase.
* **(2) Return from GY to Extra Deck:** Shuffle 1 "Stella-Regis" card from your GY to your Deck, then Special Summon 1 "Stella-Regis "Courier" Algeliache" from your deck but negate it's effect
</details>

<details>
<summary>⚔️ <b>Stella-Regis "Infiltrator" Algenubi</b> (Rank 4)</summary>

**Rank 4 | LIGHT | Machine | Xyz | Effect**

**ATK 1800 / DEF 2000**

* **Materials:** 2+ Level 4 monster.
* **Special Condition:** Can use 1 opponent's level 4 or lower monster as material.
* **(1) Summon:** Opponent reveals hand.
* **(2) End Phase:** Discard random card from opponent.
* **(3) GY Effect:** Shuffle 2 "Stella-Regis" card from your GY to your Deck and if you do, banish 1 random card from your opponent's hand or Extra Deck face down.
</details>

<details>
<summary>⚔️ <b>Stella-Regis "Paladin" Subra</b> (Rank 4)</summary>

**Rank 4 | LIGHT | Machine | Xyz | Effect**

**ATK 2500 / DEF 2000**

* **Materials:** 2+ Level 4 monster.
* **Special Condition:** Can use a monster in hand as material.
* **(1) Detach 1 Material:** Change all monsters on field to Level 4.
* **(2) If Battles with Level 4 or higher monster:** Detach 1 Material; Double ATK during Damage Calculation.
* **(3) Return from GY to Extra Deck (Quick Effect):** Banish a monster to buff an Xyz monster's ATK (1000 per level/rank). If targeting "Stella-Regis "Sovereign" Regulus", cannot be negated.
</details>

---

### 📜 Spells & Traps

<details>
<summary>🏟️ <b>Astral Colosseum - Leo's Sanctuary</b> (Field Spell)</summary>

* **(1) If Control "King" or "Sovereign":** Spell/Trap protection.
* **(2)** Everything becomes Machine.
* **(3) If a card is destroyed:** Attach it to Xyz OR add "Stella-Regis"/"Therion" from GY/Banishment to hand.
* **(4) Battle Phase (Quick Effect):** Banish 1 "Stella-Regis" card from your GY; Until the end of this turn, neither players can active card or effect during a battle that involve a "Stella-Regis" monster.
</details>

<details>
<summary>🚫 <b>Void's of the Lion</b> (Counter Trap)</summary>

* Force Attack: While you control "Sovereign", force opponent into Battle Phase and force them to attack "Sovereign" using original ATK/DEF. All Monsters become unaffected by other effects.
</details>

<details>
<summary>🌀 <b>Rounds of The Stella-Regis</b> (Normal Spell)</summary>

* Archetype Searcher: Discard 1, add 1 "Stella-Regis" and mill 1. (Locked into "Stella-Regis" Extra Deck).
</details>

</details>

<details>
<summary><b>🌱 [ARCHETYPE] Krios-Verna (Synchro)</b> (Click to Expand) </summary>

<br>

> *A custom archetype themed around the Aries constellation and Therion "Lily" Borea.*

### 📂 Main Deck Monsters

### 💠 Extra Deck Monsters

>



### 📜 Spells & Traps

<details>
<summary>🏟️ <b>Astral Colosseum - Aries' Arboretum</b> (Field Spell)</summary>

* **(1) If Control "Lily" or "Heliotrope":** +400 ATK for each Plant-monster on field.
* **(2)** Everything becomes Plant.
* **(3) If a card is Tributed or used as Synchro Material:** you can add 1 "Krios-Verna" or "Therion" monster from GY or Banishement to your hand or Special Summon 1 "Krios-Verna" monster from your Deck but negate its effect until the end of this turn..
* **(4) Battle Phase (Quick Effect):** Banish 1 "Krios-Verna" monster from your GY; Special Summon 1 "Therion" or "Krios-Verna" monster from your GY, and if you do, you gain LP equal to its original ATK.
</details>

</details>