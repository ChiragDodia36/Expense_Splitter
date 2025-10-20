# 💰 Expense Splitter

A modern, intuitive Flutter application for splitting expenses among groups of friends, roommates, or travel companions. Track who paid for what, calculate balances, and settle debts effortlessly.

## 🎯 MVP Features

### Core Functionality

- **Group Management**
  - Create multiple expense groups for different occasions (trips, shared apartments, events)
  - Add unlimited members to each group
  - View group summary with total expenses and member count

- **Expense Tracking**
  - Add expenses with description, amount, date, and optional category
  - Assign a payer for each expense
  - Split expenses equally or with custom amounts among selected members
  - Edit or delete existing expenses

- **Smart Balance Calculation**
  - Automatic calculation of who owes whom
  - Real-time balance updates as expenses are added
  - View individual balances within each group
  - Overall balance view across all groups

- **Settlement System**
  - Optimized payment suggestions to minimize transactions
  - Clear visualization of required payments
  - Mark payments as settled
  - Track settlement history

- **Export & Share**
  - Generate PDF reports of group expenses
  - Share expense summaries with group members
  - Complete transaction history

### User Experience

- **Modern UI/UX**
  - Clean, intuitive Material Design interface
  - Light and Dark theme support (follows system preference)
  - Smooth animations and transitions
  - Empty states with helpful guidance

- **Data Persistence**
  - Local storage using Hive database
  - All data saved on device
  - No internet required
  - Fast and offline-first

## 🛠️ Technology Stack

- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Local Database:** Hive
- **PDF Generation:** pdf, printing packages
- **Sharing:** share_plus
- **Date Formatting:** intl

## 📱 Screenshots

### Home Screen
<!-- Add your home screen screenshot here -->
<p align="center">
  
</p>

### Group Details
<!-- Add your group details screenshot here -->
<p align="center">
<img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/c27f3d94-b856-4a13-b6c8-b9c435fc39b7" />
</p>
<p align="center">
<img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/5d473780-794c-4ef2-9e15-a16df3f4cf82" />
</p>

### Add Expense
<!-- Add your add expense screenshot here -->
<p align="center">
<img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/6c544c33-0361-4264-b08a-428170d9870b" />
</p>

### Balance Summary
<!-- Add your balance summary screenshot here -->
<p align="center">
<img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/e1f3dd73-2c8d-428a-a3e6-c21683f88950" />
</p>

### Settlement View
<!-- Add your settlement view screenshot here -->
<p align="center">
<img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/8ca08b50-426d-45d3-8e21-f52e296b0691" />
</p>

### Overall Balance
<!-- Add your overall balance screenshot here -->
<p align="center">
<img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/0ac65d70-5155-403f-869c-2a350a3482cf" />
</p>

### Pdf Version of the Split Group
<p alig="center">
  <img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/fd13b4ad-5513-4e48-b6a3-10ceae87b8c4" />
</p>

> **Note:** To add screenshots, create a `screenshots` folder in the root directory and place your images there. Update the image paths accordingly.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.9.2)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended IDEs)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/expense_splitter.git
   cd expense_splitter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (Expense, Group, Member, etc.)
├── providers/                # State management
├── repositories/             # Data layer
├── screens/                  # UI screens
├── services/                 # Business logic services
├── theme/                    # App theming
├── utils/                    # Utility functions
└── widgets/                  # Reusable widgets
```

## 🎨 Features in Detail

### Group Creation
Create groups for any expense-sharing scenario:
- Trips and vacations
- Shared apartments or houses
- Dinner parties and events
- Office lunches
- Project expenses

### Flexible Expense Splitting
- **Equal Split:** Divide expenses equally among all members
- **Custom Split:** Assign specific amounts to different members
- **Unequal Distribution:** Handle cases where someone owes more or less

### Smart Settlement Algorithm
The app uses an optimized algorithm to minimize the number of transactions needed to settle all debts within a group.

### Export Reports
Generate professional PDF reports containing:
- Group information
- All expenses with dates and amounts
- Balance summary
- Settlement payments

## 🔮 Future Enhancements

- [ ] Cloud sync and backup
- [ ] Multi-currency support
- [ ] Receipt scanning with OCR
- [ ] Push notifications for settlements
- [ ] Group chat integration
- [ ] Recurring expenses
- [ ] Expense categories and analytics
- [ ] Budget limits per group

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Developer

**Chirag Dodia**

- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter community for excellent packages
- Material Design for UI/UX guidelines

---

Made with ❤️ using Flutter
