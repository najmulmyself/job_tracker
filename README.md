# Job Tracker - Flutter Application

A comprehensive Flutter application for tracking job applications with AI integration capabilities.

## 📱 Features

### Phase 1: MVP - Personal Job Tracker ✅

#### ✨ Core Features Implemented:

1. **Authentication**
   - Google Sign-In via Firebase Auth
   - User profile management
   - Secure user data isolation

2. **Job Application Tracking**
   - Complete job entry form with all required fields
   - Auto-save draft functionality
   - Edit and delete applications
   - Track application stages and deadlines

3. **Modern UI**
   - Card-based layout with colorful stage indicators
   - Filter and sort capabilities
   - Dark mode support
   - Animated transitions

4. **Backend & Sync**
   - Firebase Firestore for data storage
   - Firebase Storage for resume PDFs
   - Offline persistence enabled
   - Real-time data synchronization

5. **Notification System**
   - Deadline reminders
   - Draft notifications
   - Local push notifications

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.9.2)
- Firebase account

### Installation

1. Clone and install dependencies:
```bash
flutter pub get
```

2. **Firebase Setup** - See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions

3. Run the app:
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── models/          # Data models
├── screens/         # UI screens
├── widgets/         # Reusable widgets
├── providers/       # State management
├── services/        # Business logic
└── utils/          # Helper utilities
```

For more details, see the full documentation in the project files.
