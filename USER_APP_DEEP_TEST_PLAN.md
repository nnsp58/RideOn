# RideOn User App - Deep Test Plan

**App:** RideOn Car Pooling (Flutter, Supabase Backend)
**Date:** 2026-04-03
**Scope:** All user-facing screens, services, providers, RLS policies, and database functions

---

## Table of Contents

1. [Environment Setup](#1-environment-setup)
2. [Authentication Flow](#2-authentication-flow)
3. [Onboarding Flow](#3-onboarding-flow)
4. [Home Screen & Navigation](#4-home-screen--navigation)
5. [Search Rides Flow](#5-search-rides-flow)
6. [Ride Details Screen](#6-ride-details-screen)
7. [Publish Ride Flow](#7-publish-ride-flow)
8. [Booking Flow](#8-booking-flow)
9. [My Bookings Management](#9-my-bookings-management)
10. [My Rides Management (Driver)](#10-my-rides-management-driver)
11. [Chats & Messaging](#11-chats--messaging)
12. [Profile Management](#12-profile-management)
13. [Document Verification](#13-document-verification)
14. [Notifications System](#14-notifications-system)
15. [SOS Emergency System](#15-sos-emergency-system)
16. [Location & GPS Services](#16-location--gps-services)
17. [Localization (i18n)](#17-localization-i18n)
18. [Theme & Dark Mode](#18-theme--dark-mode)
19. [Admin Panel (User Side)](#19-admin-panel-user-side)
20. [Database Functions & RLS Policies](#20-database-functions--rls-policies)
21. [Storage Buckets](#21-storage-buckets)
22. [Realtime Subscriptions](#22-realtime-subscriptions)
23. [Edge Cases & Error Handling](#23-edge-cases--error-handling)
24. [Performance & Network Conditions](#24-performance--network-conditions)
25. [Security & Privacy](#25-security--privacy)
26. [Smoke Test Checklist](#26-smoke-test-checklist)

---

## 1. Environment Setup

### Prerequisites

| Item | Verification | Status |
|------|-------------|--------|
| Flutter SDK installed (`flutter doctor`) | `flutter doctor` passes with no errors | |
| Android emulator / iOS simulator running | Device shows in `flutter devices` | |
| Supabase project configured | `.env` file contains valid `SUPABASE_URL` and `SUPABASE_ANON_KEY` | |
| OneSignal keys configured | `ONESIGNAL_APP_ID` and `ONESIGNAL_REST_API_KEY` in `.env` | |
| Database schema applied | `database_schema.sql` executed without errors | |
| `flutter pub get` complete | No dependency conflicts | |
| Build runner generated files | `*.freezed.dart` and `*.g.dart` files exist | |
| Build_runner code generation fresh | `dart run build_runner build --delete-conflicting-outputs` succeeds | |

### Test Data Setup

- [ ] Create 2 test users (driver + passenger) via Supabase Admin
- [ ] Ensure at least 1 admin test user exists (`khutail1985@gmail.com`)
- [ ] Create test location coordinates near a known city
- [ ] Upload at least 1 test profile photo and 1 test document image

---

## 2. Authentication Flow

### 2.1 Welcome Screen (`screens/auth/welcome_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| AUTH-WEL-01 | Welcome screen renders | Open app as unauthenticated user | Welcome screen shows app description, branding, login/signup options | P0 |
| AUTH-WEL-02 | Navigate to login | Tap "Login" button | Routes to `/login` | P0 |
| AUTH-WEL-03 | Navigate to signup | Tap "Sign Up" button | Routes to `/signup` | P0 |

### 2.2 Login Screen (`screens/auth/login_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| AUTH-LOG-01 | Login with valid email/password | Enter valid credentials, tap login | Authenticates, redirects to home screen | P0 |
| AUTH-LOG-02 | Login with wrong email | Enter unregistered email, tap login | Shows error: "User not found" or similar | P0 |
| AUTH-LOG-03 | Login with wrong password | Enter email + invalid password | Shows error from Supabase auth | P0 |
| AUTH-LOG-04 | Empty fields validation | Tap login with empty fields | Shows validation error, does not call API | P1 |
| AUTH-LOG-05 | Password visibility toggle | Tap eye icon | Shows/hides password field | P1 |
| AUTH-LOG-06 | Loading state during auth | Tap login with valid credentials | Loading spinner appears, button disabled | P1 |
| AUTH-LOG-07 | Navigate to signup | Tap "Create account" link | Routes to `/signup` | P2 |

### 2.3 Signup Screen (`screens/auth/signup_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| AUTH-SIG-01 | Signup with valid data | Enter email, password, full name, phone, tap signup | Creates auth user + profile in `users` table, redirects to OTP screen | P0 |
| AUTH-SIG-02 | Email format validation | Enter invalid email format (e.g. "abc") | Shows email validation error | P0 |
| AUTH-SIG-03 | Password strength validation | Enter password shorter than required or no match | Shows password validation error | P0 |
| AUTH-SIG-04 | Confirm password mismatch | Enter different passwords in password/confirm fields | Shows "passwords don't match" error | P0 |
| AUTH-SIG-05 | Empty fields validation | Tap signup with one or more empty fields | Shows inline validation errors | P1 |
| AUTH-SIG-06 | Duplicate email signup | Use email of existing account | Supabase returns error, user sees message | P0 |
| AUTH-SIG-07 | Phone number format | Enter phone number in international format | Accepts valid format, rejects invalid | P1 |

### 2.4 OTP Screen (`screens/auth/otp_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| AUTH-OTP-01 | Enter correct OTP | Enter valid 6-digit OTP sent to phone | Verifies OTP, logs in user, redirects to home/profile-setup | P0 |
| AUTH-OTP-02 | Enter incorrect OTP | Enter wrong 6-digit code | Shows error, allows retry | P0 |
| AUTH-OTP-03 | OTP expiry | Wait for OTP to expire, then enter | Shows "OTP expired" error | P1 |
| AUTH-OTP-04 | Resend OTP | Tap "Resend OTP" button | New OTP sent to phone, countdown timer resets | P1 |
| AUTH-OTP-05 | Resend cooldown | Tap resend multiple times rapidly | Resend disabled during cooldown period | P2 |
| AUTH-OTP-06 | Pinput code paste | Paste full OTP code from clipboard | Auto-fills all 6 digits | P2 |

### 2.5 Auth State Persistence

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| AUTH-PER-01 | App restart while logged in | Kill app, reopen app | User stays logged in, goes to home screen | P0 |
| AUTH-PER-02 | Session expiry handling | Let Supabase session expire, perform action | App redirects to login screen | P0 |
| AUTH-PER-03 | Auto-redirect when authenticated | Open app while already logged in | Bypasses welcome/login, goes to `/home` | P0 |

---

## 3. Onboarding Flow

### 3.1 Profile Setup Screen (`screens/onboarding/profile_setup_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| ONB-PRO-01 | Render profile setup | First login after signup | Profile setup form with name, bio, photo fields | P0 |
| ONB-PRO-02 | Upload profile photo | Tap photo field, select image | Image preview appears, uploads to `profile-photos` bucket | P0 |
| ONB-PRO-03 | Save profile | Fill required fields, tap save | Profile saved to `users` table, `setup_complete` = true, redirects to `/vehicle-setup` | P0 |
| ONB-PRO-04 | Skip profile setup | Tap skip if available | Proceeds to next step with minimal profile | P2 |
| ONB-PRO-05 | Validation - empty name | Try to save with empty name | Shows validation error | P1 |

### 3.2 Vehicle Setup Screen (`screens/onboarding/vehicle_setup_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| ONB-VEH-01 | Render vehicle setup | After profile setup | Vehicle setup form with model, plate, color, type fields | P0 |
| ONB-VEH-02 | Fill vehicle details | Enter vehicle model, license plate, color, select type | All fields populated | P0 |
| ONB-VEH-03 | Save vehicle info | Tap save | `setup_complete` remains true, `hasVehicle` getter returns true, redirects to `/home` | P0 |
| ONB-VEH-04 | Can publish rides check | After vehicle setup | `UserModel.canPublishRides` returns `setupComplete && isVerified && hasVehicle && !isBanned` | P0 |
| ONB-VEH-05 | Vehicle type selection | Select from Car, Bike, Van dropdown | Vehicle type saved correctly | P1 |

---

## 4. Home Screen & Navigation

### 4.1 Home Screen (`screens/home/home_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| HOM-REN-01 | Home renders for passenger | Open app as non-vehicle user | Shows search card, recent rides, welcome message | P0 |
| HOM-REN-02 | Home renders for driver | Open app as vehicle-verified user | Shows "Publish a Ride" quick action, recent rides | P0 |
| HOM-REN-03 | No active rides | When no ride_searches available locally | Shows empty state with "Search for a ride" CTA | P1 |
| HOM-NAV-01 | Tap "Search Rides" | Tap search button on home | Routes to `/search` | P0 |
| HOM-NAV-02 | Tap "Publish Ride" | Tap publish button (driver only) | Routes to `/publish` | P0 |
| HOM-NAV-03 | Tap on a ride card | Tap a displayed ride | Routes to `/ride-details/:id` | P0 |

### 4.2 Main Screen Navigation (`screens/main_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| NAV-BTN-01 | Home tab selected | Tap Home tab icon | Shows home screen content | P0 |
| NAV-BTN-02 | My Bookings tab | Tap "My Bookings" tab | Shows my bookings content | P0 |
| NAV-BTN-03 | My Rides tab | Tap "My Rides" tab | Shows my published rides content | P0 |
| NAV-BTN-04 | Profile tab | Tap Profile tab icon | Shows profile screen | P0 |
| NAV-BTN-05 | SOS button visible | SOS floating button present on all tabs | SOS button visible as fab | P0 |
| NAV-PUB-01 | Publish ride from FAB | Tap floating action button (if driver) | Routes to `/publish` | P0 |

---

## 5. Search Rides Flow

### 5.1 Search Screen (`screens/search/search_rides_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| SRH-REN-01 | Search screen renders | Navigate to `/search` | Search form with "From", "To", "Date" fields | P0 |
| SRCH-01 | Valid search | Enter valid from/to locations + date, tap search | Shows matching rides based on location proximity | P0 |
| SRCH-02 | No results | Search for route with no active rides | Shows "no rides found" empty state | P0 |
| SRCH-03 | Search without coordinates | Enter city names as text (no lat/lng) falls back to string matching | Shows rides where location text contains search text (case-insensitive) | P1 |
| SRCH-04 | Date filter - future date | Search for rides on future date | Shows rides departing on that date | P0 |
| SRCH-05 | Date filter - today | Search for today's date | Only shows rides departing 5+ minutes in future (booking gap) | P0 |
| SRCH-06 | Search with coordinates | Select locations from map, coordinates attached to search query | Uses proximity matching (80km threshold) to find matching rides | P0 |
| SRCH-07 | Pro-rata pricing | Search for a partial segment of a ride | Segment price calculated proportionally to distance, rounded to nearest 10, minimum 30 | P0 |
| SRCH-08 | Sort by time | Results with multiple rides | Sorted by `departureDatetime` ascending | P1 |
| SARC-01 | Location autocomplete | Type in "From" field | Shows location suggestions from autocomplete | P1 |
| SARC-02 | Location from map | Tap pin icon, pick on map | Location text + lat/lng populated | P0 |
| SRCH-ERR-01 | Search network error | Search with no internet | Shows error message, no crash | P0 |
| SRCH-LOADING-01 | Search loading state | Tap search | Loading spinner shown during search | P1 |
| SRCH-RETRY-01 | Retry search | After error, tap retry or re-enter search | Re-executes search with same parameters | P2 |
| SRH-FLOW-01 | Failed search recorded | Search returns 0 results | `recordRideSearch()` called silently in background | P2 |

### 5.2 Map Location Picker (`screens/common/map_location_picker.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| MAP-CK-01 | Map renders | Open location picker | Map displays with current location | P0 |
| MAP-CK-02 | Select location by tapping | Tap a location on map | Pin placed at location, coordinates updated | P0 |
| MAP-CK-03 | Reverse geocoding | Select a location | Address text populated for selected coordinates | P1 |
| MAP-CK-04 | Search location bar | Type address in search field | Autocomplete suggestions shown | P1 |

---

## 6. Ride Details Screen

### 6.1 Ride Details (`screens/search/ride_details_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| RDT-REN-01 | Ride details renders | Open a ride details page | Shows all ride info: route, time, price, driver, seats, rules | P0 |
| RDT-02 | Driver profile displayed | View ride details | Driver name, photo, rating shown | P0 |
| RDT-RT-01 | Route visualization | Open ride details | Route map shown with from/to points and waypoints | P0 |
| RDT-RULES-01 | Ride rules displayed | Open ride details | All active rules shown as chips (No Smoking, No Music, etc.) | P1 |
| RDT-BTN-01 | Book button - available | Ride has seats, not departed | "Book Ride" button is enabled and visible | P0 |
| RDT-BTN-02 | Book button - ride full | No seats available | "Book Now" disabled or shows "Full" | P0 |
| RDT-BTN-03 | Book button - booking closed | Departure within 5 minutes | "Booking Closed" shown, book button hidden | P0 |
| RDT-BTN-04 | Book button - ride cancelled | Ride status is cancelled | Shows cancellation message | P1 |
| RDT-BOOK-01 | Open booking flow | Tap "Book" on available ride | Opens booking confirmation modal/navigates to booking flow | P0 |
| RDT-ERR-01 | Invalid ride ID | Navigate to `/ride-details/invalid-id` | Shows error state gracefully | P2 |

### 6.2 Route Viewer Screen (`screens/publish/route_viewer_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| RTV-01 | Route viewer renders | View route from published ride | Map shows route polyline and waypoints | P0 |
| RTV-02 | Waypoints visible | Ride has route_points | Intermediate waypoints shown on map | P1 |

---

## 7. Publish Ride Flow

### 7.1 Publish Ride Screen (`screens/publish/publish_ride_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| PUB-REN-01 | Publish screen renders as eligible driver | Navigate to `/publish` as verified driver | Form with ride details fields | P0 |
| PUB-PERM-01 | Publish blocked for non-verified user | Navigate as unverified user | Shows message or redirects | P0 |
| PUB-PERM-02 | Publish blocked for banned user | Navigate as banned user | Shows message or redirects | P0 |
| PUB-VRD-01 | Validate from location | Empty "From" field | Validation error shown | P0 |
| PUB-VRD-02 | Validate destination | Empty "To" field | Validation error shown | P0 |
| PUB-VRD-03 | Validate date/time | Empty or past date selected | Validation error shown | P0 |
| PUB-VRD-04 | Validate seats | 0, negative, or very large number | Validation error shown, max seats reasonable value | P0 |
| PUB-VRD-05 | Validate price | Zero or negative price | Validation error shown | P0 |
| PUB-FLOW-01 | Publish with all fields | Enter valid from, to, date, seats, price, tap publish | Ride published to Supabase, `status` = 'active', redirects to home | P0 |
| PUB-FLOW-02 | Publish with optional fields | Add description, select ride rules (no smoking, no music, etc.), tap publish | All selected rules saved to ride record | P1 |
| PUB-FLOW-03 | Publish with route waypoints | Select route points on map, tap publish | `route_points` saved as JSONB array | P1 |
| PUB-FLOW-04 | Publish with vehicle snapshot | Publish ride when user has vehicle info | `vehicle_info` and `vehicle_type` auto-populated from profile | P1 |
| PUB-TRIG-01 | Trigger: matching ride search notifications | Publish ride after user searched for same route | Users who searched get a `ride_alert` notification | P0 |
| PUB-NAV-01 | Edit existing ride | Navigate to `/publish` with existing ride passed as parameter | Form pre-filled with ride data, can update | P2 |
| PUB-PRICE-01 | Price field format | Enter decimal values | Price stored as DECIMAL(10,2) | P0 |
| PUB-SEATS-01 | Available seats = total seats | After publishing | Database shows `available_seats` equal to `total_seats` | P0 |

---

## 8. Booking Flow

### 8.1 Book a Ride

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| BKG-BOOK-01 | Book single seat | Tap book → confirm details → confirm booking | `book_ride_seat` RPC executes, booking created in DB, seats decremented | P0 |
| BKG-BOOK-02 | Booking confirmation | Successful booking | Booking ID returned, confirmation shown to user | P0 |
| BKG-BOOK-03 | Driver notification | After passenger books | Driver receives `notification` of type `booking_request` | P0 |
| BKG-SEAT-01 | Seat count after booking | Check ride's `available_seats` before/after booking | Decreased by number of seats booked | P0 |
| BKG-SEAT-02 | Ride status becomes "full" | Book last available seat | Ride status changes from 'active' to 'full' | P0 |
| BKG-SEAT-03 | Over-booking prevention | Try to book more seats than available | `book_ride_seat` returns error: "Not enough seats available" | P0 |
| BKG-PRICE-01 | Segment pricing calculation | Book partial segment of a ride | Price rounded to nearest 10, minimum 30, capped at full price | P0 |
| BKG-PRICE-02 | Full ride booking | Book entire route | Price equals `pricePerSeat` (no segment calculation) | P0 |
| BKG-BEFORE-01 | Booking 5 min before departure | Try to book ride departing in <5 min | Error: "Booking closes 5 minutes before departure" | P0 |
| BKG-AFTER-01 | Booking after departure | Try to book departed ride | Error: ride not available or booking closed | P0 |
| BKG-RACE-01 | Concurrent booking (race condition) | Two users book last seat simultaneously | `FOR UPDATE` row lock prevents double booking, one fails | P0 |
| BKG-DUP-01 | Double booking same ride | Passenger tries to book same ride twice | Allowed (unless seats not available), each booking record separate | P2 |

---

## 9. My Bookings Management

### 9.1 My Bookings Screen (`screens/bookings/my_bookings_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| BK-MY-01 | List bookings | User has 1+ bookings | Shows all bookings sorted by `booked_at` desc | P0 |
| BK-MY-02 | No bookings | User has no bookings | Shows empty state with "No bookings yet" | P1 |
| BK-MY-03 | Booking status colors | Mix of confirmed/cancelled/completed bookings | Different visual indicators per status | P1 |
| BK-MY-NAV-01 | Navigate to booking detail | Tap a booking card | Routes to `/booking-detail/:id` | P0 |
| BK-MY-FILTER-01 | Filter by status | Toggle Active/Past filters | Shows only matching bookings | P2 |

### 9.2 Booking Detail Screen (`screens/bookings/booking_detail_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| BK-DTL-01 | Booking details render | Open booking detail | Shows route, price, date, driver, passenger, status | P0 |
| BK-DTL-02 | Cancel booking (passenger) | Tap cancel on active booking | `cancel_booking` RPC called, booking status → 'cancelled', seats restored | P0 |
| BK-DTL-03 | Cancel with reason | Enter cancellation reason | Reason stored in `cancel_reason` field | P1 |
| BK-DTL-04 | Cancel already-cancelled booking | Try to cancel cancelled booking | Error: "Booking already cancelled" | P0 |
| BK-DTL-05 | Cancel notification | After cancellation | Driver receives `booking_cancelled` notification | P0 |
| BK-DTL-06 | Seat restoration after cancel | Check ride `available_seats` after booking cancellation | Seats restored by `seats_booked` amount | P0 |
| BK-DTL-07 | Chat with driver | Tap "Chat" button on active booking | Opens chat screen with driver | P0 |

---

## 10. My Rides Management (Driver)

### 10.1 My Rides Screen (`screens/rides/my_rides_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| RD-MY-01 | Published rides list | Driver has published rides | Shows all rides sorted by `departure_datetime` desc | P0 |
| RD-MY-02 | No published rides | Driver has no rides | Shows empty state: "No rides published yet" | P1 |
| RD-MY-03 | Ride status indicators | Mix of active/full/completed/cancelled rides | Each ride shows correct status badge | P0 |
| RD-MY-04 | Navigate to ride passengers | Tap on a ride card | Routes to `/ride-passengers/:id` | P0 |
| RD-MY-05 | Upcoming vs past rides | Mix of future and past rides | Clearly separated or visually indicated | P1 |

### 10.2 Ride Passengers Screen (`screens/rides/ride_passengers_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| RD-PAX-01 | Bookings list for ride | Open ride with 1+ passengers | Lists all passengers with name, seats, status | P0 |
| RD-PAX-02 | No bookings | Open ride with no bookings yet | Shows "No passengers yet" empty state | P1 |
| RD-PAX-03 | Cancel booking as driver | Tap cancel on passenger booking | `cancel_booking` RPC called with driver auth | P0 |
| RD-PAX-04 | Cancel full ride | Tap "Cancel Ride" on active ride | `cancel_full_ride` RPC cancels ride and all bookings, notifies all passengers | P0 |
| RD-PAX-05 | Chat with passenger | Tap chat icon on passenger | Opens chat with that passenger | P0 |

### 10.3 Ride Cancellation (Driver)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| RD-CXL-01 | Cancel active ride | Driver cancels ride with reason | Ride status → 'cancelled', all bookings cancelled, passengers notified | P0 |
| RD-CXL-02 | Cancel ride with no passengers | Cancel ride that has no bookings | Ride status → 'cancelled', no notifications sent to passengers | P1 |
| RD-CXL-03 | Cancel already-cancelled ride | Try to cancel a cancelled ride | Error: "Ride is already cancelled" | P0 |
| RD-CXL-04 | Unauthorized cancellation | Try to cancel another driver's ride | Error: "Not authorized" | P0 |
| RD-CXL-05 | Seats restored on cancel | Check other passengers' bookings after 1 cancellation | Only the cancelled passenger's seats restored, others unaffected | P0 |

---

## 11. Chats & Messaging

### 11.1 Inbox Screen (`screens/chat/inbox_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| CHAT-INB-01 | List chats | User has 1+ chats | Shows list of chats sorted by `last_message_at` desc | P0 |
| CHAT-INB-02 | Empty inbox | No chats exist | Shows "No conversations yet" empty state | P1 |
| CHAT-INB-03 | Other user info shown | Each chat card shows | Participant name, last message, ride route | P1 |

### 11.2 Chat Screen (`screens/chat/chat_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| CHAT-SEND-01 | Send message | Type and send message | Message saved to `messages` table, chat's `last_message` updated | P0 |
| CHAT-RCV-02 | Realtime message receive | Other user sends a message while chat is open | Message appears in real-time via Supabase stream listener | P0 |
| CHAT-HIST-01 | Message history | Open existing chat | All previous messages displayed in chronological order | P0 |
| CHAT-RCV-03 | Message read status | Read received messages | `is_read` set to true for messages not sent by current user | P1 |
| CHAT-EMPTY-01 | Empty chat | Open active chat | Shows "Start the conversation" message | P2 |
| CHAT-NAV-01 | Navigate from booking | Tap "Chat" from booking detail | Pre-filled chat with ride/booking context | P0 |
| CHAT-CREATE-01 | Auto-create chat | Open chat that doesn't exist between two users | Chat record created with default `last_message`: "Conversation started" | P0 |

### 11.3 Chat Trigger: Notification

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| CHAT-NOT-01 | Auto notification on message | Send a message in chat | Database trigger `notify_chat_message` creates notification for recipient | P0 |
| CHAT-NOT-02 | Push notification | User app is in background | OneSignal push notification delivered (if FCM token registered) | P1 |

---

## 12. Profile Management

### 12.1 Profile Screen (`screens/profile/profile_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| PRO-REN-01 | Profile renders | Open profile tab | Shows user name, photo, rating, total rides, bio, verification status | P0 |
| PRO-NAV-01 | Navigate to edit profile | Tap profile/photo | Routes to `/edit-profile` | P0 |
| PRO-NAV-02 | Navigate to documents | Tap "Documents" or verification status | Routes to `/documents` | P0 |
| PRO-NAV-03 | Navigate to notifications | Tap notifications icon | Routes to `/notifications` | P0 |
| PRO-NAV-04 | Navigate to reports | Tap "Reports" | Routes to `/reports` | P0 |
| PRO-NAV-05 | Sign out | Tap sign out | Signs out, redirects to welcome screen, clears local state | P0 |
| PRO-INFO-01 | Stats display | Profile shows | Rating, total_rides_given, total_rides_taken correctly displayed | P0 |

### 12.2 Edit Profile Screen (`screens/profile/edit_profile_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| PRO-ED-01 | Load profile data | Open edit profile | Form pre-filled with existing user data | P0 |
| PRO-ED-02 | Change name | Update full name, save | `users.full_name` updated in DB | P0 |
| PRO-ED-03 | Change bio | Update bio text, save | `users.bio` updated in DB | P1 |
| PRO-ED-04 | Change profile photo | Pick new photo | New photo uploaded to `profile-photos` bucket, URL updated in user profile | P0 |
| PRO-ED-05 | Save with validation | Leave required fields empty, save | Validation errors shown | P1 |

### 12.3 Address & Preferences

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| PRO-ADR-01 | Update address fields | Edit pincode, state, city, tehsil | Fields saved to user profile | P2 |
| PRO-PREF-01 | User preferences | Edit preferences (no smoking, no music, no heavy luggage, no pets, negotiation) | Preferences saved, used as defaults when publishing rides | P1 |
| PRO-PREF-02 | Preferences applied to ride | Publish a ride after setting preferences | Ride rules auto-populated from user preferences | P1 |

---

## 13. Document Verification

### 13.1 Documents Screen (`screens/profile/documents_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| DOC-01 | Upload driving license front | Select image, upload "Driving License Front" | File uploaded to `user-documents` bucket, `doc_driving_license_front` updated | P0 |
| DOC-02 | Upload driving license back | Select image, upload "Driving License Back" | File uploaded, `doc_driving_license_back` updated | P0 |
| DOC-03 | Upload vehicle RC | Select image, upload vehicle RC | File uploaded, `doc_vehicle_rc` updated | P0 |
| DOC-04 | Submit documents for verification | Upload all required docs, tap submit | `doc_verification_status` → 'pending' | P0 |
| DOC-05 | Show pending status | After submission, before admin review | UI shows "Pending review" banner | P1 |
| DOC-06 | Approved status | After admin approves | UI shows "Verified" badge, `doc_verification_status` → 'approved' | P0 |
| DOC-07 | Rejected status | After admin rejects with reason | UI shows rejection reason, `doc_verification_status` → 'rejected' | P0 |
| DOC-08 | Re-upload after rejection | After rejection, upload new documents | Can re-submit for review, status back to 'pending' | P0 |
| DOC-09 | Private document URLs | Access uploaded documents | Returns signed URL (1 hour expiry) for private documents | P1 |
| DOC-10 | Security - not_submitted | User who hasn't submitted docs | `doc_verification_status` = 'not_submitted', cannot publish rides | P0 |
| DOC-11 | CanPublishRides gate | Check document verification status | `isVerified` getter checks `docVerificationStatus == 'approved'` | P0 |
| DOC-12 | ID Proof upload | Upload ID proof (e.g., Aadhar, PAN) | `id_type`, `id_number`, `id_doc_url` populated | P2 |
| DOC-13 | Address Proof upload | Upload address proof | `address_doc_type`, `address_doc_url` populated | P2 |
| DOC-14 | Driving license number | Enter DL number without upload | `driving_license_number` saved | P2 |
| DOC-15 | PUC and Insurance numbers | Enter PUC and Insurance numbers | Both fields saved to user profile | P2 |

---

## 14. Notifications System

### 14.1 Notifications Screen (`screens/notifications/notifications_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| NOT-REN-01 | Notifications list | User has notifications | Shows notifications sorted by `created_at` desc | P0 |
| NOT-EMPTY-01 | Empty notifications | No notifications exist | Shows "No notifications yet" empty state | P2 |
| NOT-READ-01 | Mark as read | Tap on unread notification | `is_read` → true | P0 |
| NOT-READ-ALL-01 | Mark all as read | Tap "Mark all as read" | All unread notifications marked as read | P0 |
| NOT-DEL-01 | Delete notification | Swipe or tap delete | `notifications` table entry deleted | P2 |
| NOT-UNREAD-01 | Unread count indicator | User has unread notifications | Shows unread count badge on notification icon | P0 |
| NOT-UNREAD-02 | No unread count | All notifications read | No unread count badge shown | P2 |
| NOT-TYPE-01 | Different notification types | View booking_confirmed, booking_cancelled, chat_message, ride_alert, ride_cancelled, new_message, booking_request, passenger_interest, ride_available | Each type has different icon/title/message formatting | P1 |

### 14.2 Notification Types (Triggered by Events)

| Event | Notification Type | Recipient | Trigger Source |
|-------|-------------------|-----------|----------------|
| New booking | `booking_request` | Driver | `book_ride_seat` DB function |
| Booking cancelled by passenger | `booking_cancelled` | Driver | `cancel_booking` DB function |
| Booking cancelled by driver | `booking_cancelled` | Passenger | `cancel_booking` DB function |
| Ride cancelled | `ride_cancelled` | All passengers of ride | `cancel_full_ride` DB function |
| New chat message | `chat_message` | Other participant | `notify_chat_message` DB trigger |
| Matching ride published | `ride_alert` | User who searched that route | `notify_matching_ride_searches` trigger |
| Passengers interested | `passenger_interest` | Driver | `notify_matching_ride_searches` trigger |
| Ride available (user searched) | `ride_alert` | Searching user | Same as matching ride published |

### 14.3 Push Notifications (OneSignal)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| NOT-PUSH-01 | Push notification background | App in background, booking event occurs | OneSignal push notification delivered | P1 |
| NOT-PUSH-02 | Push notification with deep link | Tap push notification | App opens, navigates to relevant screen (ride details / chat / booking detail) | P2 |
| NOT-PUSH-03 | FCM token registration | Login to app | `users.fcm_token` updated in DB | P1 |

---

## 15. SOS Emergency System

### 15.1 SOS Button (`widgets/sos_button.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| SOS-TRG-01 | Trigger SOS | Tap SOS button, confirm | SOS alert created with current GPS location, `is_active` = true | P0 |
| SOS-TRG-02 | SOS without GPS | GPS unavailable | Shows permission request, or uses last known location with warning | P1 |
| SOS-LOC-01 | Location captured | Trigger SOS | `latitude`, `longitude`, `location_name` stored | P0 |
| SOS-ACT-01 | Active SOS display | After triggering | SOS button shows "active" state, can cancel | P0 |
| SOS-CAN-01 | Cancel SOS | Tap cancel SOS | `is_active` → false, `resolved_at` timestamp set | P0 |
| SOS-HIST-01 | View user's SOS history | User has previous alerts | All alerts visible in admin and personal history | P1 |
| SOS-META-01 | Emergency type | SOS triggered with optional emergency type selection | `emergency_type` stored (e.g., "general") | P2 |

### 15.2 Admin SOS Screen (`screens/admin/admin_sos_screen.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| SOS-ADM-01 | Admin sees active SOS | Active SOS alerts exist | Shows all active SOS alerts on admin screen | P0 |
| SOS-ADM-02 | Resolve SOS | Admin resolves SOS | `is_active` → false, `resolved_at`, `resolved_by` set | P0 |

---

## 16. Location & GPS Services

### 16.1 Location Provider (`providers/location_provider.dart`)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| LOC-GPS-01 | GPS permission granted | App has location permission allowed | Current location detected | P0 |
| LOC-GPS-02 | GPS permission denied | User denies location permission | Shows graceful message, allows manual input | P0 |
| LOC-GPS-03 | Mock location detection | App running with GPS location mock | Mock location detected and handled | P2 |
| LOC-GEO-01 | Geocoding | Convert address to coordinates | Returns `lat`/`lng` for address string | P0 |
| LOC-GEO-02 | Reverse geocoding | Convert coordinates to address | Returns address for `lat`/`lng` | P1 |
| LOC-MAP-01 | Map display | Map shown on search/publish screens | Tiles rendered via `flutter_map` with `latlong2` | P0 |

---

## 17. Localization (i18n)

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| LOC-EN-01 | English language | Set locale to English | All UI text in English | P0 |
| LOC-HI-01 | Hindi language | Set locale to Hindi | All UI text in Hindi | P0 |
| LOC-SWITCH-01 | Switch locale at runtime | Toggle language in settings | App immediately reflects new language without restart | P0 |
| LOC-DEFAULT-01 | Default locale | Fresh install, no locale set | English is default | P1 |

---

## 18. Theme & Dark Mode

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| THM-LT-01 | Light theme | System in light mode | Light theme applied (`AppTheme.lightTheme`) | P0 |
| THM-DK-01 | Dark theme | System in dark mode | Dark theme applied (`AppTheme.darkTheme`) | P0 |
| THM-SWITCH-01 | Theme switches per system setting | Change system theme while app is running | Theme updates to match system (`themeMode: ThemeMode.system`) | P1 |
| THM-BTN-01 | Button colors | Verify all buttons have proper contrast in both themes | Buttons accessible in light and dark mode | P2 |
| THM-TEXT-01 | Text readability | Check all screens in dark mode | All text visible and readable against background | P1 |

---

## 19. Admin Panel (User Side)

> Note: Admin panel is part of the user app, guarded by `is_admin` check via GoRouter redirect.

### 19.1 Admin Access

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| ADM-REDIR-01 | Non-admin access to admin routes | Navigate to `/admin` as non-admin | Redirected to `/home` | P0 |
| ADM-REDIR-02 | Admin access | Navigate to `/admin` as admin | Admin dashboard shown | P0 |
| ADM-REDIR-03 | Unauthenticated admin access | Navigate to `/admin` while logged out | Redirected to `/welcome` | P0 |

### 19.2 Admin Screens

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| ADM-DASH-01 | Dashboard renders | Open `/admin` | Shows admin metrics/stats overview | P0 |
| ADM-USERS-01 | User management | Open `/admin/users` | Lists all users with ban/unban capabilities | P0 |
| ADM-USERS-02 | Ban user | Admin bans a user | `is_banned` = true, user cannot publish rides | P0 |
| ADM-DOC-01 | Document review | Open `/admin/documents` | Shows pending documents for verification | P0 |
| ADM-DOC-02 | Approve document | Admin approves a document | `doc_verification_status` = 'approved' | P0 |
| ADM-DOC-03 | Reject document | Admin rejects with reason | `doc_verification_status` = 'rejected', `doc_rejection_reason` stored | P0 |
| ADM-SOS-01 | Active SOS alerts | Open `/admin/sos` | Lists all active SOS alerts | P0 |
| ADMIN-RIDE-01 | Ride management | Open `/admin/rides` | Lists all rides with status management capability | P0 |

---

## 20. Database Functions & RLS Policies

### 20.1 Database Functions

| Function | Purpose | Input | Output | Tests |
|----------|---------|-------|--------|-------|
| `book_ride_seat(...)` | Atomic seat booking with validation | ride_id, passenger info, seats, price | `{success, booking_id}` or `{success: false, error}` | Tests BKG-BOOK-01, BKG-SEAT-01, BKG-SEAT-02, BKG-SEAT-03, BKG-BEFORE-01 |
| `cancel_booking(...)` | Cancel booking, restore seats, notify | booking_id, user_id, reason | `{success}` or `{success: false, error}` | Tests BK-DTL-02, BK-DTL-04, BK-DTL-06 |
| `cancel_full_ride(...)` | Cancel entire ride, cancel all bookings, notify all passengers | ride_id, driver_id, reason | `{success}` or `{success: false, error}` | Tests RD-PAX-04, RD-CXL-01, RD-CXL-03, RD-CXL-04 |
| `expire_completed_rides()` | Auto-complete past rides and bookings | None | void | Auto-triggered on ride/booking INSERT |
| `notify_matching_ride_searches()` | Notify users after new ride published on their searched route | Triggered by ride INSERT | Inserts notifications | Tests PUB-TRIG-01 |
| `update_user_rating()` | Recalculate average rating after new review | Triggered by review INSERT | Updates `users.rating` and counters | Proven by review flow |
| `notify_chat_message()` | Auto notification when new message sent | Triggered by message INSERT | Inserts notification | Tests CHAT-NOT-01 |
| `is_admin_v2()` | Check if current user is admin | None (uses `auth.uid()`) | boolean | Used in admin RLS policies |
| `handle_master_admin()` | Auto-set admin flag for master admin email | Triggered by user INSERT/UPDATE | Sets `is_admin` | Tests ADM-REDIR-02 |
| `handle_new_user()` | Auto create user profile on auth signup | Triggered by auth.users INSERT | Inserts into `public.users` | Auth signup flow |

### 20.2 RLS Policies

| Table | Policy | Verification |
|-------|--------|-------------|
| `users` | View all profiles (SELECT true) | Any user can view any profile |
| `users` | Insert own profile (auth.uid() = id) | Can only insert own record |
| `users` | Update own profile (auth.uid() = id) | Can only update own record |
| `users` | Admin ALL (is_admin_v2()) | Admin can do anything |
| `rides` | View active rides (true) | Anyone can view all rides |
| `rides` | Insert own rides (auth.uid() = driver_id) | Can only publish own rides |
| `rides` | Update own rides (auth.uid() = driver_id) | Can only update own rides |
| `rides` | Admin ALL | Admin can do anything |
| `bookings` | View own (passenger_id or driver_id matches) | Can only view bookings you're involved in |
| `bookings` | Insert as passenger (auth.uid() = passenger_id) | Can only book for yourself |
| `bookings` | Update by participants (passenger_id or driver_id) | Both parties can update |
| `bookings` | Admin ALL | Admin can do anything |
| `chats` | View own chats | Only participants can view |
| `messages` | View via chat ownership | Only participants of chat |
| `messages` | Insert as sender (auth.uid() = sender_id) | Can only send as yourself |
| `notifications` | View own (auth.uid() = user_id) | Can only see own notifications |
| `notifications` | Admin ALL | Admin can do anything |
| `sos_alerts` | View public | Anyone can view active alerts |
| `sos_alerts` | Insert own | Can only create own alerts |
| `sos_alerts` | Update own | Can only cancel own alerts |
| `sos_alerts` | Admin ALL | Admin can resolve any alert |
| `road_reports` | View, Insert own, Update own | Standard user ownership |

---

## 21. Storage Buckets

| Bucket | Access Type | Policy | Tests |
|--------|-------------|--------|-------|
| `profile-photos` | Public | Anyone can read, authenticated users can upload/update/delete own | Tests PRO-ED-04, ONB-PRO-02 |
| `user-documents` | Private | Only owner can view/update/delete, authenticated users can upload | Tests DOC-01 through DOC-15 |

### Storage Tests

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| ST-PROF-01 | Upload and view profile photo | Upload a new profile photo | Public URL generated, accessible without auth | P0 |
| ST-DOC-01 | Upload and access document | Upload a document | Signed URL (1hr expiry) generated, accessible | P0 |
| ST-DOC-02 | Document privacy | Try to access another user's document URL | Signed URL works, but RLS prevents viewing without auth | P0 |
| ST-DEL-01 | Delete profile photo | Replace profile photo | Old file overwritten (upsert), no orphaned files | P2 |
| ST-CACHE-01 | Profile photo caching | Update profile photo | New photo loads (consider cache busting with `avatar.jpg` same name) | P2 |

---

## 22. Realtime Subscriptions

| Feature | Stream | Trigger | Tests |
|---------|--------|---------|-------|
| Chat messages | `messages` table stream | INSERT/UPDATE | CHAT-RCV-02 |
| Chat list | `chats` table (via getMyChats) | UPDATE on last_message | CHAT-INB-01 |
| Notifications | `notifications` table stream | INSERT/UPDATE | NOT-REN-01 |
| SOS alerts | `sos_alerts` table stream | INSERT/UPDATE | SOS-ADM-01 |

### Publication Check

- `supabase_realtime` publication includes: `chats`, `messages`, `notifications`
- Verified in database schema: `ALTER PUBLICATION supabase_realtime ADD TABLE`

---

## 23. Edge Cases & Error Handling

### 23.1 Network Failures

| Test ID | Scenario | Expected Behavior | Priority |
|---------|----------|-------------------|----------|
| ERR-NET-01 | No internet - login attempt | Shows clear error, does not crash | P0 |
| ERR-NET-02 | No internet - search | Shows "no connection" message | P0 |
| ERR-NET-03 | No internet - publish ride | Shows error, form data preserved | P0 |
| ERR-NET-04 | No internet - booking | Shows error, does not create partial booking | P0 |
| ERR-NET-05 | No internet - chat messages | Shows offline indicator, messages queued if possible | P2 |
| ERR-NET-06 | Network timeout (slow connection) | Shows timeout error after reasonable delay | P1 |
| ERR-NET-07 | Intermittent connection | Handles disconnect/reconnect gracefully | P1 |

### 23.2 Data Validation

| Test ID | Scenario | Expected Behavior | Priority |
|---------|----------|-------------------|----------|
| ERR-VAL-01 | Supabase returns malformed data | App handles gracefully (`try/catch` in JSON parsing), shows error | P0 |
| ERR-VAL-02 | Null fields from backend | App does not crash on null unexpected fields (Freezed handles nullable) | P0 |
| ERR-VAL-03 | Date in past for new ride | Validation prevents publishing rides with past departure time | P0 |
| ERR-VAL-04 | Special characters in input | Names, descriptions, locations with special chars handled properly | P1 |
| ERR-VAL-05 | Very long text inputs | Bio, description fields handle long text with maxLength enforcement | P2 |

### 23.3 State Edge Cases

| Test ID | Scenario | Expected Behavior | Priority |
|---------|----------|-------------------|----------|
| STATE-01 | Profile setup mid-flight (kill app mid-onboarding) | Returns to correct onboarding screen on restart | P1 |
| STATE-02 | Document upload interrupted | Can re-upload without errors | P1 |
| STATE-03 | Ride expires while viewing details | Ride state changes to 'ongoing'/'completed', UI refreshed | P1 |
| STATE-04 | User banned mid-session | Next action fails with banned error, forced logout | P0 |
| STATE-05 | Multiple devices logged in | Both can see real-time updates via Supabase streams | P2 |
| STATE-06 | Deep link while logged out | Redirects to login, then back to intended destination | P2 |

### 23.4 Race Conditions

| Test ID | Scenario | Expected Behavior | Priority |
|---------|----------|-------------------|----------|
| RACE-01 | Two passengers book last seat simultaneously | `FOR UPDATE` lock in `book_ride_seat` serializes - one succeeds, one gets "Not enough seats" | P0 |
| RACE-02 | Driver and passenger cancel booking simultaneously | `cancel_booking` checks `status = 'confirmed'` - one wins, error for other | P0 |
| RACE-03 | Driver cancels full ride while passenger tries to book | Ride status checked + `FOR UPDATE` lock on booking prevents overlap | P0 |
| RACE-04 | Multiple ride publishes simultaneously | Each insert independent, both succeed with unique UUIDs | P1 |

---

## 24. Performance & Network Conditions

### 24.1 Load & Stress

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| PERF-01 | Search with 1000s of rides | Have large dataset, run search | Results return within acceptable time (<5s) | P1 |
| PERF-02 | Chat with 1000s of messages | Open a chat with many messages | Messages paginate or stream without lag | P1 |
| PERF-03 | Notifications list with hundreds | Large notification history | List scrolls smoothly | P2 |
| PERF-04 | Image loading for many users | Load ride cards with driver photos | Photos cached, loaded efficiently | P1 |

### 24.2 Memory & Rendering

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| PERF-05 | Memory leaks during navigation | Navigate through all screens repeatedly | No memory growth, no OOM crashes | P1 |
| PERF-06 | Hot reload/restart | Flutter dev tools hot reload during development | State preserved, no crashes | P1 |
| PERF-07 | List scrolling performance | Long ride/bookings list | Smooth 60fps scroll (ListView.builder used) | P1 |
| PERF-08 | Map rendering | Map on search/publish screens | Tiles render smoothly, no tile caching issues | P2 |

---

## 25. Security & Privacy

| Test ID | Description | Steps | Expected Result | Priority |
|---------|-------------|-------|----------------|----------|
| SEC-RLS-01 | Passenger cannot see other passenger's bookings for same ride | Query bookings not belonging to user | RLS blocks access | P0 |
| SEC-RLS-02 | Cannot update another user's profile | Try to update `users` where id != auth.uid() | RLS blocks | P0 |
| SEC-RLS-03 | Cannot delete another user's ride | Try to delete ride where driver_id != auth.uid() | RLS blocks | P0 |
| SEC-RLS-04 | Cannot read private documents of other users | Try to access `user-documents` bucket path | RLS blocks | P0 |
| SEC-RLS-05 | Non-admin cannot access admin panel | Navigate to `/admin` | Redirected | P0 |
| SEC-RLS-06 | Admin can override all policies | Admin CRUD operations on any entity | Succeeds via `is_admin_v2()` policies | P0 |
| SEC-PHONE-01 | Phone number privacy | Passenger phone only visible to driver of booked ride | RLS on `bookings.passenger_phone` | P1 |
| SEC-API-02 | Supabase anon key exposed in `.env` | Verify key has limited RLS-only permissions | No server-side key exposure | P0 |
| SEC-AUTH-03 | Session hijacking attempt | Use another user's auth token | Blocked by Supabase auth, not by RLS | P0 |
| SEC-XSS-04 | Input sanitization | Enter HTML/JS in name, bio, description fields, view on UI | Flutter renders as plain text (no innerHTML), safe | P1 |

---

## 26. Smoke Test Checklist

> Quick pass through all critical user journeys. Run before every release.

- [ ] **S.0** App launches from fresh install
- [ ] **S.1** Sign up with new email+password → OTP verification → Profile setup → Vehicle setup → Home screen
- [ ] **S.2** Login with existing credentials → Navigate to home
- [ ] **S.3** Search for a ride (from/to + date) → Results displayed → Select a ride
- [ ] **S.4** View ride details → Book ride → Confirmation shown
- [ ] **S.5** Driver receives booking notification
- [ ] **S.6** My Bookings → View booking details
- [ ] **S.7** Publish a ride (driver) → Ride appears in search results
- [ ] **S.8** My Rides → View passengers → Cancel a booking
- [ ] **S.9** Cancel full ride → All passengers notified
- [ ] **S.10** Chat between driver and passenger → Messages sent/received in real-time
- [ ] **S.11** Profile → Edit name → Photo upload → Save
- [ ] **S.12** Upload documents for verification → Status shows "pending"
- [ ] **S.13** Notifications → View list → Mark as read → Unread count updates
- [ ] **S.14** SOS trigger → Emergency alert created → Cancel SOS
- [ ] **S.15** Admin: review documents → approve/reject
- [ ] **S.16** Sign out → Returns to welcome screen → Cannot access authenticated routes
- [ ] **S.17** Kill app, reopen → User stays logged in → Returns to last screen

---

## Appendix A: Data Model Reference

### Entity: `UserModel`

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `id` | String (UUID) | required | References auth.users |
| `full_name` | String? | null | |
| `phone` | String? | null | |
| `email` | String? | null | |
| `photo_url` | String? | null | Public bucket URL |
| `bio` | String? | null | |
| `rating` | double | 5.0 | Auto-calculated via `update_user_rating()` |
| `total_rides_given` | int | 0 | |
| `total_rides_taken` | int | 0 | |
| `is_admin` | bool | false | |
| `is_banned` | bool | false | |
| `setup_complete` | bool | false | |
| `vehicle_model` | String? | null | |
| `vehicle_license_plate` | String? | null | |
| `vehicle_color` | String? | null | |
| `vehicle_type` | String? | null | Car, Bike, Van |
| `doc_driving_license_front` | String? | null | Storage path |
| `doc_driving_license_back` | String? | null | |
| `doc_vehicle_rc` | String? | null | |
| `doc_verification_status` | String | 'not_submitted' | not_submitted/pending/approved/rejected |
| `doc_rejection_reason` | String? | null | |
| `driving_license_number` | String? | null | |
| `puc_number` | String? | null | |
| `insurance_number` | String? | null | |
| `pref_no_smoking` | bool | false | |
| `pref_no_music` | bool | false | |
| `pref_no_heavy_luggage` | bool | false | |
| `pref_no_pets` | bool | false | |
| `pref_negotiation` | bool | false | |

### Entity: `RideModel`

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `id` | String (UUID) | required | |
| `driver_id` | String (UUID) | required | FK users |
| `driver_name` | String | required | Snapshot of driver name |
| `from_location` | String | required | |
| `to_location` | String | required | |
| `from_lat/from_lng` | double | null | |
| `to_lat/to_lng` | double | null | |
| `route_points` | List\<Map> | null | JSONB array of {lat, lng} |
| `departure_datetime` | DateTime | required | |
| `available_seats` | int | required | Decremented on booking |
| `total_seats` | int | required | |
| `price_per_seat` | double | required | |
| `segment_price` | double | null | Calculated at search time |
| `distance_km` | double | null | |
| `duration_mins` | int | null | |
| `rule_no_smoking` | bool | false | |
| `rule_no_music` | bool | false | |
| `rule_no_heavy_luggage` | bool | false | |
| `rule_no_pets` | bool | false | |
| `rule_negotiation` | bool | false | |
| `status` | String | 'active' | active/full/completed/cancelled |

### Entity: `BookingModel`

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `id` | String (UUID) | required | |
| `ride_id` | String (UUID) | required | FK rides |
| `passenger_id` | String (UUID) | required | FK users |
| `driver_id` | String (UUID) | required | FK users |
| `passenger_name` | String | required | |
| `passenger_phone` | String? | null | |
| `from_location/to_location` | String? | null | Pickup/dropoff |
| `from_lat/from_lng/to_lat/to_lng` | double | null | Coordinates |
| `seats_booked` | int | 1 | |
| `total_price` | double | required | |
| `status` | String | 'confirmed' | confirmed/cancelled/completed |
| `booked_at` | DateTime | NOW() | |
| `cancelled_at` | DateTime? | null | |
| `cancel_reason` | String? | null | |

### Entity: `MessageModel`

| Entity | Description |
|--------|-------------|
| `MessageModel` | id, chat_id, sender_id, text, is_read, created_at |

### Entity: `NotificationModel`

| Entity | Description |
|--------|-------------|
| `Notification` (in-app) | id, user_id, title, message, type, is_read, ride_id, booking_id, created_at |

### Entity: `SOSAlertModel`

| Entity | Description |
|--------|-------------|
| `SOSAlertModel` | id, user_id, user_name, latitude, longitude, location_name, emergency_type, is_active, created_at, resolved_at, resolved_by |

### Entity: `ReviewModel`

| Entity | Description |
|--------|-------------|
| `ReviewModel` | id, ride_id, booking_id, reviewer_id, reviewee_id, rating (1-5), comment, created_at |

### Entity: `RoadReportModel`

| Entity | Description |
|--------|-------------|
| `RoadReportModel` | id, report_type, description, latitude, longitude, reported_by, cleared_votes, expires_at, created_at |

---

## Appendix B: State Providers Reference

| Provider | Type | Purpose |
|----------|------|---------|
| `authProvider` | Riverpod | Current user auth state, login/logout |
| `locationProvider` | Riverpod | GPS location state |
| `bookingProvider` | Riverpod | Booking state for user |
| `rideProvider` | Riverpod | Rides state, search results |
| `notificationProvider` | Riverpod | Notification list and unread count |
| `chatProvider` | Riverpod | Chat inbox state |
| `localeProvider` | Riverpod | Current language locale |
| `adminProvider` | Riverpod | Admin panel state |

---

## Appendix C: Route Map

```
/                        → SplashScreen
/welcome                 → WelcomeScreen (unauthenticated)
/login                   → LoginScreen
/signup                  → SignupScreen
/otp                     → OTPScreen (phone number via state.extra)
/profile-setup           → ProfileSetupScreen
/vehicle-setup           → VehicleSetupScreen
/home                    → HomeScreen (in MainScreen shell)
/my-bookings             → MyBookingsScreen (in MainScreen shell)
/my-rides                → MyRidesScreen (in MainScreen shell)
/profile                 → ProfileScreen (in MainScreen shell)
/search                  → SearchRidesScreen (root nav)
/ride-details/:id        → RideDetailsScreen (root nav)
/publish                 → PublishRideScreen (root nav)
/booking-detail/:id      → BookingDetailScreen (root nav)
/ride-passengers/:id     → RidePassengersScreen (root nav)
/chat/:chatId            → ChatScreen (root nav)
/edit-profile            → EditProfileScreen (root nav)
/documents               → DocumentsScreen (root nav)
/notifications           → NotificationsScreen (root nav)
/reports                 → ReportsScreen (root nav)
/admin                   → AdminDashboardScreen (in AdminShell)
/admin/users             → AdminUsersScreen (in AdminShell)
/admin/documents         → AdminDocumentsScreen (in AdminShell)
/admin/sos               → AdminSOSScreen (in AdminShell)
/admin/rides             → AdminRidesScreen (in AdminShell)
```

---

## Appendix D: External Dependencies

| Dependency | Purpose | Critical? |
|------------|---------|-----------|
| `supabase_flutter` | Backend database, auth, realtime, storage | Yes |
| `go_router` | Navigation & route guards | Yes |
| `flutter_riverpod` | State management | Yes |
| `flutter_map` | Map display | Yes |
| `geolocator` | GPS location | Yes |
| `geocoding` | Address ↔ coordinates conversion | Yes |
| `onesignal_flutter` | Push notifications | Yes |
| `image_picker` | Photo/document selection | Yes |
| `shared_preferences` | Local storage | Yes |
| `http` | OneSignal REST API calls | Yes |
| `flutter_localizations` | i18n support | Yes |
| `freezed` | Immutable data classes | Yes (dev) |
| `cached_network_image` | Image caching | No |
| `lottie` | Animations | No |
| `timeago` | Relative time formatting | No |
| `pinput` | OTP input | No |
| `url_launcher` | External URL handling | No |
| `share_plus` | Share functionality | No |

---

## Appendix E: Test File Inventory (Existing)

| File | Coverage |
|------|----------|
| `integration_test/app_test.dart` | Basic UI and flow tests |
| `integration_test/stress_automation_test.dart` | Stress and automated flow tests |
| `test/logic_verification_test.dart` | Unit tests for business logic |
| `test/publish_ride_screen_test.dart` | Publish ride screen widget/business tests |
| `test/ride_search_logic_test.dart` | Search algorithm tests |
| `test/unit/services/ride_service_test.dart` | RideService unit tests |
| `test/widget_test.dart` | Basic widget test |

---

*End of Test Plan - 200+ individual test cases across 26 sections*
