# Employee Management System

A complete Flutter web-based Employee Management System with Firebase backend support. This application provides full CRUD (Create, Read, Update, Delete) operations for managing employee records with real-time data synchronization using Cloud Firestore.

## Features

- ✅ Full CRUD operations for employee records
- ✅ Real-time data updates using Cloud Firestore streams
- ✅ Admin login (Firebase Auth) required for add/edit/delete actions
- ✅ Material 3 design with clean, admin-style layout
- ✅ Responsive web interface
- ✅ Employee fields: ID, Name, Email, Phone, Department, Position, Salary, and Joined Date
- ✅ Form validation
- ✅ Delete confirmation dialogs
- ✅ Success/error notifications

## Project Structure

```
lib/
├── models/
│   └── employee_model.dart      # Employee data model
├── services/
│   ├── firestore_service.dart   # Firestore CRUD operations
│   └── auth_service.dart        # Firebase Authentication helper
├── pages/
│   ├── home_page.dart           # Main page with employee list
│   ├── add_employee_page.dart   # Add new employee page
│   ├── edit_employee_page.dart  # Edit existing employee page
│   └── login_page.dart          # Admin login page
├── widgets/
│   ├── employee_card.dart       # Employee card widget
│   └── employee_form.dart       # Reusable employee form widget
├── firebase_options.dart        # Firebase configuration
└── main.dart                    # App entry point
```

## Prerequisites

- Flutter SDK (3.9.2 or higher)
- Firebase account
- Firebase project set up

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Setup

#### Option A: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase for your project:
```bash
flutterfire configure
```

This will automatically generate the `firebase_options.dart` file with your Firebase project credentials.

#### Option B: Manual Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Enable Cloud Firestore Database:
   - Go to Firestore Database
   - Click "Create database"
   - Start in test mode (for development)
   - Select a location
4. Get your Firebase web configuration:
   - Go to Project Settings
   - Scroll down to "Your apps"
   - Click the web icon (`</>`) to add a web app
   - Copy the Firebase configuration object
5. Update `lib/firebase_options.dart` with your Firebase credentials:
   - Replace `YOUR_WEB_API_KEY` with your actual API key
   - Replace `YOUR_WEB_APP_ID` with your actual App ID
   - Replace `YOUR_MESSAGING_SENDER_ID` with your actual Sender ID
   - Replace `YOUR_PROJECT_ID` with your actual Project ID

### 3. Enable Firebase Authentication

1. In the Firebase console, open **Authentication** and click **Get started**.
2. Enable the **Email/Password** sign-in provider.
3. Add one or more admin users (email + password) to manage employees inside the app.

### 4. Firestore Security Rules (Development)

For development, you can use these rules in Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /employees/{document=**} {
      allow read, write: if true; // For development only
    }
  }
}
```

**⚠️ Important:** For production, implement proper authentication and security rules.

### 5. Run the Application

For web:
```bash
flutter run -d chrome
```

Or build for web:
```bash
flutter build web
```

## Usage

1. **View Employees**: Everyone can browse the home page list without logging in.
2. **Log In**: Click the **Admin Login** button (top-right) and sign in with a Firebase Authentication user.
3. **Add Employee**: Once logged in, click the floating **Add Employee** button to create a record.
4. **Edit Employee**: Use the edit icon on a card while signed in to modify information.
5. **Delete Employee**: Use the delete icon (and confirm) while signed in to remove a record.

## Authentication

- The interface is open for read-only access; mutations require a valid Firebase Authentication session.
- Only signed-in admins can add, edit, or delete employees. Visitors see disabled actions with tooltips indicating login is required.
- Manage admin accounts from **Firebase Console → Authentication → Users**.

## Employee Model

Each employee record contains:
- **ID**: Unique identifier (auto-generated)
- **Name**: Employee's full name
- **Email**: Email address
- **Phone**: Phone number
- **Department**: Department name
- **Position**: Job position/title
- **Salary**: Annual salary (numeric)
- **Joined Date**: Date when employee joined the company

## Technologies Used

- **Flutter**: UI framework
- **Firebase Core**: Firebase initialization
- **Cloud Firestore**: Real-time database
- **Material 3**: Modern design system
- **Intl**: Date and number formatting

## Dependencies

- `firebase_core: ^4.2.1`
- `firebase_auth: ^5.3.1`
- `cloud_firestore: ^6.1.0`
- `intl: ^0.20.2`

## Notes

- The app uses real-time streams, so any changes in Firestore will automatically update the UI
- All form fields are validated before submission
- Employee IDs are auto-generated using timestamps
- When not logged in, the UI is read-only (no floating action button and disabled edit/delete buttons)
- The app is optimized for web but can be adapted for mobile platforms

## Troubleshooting

### Firebase Initialization Error
- Ensure `firebase_options.dart` is properly configured with your Firebase credentials
- Verify that Firebase is enabled for web in your Firebase project settings

### Firestore Permission Denied
- Check your Firestore security rules
- Ensure the database is created and initialized

### Build Errors
- Run `flutter clean` and then `flutter pub get`
- Ensure all dependencies are compatible with your Flutter SDK version

## License

This project is open source and available for use.
