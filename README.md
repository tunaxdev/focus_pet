# Focus Pet

A gamified study companion for students, built with Flutter. Plan your week of classes and assignments, run focus sessions with ambient sounds, and keep a virtual pet happy by actually getting work done: every focused minute earns XP and coins that you can spend on your pet.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?logo=dart&logoColor=white)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-555)
![License](https://img.shields.io/badge/license-MIT-green)

<!-- SCREENSHOTS -->

## Features

### 📅 My Week: courses and deadlines
- Add courses with one or more weekly sessions (day, start and end time, location).
- A weekly calendar shows the selected day's schedule at a glance.
- Each course has its own task list with due dates. Tasks can be added, edited, completed and deleted.
- An **Upcoming Deadlines** section highlights tasks due in the next 7 days.

### 🎯 Focus mode
- Pomodoro-style timer with an adjustable session length and a circular progress indicator.
- Ambient soundscapes (rain, fireplace, café, white noise) that loop during a session.
- Keeps the screen awake while focusing, with optional haptic feedback.
- **Anti-distraction check:** if you leave the app for more than 10 seconds during a session, the timer pauses.
- Daily focus goal (30–120 min), daily quests and a reward summary when a session ends.
- A local notification is sent when a session completes.

### 🐾 My Pet
- Completing focus sessions earns **XP** (5 per minute) and **coins**, and levels up your pet.
- Hunger and happiness stats change over time: the pet gets hungrier and a little sadder each new day.
- Spend coins to feed the pet, or play with it to raise its happiness.
- A streak counter rewards consistent daily focus.

### ⚙️ Settings
- Username, light/dark theme, haptic feedback and language preference.
- All data is stored locally on the device; no account is needed.

## Tech Stack

| Area | Technology |
| --- | --- |
| Framework | Flutter (Material 3), Dart |
| State management | `provider` (`ChangeNotifier`) |
| Persistence | `shared_preferences` (JSON-serialized models) |
| Audio | `audioplayers` |
| Notifications | `flutter_local_notifications`, `timezone` |
| Utilities | `wakelock_plus`, `intl` |

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App strings
│   └── theme/              # Colors and theme
├── features/
│   ├── dashboard/          # My Week: schedule, courses, tasks, deadlines
│   ├── focus_mode/         # Timer, ambient sounds, quests and rewards
│   ├── pet_room/           # Virtual pet: feed, play, stats
│   ├── onboarding/         # Welcome screen
│   └── settings/           # User preferences
├── models/                 # Course, schedule, task and pet models
├── providers/              # Course, focus, pet and settings state
├── services/               # Local notifications
└── main.dart               # App entry point and providers
assets/
└── sounds/                 # Ambient sound loops
```

The app follows a feature-first structure. Each screen reads and updates state through providers, and the providers persist their data with `shared_preferences`.

## Getting Started

**Requirements:** Flutter SDK with Dart 3.9 or newer.

```bash
git clone https://github.com/tunaxdev/focus_pet.git
cd focus_pet
flutter pub get
flutter run
```

To run in a browser, use `flutter run -d chrome`. Local notifications are only available on mobile and desktop.

## Roadmap

- Pet artwork that evolves with level (currently shown as an icon)
- Statistics screen with weekly and monthly focus history
- Localization (Turkish and English)

## License

This project is licensed under the [MIT License](LICENSE).
