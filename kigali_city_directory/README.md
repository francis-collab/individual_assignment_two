# Kigali City Directory

A Flutter mobile application that allows users to discover, add, and manage service listings (cafés, hospitals, tourist attractions, etc.) in Kigali, Rwanda.  
Built with **Firebase Authentication**, **Cloud Firestore** for real-time data, and **Google Maps** for location visualization.

---

# Features

## Email/Password Authentication
- Sign up and login with **Firebase Authentication**
- Mandatory **email verification** before accessing the app
- Secure logout from **Settings screen**

## Listings Management (CRUD)
- Create new listings *(name, category, address, contact, description, coordinates)*
- View all listings in the **Directory screen**
- View and manage your own listings in **My Listings screen**
- Edit and delete your own listings *(ownership enforced via `createdBy` UID)*

## Real-time Directory & Filtering
- Browse listings with **real-time Firestore updates**
- Top category tabs *(Café, Hospital, Tourist Attraction, etc.)*
- Search by name *(client-side filtering)*

## Interactive Map View
- **Google Maps integration** showing markers for all listings
- Distance calculation from user location *(using Geolocator)*
- **Navigate button** launches Google Maps directions

## Detail Screen
- Full listing information + embedded Google Map
- Bookmark toggle *(local state – can be extended to Firestore)*
- Reviews button *(placeholder screen – expandable later)*

## Settings Screen
- Displays user email with **verification status badge**
  - Green check if verified
- Toggle for **location-based notifications** *(placeholder)*
- Logout button

---

# Firestore Database Structure

## Collections

### 1. `users`
**Document ID:** Firebase Auth UID

Fields:
- `email` : string
- `createdAt` : timestamp

### 2. `listings`
**Document ID:** auto-generated

Fields:
- `name` : string *(e.g. "Kimironko Café")*
- `category` : string *(e.g. "Café", "Hospital")*
- `address` : string
- `contact` : string
- `description` : string
- `coordinates` : GeoPoint *(latitude, longitude)*
- `createdBy` : string *(user UID – enforces ownership)*
- `timestamp` : timestamp *(server timestamp)*

### Design Decisions
- **Flat structure** → fast reads and simple queries
- **`createdBy` field** → enables ownership filtering in **My Listings**
- **GeoPoint coordinates** → allows future geospatial queries
- **No subcollections** → keeps reads efficient and code simple

---

# State Management Approach

**Bloc** was chosen for state management because it provides:
- Clean separation of concerns
- Predictable state transitions
- Excellent support for streams

## Main Blocs

### `AuthBloc`
Handles:
- Sign-up
- Login
- Logout
- Email verification status

### `ListingBloc`
Manages all listing operations:

Events include:
- `LoadListings` → fetch all listings or user listings
- `CreateListingEvent` → create listing
- `UpdateListingEvent` → update listing
- `DeleteListingEvent` → delete listing
- `SearchListingsEvent` → client-side filtering by name/category

---

## Key Implementation Details

**Real-time updates**
- Firestore streams are passed through the Bloc
- Consumed in UI using `StreamBuilder`

**Filtering**
- Client-side filtering on stream data
- Suitable for small datasets

**Loading & Error States**
- Centralized in Bloc
- Provides consistent UI feedback across screens

### Trade-offs
- Client-side filtering instead of Firestore queries
  - Simpler code
  - Less efficient for large collections

- Direct service calls inside Bloc
  - Faster development
  - Less testable than a full repository pattern

---

# Setup Instructions

## 1. Clone the Repository
```bash
git clone <repository-url>
cd <repository-folder>

## 2. Install Dependencies

```bash
flutter pub get
```

## 3. Configure Firebase

Add `google-services.json` (Android)

Add `GoogleService-Info.plist` (iOS)

Run:

```bash
flutterfire configure
```

## 4. Enable Authentication

In **Firebase Console → Authentication → Sign-in method**

Enable:

- Email / Password

## 5. Run the App

```bash
flutter run
```

---

## Technologies Used

- Flutter (Dart)
- Firebase Authentication
- Cloud Firestore
- Google Maps Flutter
- Geolocator
- Bloc (State Management)

---

## Future Improvements

- Add real user reviews/ratings in Firestore subcollection
- Implement bookmark persistence in Firestore
- Add release SHA-1 restriction for production API key
- Add image upload for listings

---

## Author

Francis  
March 2025 – Kigali, Rwanda