# DeathWatch

A WatchOS application that counts down to a significant date in your life. DeathWatch provides a visual reminder of time passing, allowing you to maintain perspective on life's finite nature.

## Overview

DeathWatch is a minimalist countdown application for Apple Watch that keeps track of how much time remains until a date you specify. The app displays the countdown in hours, days, and weeks remaining, serving as a philosophical tool for mindfulness and intentional living.

## Features

- **Precise Countdown**: Track remaining hours, days, and weeks until your target date
- **Custom Date Setting**: Set and store a personalized target date
- **Watch Complications**: View your countdown directly on your watch face
- **Widget Extension**: "LifeCountdownWidget" provides at-a-glance information

## Requirements

- Apple Watch with watchOS 11.2 or later
- Xcode 16.2 or later for development

## Installation

### App Store
*Coming soon*

### Manual Installation (Development)

1. Clone the repository:
```bash
git clone https://github.com/nathan-eagle/DeathWatch.git
```

2. Open the project in Xcode:
```bash
cd DeathWatch
open DeathWatch.xcodeproj
```

3. Build and run the project on your Apple Watch or simulator:
   - Select the "DeathWatch Watch App" scheme
   - Choose your target device
   - Press Run (⌘+R)

## Usage

1. **Launch the app** on your Apple Watch
2. **View your countdown** displayed in various time measurements
3. **Configure your target date** through the settings menu
4. **Add complications** to your watch face for continuous awareness

## Configuration

### Setting Your Target Date

By default, the app uses December 21, 2056 as the target date. To change this:

1. Open the app on your Apple Watch
2. Navigate to the settings screen
3. Select "Set Target Date"
4. Choose your personally meaningful date

### Widget Configuration

1. Add the "LifeCountdownWidget" to your watch face
2. Select your preferred display style from the available options

## Technical Information

- **Framework**: SwiftUI
- **Minimum Deployment Target**: watchOS 11.2
- **Architecture**: The app uses a data model (CountdownData) to manage date calculations
- **Storage**: Target dates are saved using UserDefaults for persistence
- **Shared Data**: Uses App Groups (group.AerieVentures.DeathWatch) for sharing data between the main app and widget

## Project Structure

- **DeathWatch Watch App**: Main application code
- **LifeCountdownWidget**: Widget extension for displaying the countdown on watch faces
- **Testing components**: Includes unit and UI test targets

## About

DeathWatch was created as a modern interpretation of the memento mori concept - a reminder of mortality that encourages living a more meaningful life. By maintaining awareness of time's passage, users can make more intentional choices about how they spend their days.

## License

This project is licensed under standard copyright law. All rights reserved.

## Contact

Developed by Nathan Eagle