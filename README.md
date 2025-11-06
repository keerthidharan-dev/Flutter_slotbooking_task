# Flutter Slot Booking App

This Flutter app enables users to select available time slots and confirm bookings with mock payment validation. It uses Firebase Firestore for real-time slot data and booking persistence.

## Features

- Display a list of available booking slots fetched from Firebase Firestore
- Disable booking for sold-out slots
- Navigate to booking confirmation screen on slot selection
- Input form for user details with validation
- Mock payment code validation ("1234")
- Atomic Firestore transaction to decrement slot availability on booking
- Success feedback with animated Thank You screen
- Real-time UI updates via Firestore streams

## Setup and Run

### Prerequisites

- Flutter SDK installed (version compatible with your project)
- Firebase project with Firestore enabled
- Android/iOS emulator or physical device connected

### Installation

1. Clone the repository:


2. Navigate to the project directory:


3. Install Flutter dependencies:


4. Set up Firebase configuration:

- Add your `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) to the project as per Firebase setup
- Ensure `firebase_options.dart` is generated and included (as in the project files)

### Running the App

Run the app on an emulator or connected device:


## Project Structure

- `Homepage.dart`: Displays the slot selection screen with available slots fetched from Firestore.
- `Booking-Confirmation-Screen.dart`: Booking confirmation form, validation, and booking persistence using Firestore transactions.
- `thank_you_screen.dart`: Animated screen shown after successful booking confirmation.
- `main.dart`: Entry point of the app.
- `firebase_options.dart`: Firebase configuration file.

## Approach

The app uses Flutter's `StreamBuilder` to listen to Firestore slot documents in real time, enabling instant UI updates when slots are booked. Booking is processed inside a Firestore transaction to ensure atomic decrement of available tickets and consistent booking creation. User inputs are validated with Flutter form validation, and the payment is mocked through a simple code input ("1234"). Upon successful booking, an animated thank you screen provides feedback to the user.

## Dependencies

- `cloud_firestore`: For Firestore database integration
- `flutter/material.dart`: Flutter UI components
- Other dependencies as defined in `pubspec.yaml`.

## Contributing

Contributions are welcome! Feel free to fork the repository, make changes, and submit pull requests.

## License

Specify your preferred license here.

---

Thank you for using this Flutter Slot Booking app. Please raise issues or contribute for improvements.

