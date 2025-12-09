# PickMyTask - Technical Assessment

A Flutter project showcasing a complete **Location Tracking Feature** built with the **MVVM architecture** and **Provider**.  
The application retrieves the user's current GPS coordinates, converts them into a readable address, listens to real-time location changes and maintains a history of visited locations.

## Features

- 📍 **Get Current Location** using Geolocator  
- 🏙️ **Reverse Geocoding** (city, state, pincode) via Google Geocoding API  
- 🔄 **Real-Time Tracking** using position streams  
- 🕒 **Last Updated Timestamp** for every location update  
- 🗂️ **Location History** stored in-memory (no database)  
- 🧭 **Open Location in Google Maps** using url_launcher  
- 🔐 **Secure API Key Loading** using flutter_dotenv  
- 🧱 **MVVM + Provider Architecture** for clean separation of layers  

## Architecture

The project follows a modular MVVM approach:

- **Repository**  
  Handles permissions, GPS access, reverse geocoding and streams.

- **ViewModel**  
  Maintains current location state, performs updates, caches addresses and exposes observable data for UI.

- **View (UI)**  
  Renders current coordinates, address, controls for tracking and history list.

## APIs & Packages Used

- **Geolocator** – fetch GPS location, request permission, track movement  
- **Google Geocoding API** – convert coordinates to human-readable address  
- **Provider** – state management for MVVM  
- **url_launcher** – open coordinates in Google Maps  
- **flutter_dotenv** – load API keys securely from `.env`  

## Experience Summary

My experience with Flutter architecture, async streams, API integration and state management helped build this feature efficiently.  
Understanding MVVM allowed clean separation of UI, logic and data handling, while experience with real device location handling ensured smooth and accurate tracking.
