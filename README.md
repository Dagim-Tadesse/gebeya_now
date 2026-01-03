﻿# Gebeya Now — Local Service Marketplace (Course Project)

## About this repository

This project is part of a Flutter Mobile Programming course workspace.

**Author**

- Name: Dagim Tadesse
- University: Addis Ababa Science and Technology University
- Department: Software Engineering

`gebeya_now` is a Flutter app built during the course to practice building a **realistic marketplace-style mobile app** with:

- Modern responsive UI (Sizer)
- Firebase Authentication
- Cloud Firestore data modeling
- Search + filtering UX
- Provider onboarding flow (submit → review → approved)

The idea is to help users quickly find local service providers (plumbing, electrical, tutoring, etc.).

---

## Quick start

From this folder:

```powershell
flutter pub get
flutter run
```

---

## Tech stack

- Flutter (Material)
- Dart
- Firebase
  - `firebase_core`
  - `firebase_auth` (+ Google and Facebook sign-in)
  - `cloud_firestore`
- Responsive layout: `sizer`
- Common utilities: `dio`, `shared_preferences`, `cached_network_image`, `image_picker`

Firebase initialization happens in `lib/main.dart`.

---

## Main user experience

### 1) Browse (Categories = Home)

The **Categories screen** is the main “home-like” page:

- Shows service categories (Plumbing, Electrical, Tailoring, Tutoring, Cleaning, Repair, Beauty, Carpentry, Painting, Gardening)
- Has a **working city selector** (“Change” opens a bottom sheet to pick a city)
- Tapping a category navigates to the provider list/search experience pre-filtered to that category

### 2) Search providers + real filters

The provider list screen supports:

- Live provider updates from Firestore (`providers` collection)
- Search by text
- Filter bottom sheet (category + other filters)
- Sorting (distance, rating, price, etc.)
- Favorites tab (requires login)

### 3) Favorites

Favorites are stored under each user:

- `users/{uid}/favorites/{providerId}`

### 4) Provider onboarding (submit for review)

Users can apply to become providers using the provider registration flow.

**Important:** the app does NOT write directly into `providers` from the user-facing registration flow. Instead it submits an application for review.

Flow:

1. User fills provider registration form.
2. App writes a pending application document:
   - `provider_applications/{uid}` with `status: "pending"`
3. App also updates the user document:
   - `users/{uid}.providerApplicationStatus = "pending"`

After approval (admin/manual step), the provider should be “promoted” into:

- `providers/{uid}` (provider profile used by search)
- `users/{uid}.role = "provider"` and `providerApplicationStatus = "approved"`

---

## Firestore collections used

This app currently expects/uses these collections:

### `providers`

Search reads from `providers` and normalizes a provider into fields like:

- `name`, `category`, `specialization`
- `location` (string or map)
- `avatar` (string url or `{ url: "..." }`)
- `availability` (e.g. Online/Offline)
- `rating`, `reviewCount`, `price`, `distance`
- `isFeatured`, `isEmergency`
- `joinedDate`

### `users`

Used for auth-related profile data and app flags like:

- `role` (e.g. `customer` / `provider`)
- `providerApplicationStatus` (`pending` / `approved` / `rejected`)
- Subcollection `favorites`

### `provider_applications`

Stores provider applications submitted from the app:

- `status: "pending"`
- Registration form fields (working hours, category, etc.)

---

## Demo provider data (for seeding/testing)

The project contains a demo provider dataset split by category and aggregated in one place:

- `lib/data/demo_provider_generator.dart` (helper)
- `lib/data/demo_<category>_data.dart` (per category)
- `lib/data/demo_providers.dart` (aggregated list)

This is intended for development/testing and quick UI preview.

---

## Project structure (high level)

```
gebeya_now/
  lib/
    main.dart
    core/
    presentation/                 # screens and widgets
    routes/                       # app routes
    theme/                        # theme setup
    widgets/                      # reusable UI widgets
    data/                         # demo provider data
```

---

## Known limitations / next improvements

- Provider profile images picked via `image_picker` are local device file paths; for a real product they should be uploaded to Firebase Storage and stored as a download URL.
- Provider verification (“approve/reject”) is currently a manual/admin step; for production, build an admin tool or Cloud Function to promote applications into `providers`.
- Firestore Security Rules must be configured in Firebase Console (especially for `providers` and `provider_applications`).

---

## Troubleshooting

- If `flutter run` fails due to Gradle downloads: check network/DNS/proxy and retry.
- If Firestore reads fail: confirm Firebase config and Firestore rules allow the operation for the current user.
