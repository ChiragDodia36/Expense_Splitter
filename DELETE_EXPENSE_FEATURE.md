# Delete Expense Feature

## Overview
The Delete Expense feature allows users to remove expense records from groups. This is useful for correcting mistakes, removing duplicate entries, or cleaning up old expenses.

## How to Delete an Expense

### Method 1: Popup Menu (Recommended)
1. **Navigate to Group Detail Screen**
   - Open any group from the home screen
   - Go to the "Expenses" tab

2. **Find the Expense to Delete**
   - Scroll through the list of expenses
   - Each expense card shows: description, payer, date, amount, and participant count

3. **Access Delete Option**
   - Look for the **three-dot menu** (⋮) on the right side of each expense card
   - Tap the three-dot menu button

4. **Select Delete**
   - A popup menu will appear with two options:
     - **Edit** (pencil icon) - to modify the expense
     - **Delete** (trash icon, red) - to remove the expense
   - Tap "Delete"

5. **Confirm Deletion**
   - A confirmation dialog will appear
   - Shows the expense description: "Are you sure you want to delete '[Expense Name]'?"
   - Tap "Delete" to confirm or "Cancel" to abort

6. **Success**
   - The expense is removed from the group
   - A success message appears: "Expense deleted"
   - The expense list updates automatically
   - All balances are recalculated

### Method 2: Long Press (Alternative)
1. **Long Press on Expense Card**
   - Press and hold on any expense card for about 1 second
   - A bottom sheet will appear with options

2. **Select Delete**
   - Choose "Delete Expense" from the bottom sheet
   - Confirm the deletion in the dialog

## Visual Indicators

### Expense Card Layout
```
┌─────────────────────────────────────────┐
│ 🍕 Pizza Night                    $45.00 │
│ Paid by John                          ⋮  │
│ 2 hours ago • 4 people                 │
└─────────────────────────────────────────┘
```

- **Three-dot menu (⋮)**: Located on the right side, clearly visible
- **Styled button**: Has a subtle background to make it more obvious
- **Red delete option**: Clearly marked in red to indicate destructive action

### Confirmation Dialog
```
┌─────────────────────────────────────────┐
│ Delete Expense?                         │
│                                         │
│ Are you sure you want to delete        │
│ "Pizza Night"?                          │
│                                         │
│ [Cancel]              [Delete]          │
└─────────────────────────────────────────┘
```

## What Happens When You Delete

### Immediate Effects
1. **Expense Removed**: The expense disappears from the list
2. **Balances Updated**: All member balances are recalculated
3. **Settlements Updated**: Settlement suggestions are refreshed
4. **UI Refreshed**: All screens update to reflect the change

### Data Impact
- **Permanent Deletion**: The expense is permanently removed from the database
- **No Recovery**: Deleted expenses cannot be restored (consider this carefully)
- **Balance Recalculation**: All financial calculations are updated automatically

## Safety Features

### Confirmation Required
- **Double Confirmation**: Both popup menu selection AND dialog confirmation
- **Clear Messaging**: Shows exactly which expense will be deleted
- **Cancel Option**: Easy to abort the operation

### Visual Warnings
- **Red Color**: Delete option is clearly marked in red
- **Trash Icon**: Universal delete symbol
- **Destructive Action**: Clearly indicated as a permanent action

## Use Cases

### Common Scenarios
1. **Mistake Correction**: Accidentally added wrong expense
2. **Duplicate Removal**: Same expense added twice
3. **Data Cleanup**: Remove old or irrelevant expenses
4. **Group Management**: Clean up before archiving a group

### Examples
- **Wrong Amount**: Added $50 instead of $15
- **Wrong Payer**: Selected wrong person as payer
- **Wrong Participants**: Included people who didn't participate
- **Test Data**: Remove test expenses from real groups

## Technical Details

### Implementation
- **Repository Layer**: `GroupRepository.deleteExpense()`
- **Provider Layer**: `GroupProvider.deleteExpense()`
- **UI Layer**: Popup menu with confirmation dialog
- **Database**: Hive local storage update

### Data Flow
1. User taps delete option
2. Confirmation dialog appears
3. User confirms deletion
4. Provider calls repository
5. Repository removes from Hive
6. Provider notifies listeners
7. UI updates automatically

### Error Handling
- **Group Not Found**: Gracefully handles missing groups
- **Expense Not Found**: Handles missing expenses
- **Database Errors**: Shows user-friendly error messages
- **Network Issues**: Works offline (local storage)

## Best Practices

### Before Deleting
1. **Verify the Expense**: Make sure you're deleting the right one
2. **Check Dependencies**: Consider if other data depends on this expense
3. **Backup Important Data**: Export group data if needed
4. **Communicate**: Let group members know about the deletion

### After Deleting
1. **Verify Balances**: Check that balances look correct
2. **Update Settlements**: Review settlement suggestions
3. **Inform Group**: Let others know about the change
4. **Document**: Keep track of why the expense was deleted

## Troubleshooting

### Common Issues

**"Delete option not visible"**
- Make sure you're looking for the three-dot menu (⋮) on the right side
- Try long-pressing the expense card as an alternative

**"Confirmation dialog not appearing"**
- Check that you tapped "Delete" in the popup menu
- Make sure the dialog isn't hidden behind other UI elements

**"Expense still showing after deletion"**
- Try refreshing the screen (pull down to refresh)
- Check if there was an error during deletion

**"Balances look wrong after deletion"**
- The app automatically recalculates balances
- If balances seem incorrect, check if other expenses are correct
- Consider adding the expense back and editing it instead

### Error Messages
- **"Group not found"**: The group may have been deleted
- **"Expense not found"**: The expense may have already been deleted
- **"Failed to delete expense"**: Database error, try again

## Future Enhancements

Potential improvements:
- **Bulk Delete**: Delete multiple expenses at once
- **Undo Feature**: Temporary undo for accidental deletions
- **Delete History**: Track what was deleted and when
- **Soft Delete**: Mark as deleted instead of permanent removal
- **Admin Controls**: Only group creator can delete expenses
- **Delete Reasons**: Require reason for deletion
- **Export Before Delete**: Automatic backup before deletion

## Summary

The Delete Expense feature provides a safe and intuitive way to remove expense records:

✅ **Easy Access** - Three-dot menu on each expense card  
✅ **Clear Confirmation** - Double confirmation prevents accidents  
✅ **Visual Indicators** - Red color and trash icon clearly indicate deletion  
✅ **Automatic Updates** - All balances and settlements update immediately  
✅ **Error Handling** - Graceful handling of edge cases  
✅ **User-Friendly** - Intuitive interface with clear feedback  

This feature helps maintain clean and accurate expense records while preventing accidental data loss through confirmation dialogs and clear visual indicators.
