# Edit Expense Feature

## Overview
The edit expense feature allows users to modify existing expense details including description, amount, payer, and how the expense is split between participants. This is useful for correcting mistakes or updating expenses when details change.

## How to Access

### Method 1: Quick Edit (Tap)
1. Go to the "Expenses" tab in any group
2. **Tap** on any expense card
3. Edit expense screen opens with pre-filled data

### Method 2: Options Menu (Long Press)
1. Go to the "Expenses" tab in any group
2. **Long press** on any expense card
3. Bottom sheet appears with options:
   - **Edit Expense** - Opens edit screen
   - **Delete Expense** - Permanently removes the expense

## What Can Be Edited

### 1. **Description**
- Update the expense description
- Example: "Dinner" → "Dinner at Italian Restaurant"
- Validation: 2-100 characters required

### 2. **Amount**
- Change the total expense amount
- Automatically recalculates splits if in equal mode
- Validation: Must be > 0 and max 2 decimal places

### 3. **Payer**
- Change who paid for the expense
- Select from group members using choice chips
- Only one payer allowed per expense

### 4. **Split Type**
- Toggle between **Equal** and **Custom** split
- Equal: Amount divided evenly
- Custom: Manually specify each person's share

### 5. **Participants**
- Add or remove people from the expense
- Check/uncheck participants
- For custom splits, enter individual amounts

## Features

### Smart Split Detection
When editing an expense, the app automatically detects whether it was originally split equally or custom:
- If all splits are equal → "Equal" mode selected
- If splits vary → "Custom" mode selected

### Pre-filled Data
All fields are pre-populated with current expense data:
- Description filled in
- Amount shown with 2 decimal places
- Current payer selected
- All participants checked
- Custom amounts shown if applicable

### Real-time Validation

#### Equal Split
- Shows each person's share automatically
- Updates when participants change
- Example: $100 split 3 ways = $33.33 each

#### Custom Split
- Real-time remaining amount calculator
- Green indicator when amounts match total
- Orange warning when amounts don't add up
- Must sum to total expense amount (±1¢ tolerance)

### Balance Update
When an expense is edited:
1. Old expense data is removed from calculations
2. New expense data is applied
3. All balances recalculate automatically
4. Settlement suggestions update if needed

## User Flow Example

### Scenario: Correcting a Mistake
**Original Expense:**
- Description: "Dinner"
- Amount: $80
- Paid by: Alice
- Split equally: Alice, Bob, Carol

**Mistake Found:** The total was actually $90, and David also participated

**Edit Process:**
1. Tap on the expense
2. Update amount: $80 → $90
3. Check "David" to add him
4. Amount auto-splits: $22.50 each (4 people)
5. Tap "Save Changes"
6. ✅ Balances update automatically

### Scenario: Changing from Equal to Custom Split
**Original:**
- $100 split equally (3 people) = $33.33 each

**Change to Custom:**
1. Tap expense to edit
2. Toggle to "Custom" split
3. Enter custom amounts:
   - Alice: $40
   - Bob: $35
   - Carol: $25
4. Remaining shows $0.00 (green ✓)
5. Save changes

## Validation & Error Handling

### Required Fields
- ❌ Description cannot be empty
- ❌ Amount must be valid number > 0
- ❌ At least one payer must be selected
- ❌ At least one participant must be selected

### Custom Split Validation
- ❌ All participant amounts must be filled
- ❌ Amounts must be non-negative
- ❌ Total splits must equal expense amount (±1¢)
- ✅ Real-time feedback with remaining amount indicator

### Success Confirmation
- Green snackbar: "Expense updated successfully!"
- Automatically returns to group detail screen
- Changes immediately visible in expense list
- Balances update instantly

## UI/UX Features

### Visual Feedback
- **Choice Chips** for payer selection with avatars
- **Checkboxes** for participant selection
- **Segmented Button** for equal/custom toggle
- **Color-coded cards** for remaining amount:
  - 🟢 Green: Amounts match perfectly
  - 🟠 Orange: Amounts don't add up
- **Loading indicator** while saving

### Smart Navigation
- Tap expense → Quick edit
- Long press → Options menu (Edit or Delete)
- Back button → Cancel without saving
- Save button → Validates and updates

### Accessibility
- All form fields labeled
- Clear error messages
- Logical tab order
- Touch targets sized appropriately

## Data Persistence

### Database Updates
- Changes saved immediately to Hive database
- Original expense ID preserved
- Timestamp remains from original creation
- All related balances recalculated

### State Management
- Provider notifies all listeners
- UI updates across all tabs
- Settlement suggestions refresh
- Balance cards update automatically

## Technical Details

### Edit vs Add Expense
The edit screen is similar to add expense but:
- Pre-fills all fields with existing data
- Detects original split type
- Preserves expense ID and date
- Uses `updateExpense()` instead of `addExpense()`

### Data Flow
```
User taps expense
  → EditExpenseScreen opens with expense data
  → User makes changes
  → Validation runs
  → Updates Expense object
  → groupProvider.updateExpense()
  → Repository updates in Hive
  → All balances recalculate
  → UI refreshes automatically
```

## Benefits

- ✅ **Fix mistakes easily** - No need to delete and re-add
- ✅ **Maintain history** - Original expense date preserved
- ✅ **Automatic recalculation** - Balances update instantly
- ✅ **Flexible editing** - Change any aspect of the expense
- ✅ **No data loss** - Save as many times as needed
- ✅ **Clear validation** - Know exactly what's wrong

## Future Enhancements

Potential improvements:
- Edit history/audit trail
- Undo last edit
- Duplicate expense feature
- Bulk edit multiple expenses
- Add notes to expenses
- Attach receipts/photos
- Edit date/timestamp

