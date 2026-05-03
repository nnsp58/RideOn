# 📋 RideOn: Business, Legal & Release Checklist

This document serves as the master checklist for all non-coding tasks required before officially launching the RideOn application. It covers legal protection for the founder, infrastructure setup, version control, and Play Store requirements.

---

## 🛡️ 1. Legal, Policy & Liability Protection (Founder's Protection)
To ensure the founders are protected from police harassment or legal liabilities in case of accidents, illegal activities, or commercial registration disputes.

### Important Digital Agreement (To be shown during Signup/Publish Ride)
**English Translation of the core protection clause:**
> *"I understand that RideOn is strictly a cost-sharing platform, not a commercial taxi service. I am personally responsible for my vehicle's insurance, adherence to traffic rules, and the safety of my passengers. RideOn, its parent company, and its founders act solely as an intermediary (aggregator) and bear no legal liability for any incidents, accidents, or disputes that occur during the trip."*

- [ ] **Terms & Conditions (T&C):** Must include the "Intermediary Status" (IT Act Section 79) and the exact clause mentioned above. Users must check a box agreeing to this.
- [ ] **Zero Profit / Cost-Sharing Policy:** Clearly state that the app is for sharing fuel/toll costs. Using white-plate private cars for profit is illegal; RideOn only facilitates cost-sharing.
- [ ] **Privacy Policy:** Required by Google Play Store. Must explain why background location, camera (for RC/DL), and personal data are collected, and state that data will be shared with law enforcement if a valid legal request is made.
- [ ] **Copyright & Trademark:** Register the "RideOn" brand name and logo to prevent copyright strikes from competitors.

---

## 🎛️ 2. Admin Panel & Moderation (Safety Controls)
- [ ] **User Suspension:** Ability to instantly block/ban users or drivers reported for bad behavior.
- [ ] **Document Verification (KYC):** System to manually or automatically verify Driving Licenses (DL) and Vehicle Registration (RC).
- [ ] **Police Report Export:** A 1-click feature to download a trip's complete history (Driver details, passenger details, route, timestamps) in PDF format to hand over to police if requested.
- [ ] **SOS Monitoring:** Admin dashboard alert when a passenger presses the in-app SOS button.

---

## ☁️ 3. Infrastructure & Version Control
- [ ] **Git & GitHub (Version Control):** Ensure the entire codebase is pushed to a Private GitHub repository. Create branches for new features (`feature/payment`, `feature/google-login`) so the main app is never broken.
- [ ] **Supabase Backups:** Enable automated database backups to prevent data loss.
- [ ] **Firebase Production Setup:** Lock down Firebase security rules so malicious users cannot write directly to the database.
- [ ] **Environment Variables (.env):** Ensure all API Keys (Google Maps, Supabase, Firebase) are secured and never exposed in public repositories.

---

## 🚀 4. Google Play Store & Deployment
- [ ] **Google Developer Account:** Create an account ($25 one-time fee).
- [ ] **20 Testers Rule (Closed Testing):** Google's new policy requires 20 people to test the app continuously for 14 days before it can go public.
- [ ] **Store Assets:** 
  - 512x512 High-Res App Icon
  - 1024x500 Feature Graphic
  - 3-8 Phone Screenshots
  - Privacy Policy URL hosted on a website.
- [ ] **Location Permission Video:** Since RideOn tracks location in the background (for live rides), Google will ask for a video proof of why this permission is needed. Record a screen capture of the app using the location.
- [ ] **App Bundles:** Build a production-ready `.aab` (Android App Bundle) with ProGuard (`minifyEnabled true`) to make the app smaller and secure the code from reverse engineering.

---
*Note: Keep updating this file as items are completed.*
