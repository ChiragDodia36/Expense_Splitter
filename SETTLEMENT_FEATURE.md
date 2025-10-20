# Settlement Payment Feature

## Overview
The settlement payment feature allows members to mark settlements as paid and tracks the payment history. This ensures that the balance calculations reflect actual payments made between members.

## How It Works

### 1. **Viewing Settlement Suggestions**
- Navigate to the "Settle Up" tab in any group
- The app shows optimized settlement suggestions (minimized transactions)
- Each suggestion shows who should pay whom and how much

### 2. **Marking a Settlement as Paid**
- Tap the "Mark as Paid" button on any settlement suggestion
- Confirm the payment in the dialog
- The payment is recorded with a timestamp

### 3. **Settlement History**
- All completed payments are shown in the "Settlement History" section
- History displays:
  - Who paid whom
  - Amount paid
  - Date of payment
  - Optional notes
- Long-press any history item to delete it (if recorded by mistake)

### 4. **Updated Balance Calculations**
When a settlement is marked as paid:
- Balances automatically update to reflect the payment
- New settlement suggestions are calculated based on remaining balances
- When all settlements are complete, the app shows "All Settled Up!"

### 5. **PDF Export**
Settlement history is automatically included in PDF exports:
- Shows a table of all completed settlements
- Includes date, payer, receiver, and amount
- Helps maintain records for the group

## Technical Details

### Data Model
```dart
SettlementPayment {
  String id;
  String fromMemberId;  // Who paid
  String toMemberId;    // Who received
  double amount;        // Amount paid
  DateTime paidAt;      // When payment was made
  String? note;         // Optional note
}
```

### Balance Calculation
The balance algorithm now:
1. Calculates balances from all expenses (as before)
2. Adjusts balances for completed settlement payments
3. Returns net balances showing remaining amounts owed

### Database
- Settlement payments are stored in the Group model
- Persisted in Hive database
- Survives app restarts

## User Flow Example

1. **Initial State:**
   - Alice paid $100 for dinner
   - Bob paid $60 for drinks
   - Carol paid $0
   - Split equally (3 people)

2. **Balances:**
   - Alice: +$46.67 (is owed)
   - Bob: +$6.67 (is owed)
   - Carol: -$53.33 (owes)

3. **Settlement Suggestions:**
   - Carol pays Alice $46.67
   - Carol pays Bob $6.67

4. **Mark as Paid:**
   - Carol pays Alice $46.67 → Mark as Paid
   - Balance updates: Alice is now settled, Carol now owes only $6.67

5. **Final Settlement:**
   - Carol pays Bob $6.67 → Mark as Paid
   - All balanced! ✓

## Benefits

- ✅ **Real-time updates**: Balances update immediately when settlements are recorded
- ✅ **History tracking**: Complete audit trail of all payments
- ✅ **Simplified settlements**: Algorithm minimizes number of transactions
- ✅ **No confusion**: Clear record of what has and hasn't been paid
- ✅ **PDF records**: Export includes settlement history for group records

## Future Enhancements

Potential improvements:
- Add optional notes when marking settlements as paid
- Filter/search settlement history
- Undo recent settlements
- Payment method tracking (cash, Venmo, etc.)
- Notifications when settlements are marked as paid

