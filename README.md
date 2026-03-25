#DB
#  Fantasy Heroes Battle System

##  Description
This project is a simple Object-Oriented Programming (OOP) system in Python that simulates a fantasy battle between heroes and monsters.

The goal of the project is to demonstrate:
- class design
- inheritance
- encapsulation
- method overriding
- interaction between objects

---

##  Project Structure
fantasy_game/
│
├── character.py # Base class
├── heroes.py # Warrior, Mage
├── monster.py # Goblin
├── items.py # Items system
├── main.py # Battle simulation
└── README.md

---

##  Implemented Classes

###  Character (Base Class)
- name
- health
- attack_power
- inventory

Methods:
- `attack(target)`
- `take_damage(amount)`
- `is_alive()`
- `use_item()`

---

###  Warrior
- Higher health
- Has armor (reduces incoming damage)

---

###  Mage
- Uses mana
- Can deal double damage with spells

---

###  Goblin (Monster)
- Has a chance to dodge attacks

---

###  Items
- **HealthPotion** → restores HP
- **Sword** → increases attack power

---

##  Inventory System
- Characters can store items
- Items can be used by name
- Items affect character stats

---

## ▶️ How to Run

```bash
python main.py
