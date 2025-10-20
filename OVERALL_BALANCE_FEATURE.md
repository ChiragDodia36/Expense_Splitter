# Overall Balance Feature (Like Splitwise)

## Overview
The Overall Balance feature provides a comprehensive view of all money owed and owed to you across ALL groups, not just within individual groups. This is similar to Splitwise's main dashboard where you can see your total financial position with all friends regardless of which groups they're in.

## Access the Feature

### From Home Screen
- Tap the **wallet icon** (💰) in the top-right corner of the Home Screen
- Opens the "Overall Balance" screen

## What You'll See

### 1. **User Name Input**
At the top, enter your name as it appears across all groups:
- Default: "Me"
- Must match your name in groups exactly
- Tap refresh icon to recalculate
- The system uses this to identify you across all groups

### 2. **Summary Cards**

#### You Owe (Red Card)
- Total amount you owe to all people across all groups
- Shows the sum of all negative balances

#### Owed to You (Green Card)
- Total amount owed to you by all people across all groups
- Shows the sum of all positive balances

#### Net Balance (Large Card)
- Your overall position: `Owed to You - You Owe`
- 🟢 Green with ⬇️: You're getting money back (positive)
- 🟠 Orange with ⬆️: You need to pay money (negative)

### 3. **People List**

Shows everyone you have financial interactions with across all groups:

**For each person:**
- Name and avatar
- Total amount owed/owing
- Expandable to see group-by-group breakdown
- Color-coded:
  - 🟢 Green (⬇️): They owe you money
  - 🔴 Red (⬆️): You owe them money

**Expand a person to see:**
- Which groups you share with them
- Individual balance in each group
- Breakdown of where the debt comes from

## Example Scenarios

### Scenario 1: Simple Case

**Groups:**
1. "Trip to NYC" - You, Alice, Bob
2. "Dinner Group" - You, Alice, Carol

**Expenses:**
- NYC Trip: Alice paid $300, split 3 ways → You owe Alice $100
- Dinner: You paid $90, split 3 ways → Alice owes you $30, Carol owes you $30

**Overall Balance Screen Shows:**
```
You Owe: $70           (to Alice: $100 - $30 = $70)
Owed to You: $30       (from Carol: $30)
Net Balance: -$40      (You need to pay $40 overall)

People:
├─ Alice: You owe $70
│  ├─ Trip to NYC: $100 (you owe)
│  └─ Dinner Group: $30 (owes you)
└─ Carol: Owes you $30
   └─ Dinner Group: $30 (owes you)
```

### Scenario 2: Complex Multi-Group

**Groups:**
1. "Roommates" - You, Alice, Bob
2. "Weekend Trip" - You, Alice, Carol
3. "Office Lunch" - You, Bob, David

**After various expenses:**

**Overall Balance might show:**
```
You Owe: $125
Owed to You: $200
Net Balance: +$75 ✓ (You get back $75)

People (sorted by amount):
├─ Alice: Owes you $120
│  ├─ Roommates: $50
│  └─ Weekend Trip: $70
├─ Carol: Owes you $80
│  └─ Weekend Trip: $80
├─ Bob: You owe $45
│  ├─ Roommates: -$20 (owes you)
│  └─ Office Lunch: -$65 (you owe)
└─ David: You owe $80
   └─ Office Lunch: $80
```

## Key Features

### 1. **Cross-Group Aggregation**
- Combines balances from all groups where you appear
- Automatically matches people by name
- Shows net position per person, not per group

### 2. **Intelligent Matching**
- Groups expenses by person name across all groups
- Example: "Alice" in "Trip" + "Alice" in "Dinner" = same person
- No need to manually link accounts

### 3. **Detailed Breakdown**
- Tap any person to expand
- See which groups contribute to their balance
- Understand where each debt comes from

### 4. **Real-time Updates**
- Automatically reflects changes from any group
- Updates when you add/edit expenses
- Updates when settlements are recorded

### 5. **Net Simplification**
- Shows net amount per person across all groups
- Example: If Alice owes you $50 in one group and you owe her $30 in another, shows: "Alice owes you $20"

## How Balances Are Calculated

### Step 1: Calculate Within Each Group
For each group, calculate individual balances as normal:
```
Balance = Total Paid - Total Share
```

### Step 2: Aggregate by Person
Sum up balances for each person across all groups:
```
Alice's Total = Alice's balance in Group1 + Alice's balance in Group2 + ...
```

### Step 3: Show Net Position
From your perspective:
- Positive balance → They owe you
- Negative balance → You owe them

### Step 4: Account for Settlements
Settlement payments are already factored into group balances, so overall balance automatically reflects them.

## Benefits

### 1. **Single Source of Truth**
- See all your money in one place
- No need to check multiple groups
- Quick answer to "Who owes me money?"

### 2. **Simplified View**
- Net positions instead of separate group balances
- Reduces mental overhead
- Clear action items (who to pay/collect from)

### 3. **Cross-Group Clarity**
- Understand total relationship with each person
- See if someone owes you in one group but you owe them in another
- Make informed settlement decisions

### 4. **Quick Assessment**
- Three numbers tell the whole story:
  - How much you owe total
  - How much is owed to you total
  - Your net position

## Use Cases

### Use Case 1: Regular Roommates
**Scenario:** Share multiple ongoing expenses
- Rent, utilities, groceries in different groups
- Overall balance shows net position
- Settle up once instead of per-group

### Use Case 2: Travel Friends
**Scenario:** Go on multiple trips
- Each trip is a separate group
- Overall balance shows total across all trips
- Clear view of total relationship

### Use Case 3: Mixed Social Circles
**Scenario:** Friend appears in multiple contexts
- Colleague in "Office Lunch" group
- Friend in "Weekend Activities" group
- Overall balance combines both

### Use Case 4: Financial Planning
**Scenario:** Need to know total exposure
- Before payday, check total owed
- Budget for upcoming settlements
- Track overall financial health

## Tips for Best Results

### 1. **Consistent Naming**
Use the same name across all groups:
- ✅ "Alice" in all groups
- ❌ "Alice", "Alice Smith", "A. Smith" (treated as different people)

### 2. **Regular Updates**
- Enter expenses promptly
- Record settlements when they happen
- Keep groups up to date

### 3. **Review Periodically**
- Check overall balance before settling up
- Use group breakdown to understand sources
- Settle cross-group debts efficiently

### 4. **Communicate**
- Share overall balance screen with friends
- Discuss cross-group settlements
- Agree on total amounts before payment

## Comparison with Individual Groups

### Individual Group View
- Shows balances within one specific group
- Good for: Group-specific expenses
- Best for: Single-context relationships

### Overall Balance View
- Shows balances across ALL groups
- Good for: Total financial picture
- Best for: Multi-context relationships

## Technical Notes

### Person Identification
- People are matched by exact name
- Case-sensitive matching
- Future: Could add email/phone matching for better accuracy

### Performance
- Calculations run on-demand
- Fast even with many groups
- All data stored locally (no server needed)

### Data Privacy
- All calculations client-side
- No data sent to servers
- Your financial data stays on your device

## Future Enhancements

Potential improvements:
- Link people across groups by email/phone
- Cross-group settlement recording
- Overall balance history/trends
- Push notifications for balances
- Quick settle-up actions from overall view
- Filter by person or time period
- Export overall balance report

## Summary

The Overall Balance feature gives you a **Splitwise-like** experience where you can:

✅ See total amounts owed/owing across all groups  
✅ View net position per person  
✅ Understand group-by-group breakdown  
✅ Track overall financial health  
✅ Make informed settlement decisions  

This transforms the app from group-focused to person-focused, making it much easier to manage finances with friends across multiple contexts!

