
# 🌌 NoteSphere
**A place where your notes persevere.**

**NoteSphere** is the ultimate note-taking application, designed to make your ideas, thoughts, and memories live, grow, and endure. Built with *Flutter*, it combines performance, organization, and elegance in a fully offline, open-source solution.



## 🚀 Why NoteSphere?

- 💾 Notes that last: Offline-first storage with SQLite, ensuring your data stays on your device.

- 🏗️ Professional Organization: Built with Clean Architecture and a feature-first structure for maximum scalability.

- ⚡ Premium Performance: State management powered by Riverpod for a reactive and smooth experience.

- 🎨 Minimalist & Functional: A clean, clutter-free UI designed for seamless daily use.

- 🔓 Open-Source & Extensible: Built for the community—free to study, modify, and improve.


## ✨ Features

- Instant CRUD: Create, read, and list notes with zero latency.

- Offline-First: Robust persistence using a local notes.db.

- Reactive UI: The list refreshes automatically as soon as you add a new note.

- Quick Action: Add sample notes instantly via the Floating Action Button.

- Modular Design: Clean separation of concerns where each feature is self-contained.
##  🛠️ Tech Stack & Dependencies


| Tool | Purpose   | 
| :-------- | :------- | 
| `Flutter` | Cross-platform UI Framework |
| `Riverpod` | Reactive State Management |
| `SQFlite` | Local SQL Database persistence |
| `UUID` | Unique identifier generation |
| `Path Provider` | Secure file system access |




## 📂Project Structure

```lib/
├── core/                 # Shared utilities, themes, and constants
├── features/
│   └── notes/            # Notes Feature Module
│       ├── data/         # Repositories & SQLite implementation
│       ├── domain/       # Entities & Repository interfaces (Business Logic)
│       └── presentation/ # UI Widgets & Riverpod Controllers
└── main.dart             # Application entry point
```
## ⚙️ Installation

Ready to get started? Follow these steps:
1. **Clone the repository :**

    ```bash
    git clone <https://github.com/DeadlyISwitch/NoteSphere>
    cd NoteSphere
    ```

2. **Install dependencies :**

    ```bash
    flutter pub get
    ```

3. **Run the application :**

    ```bash
    flutter run
    ```

## 📖 Usage

1. Launch the app to see your (initially empty) note board.

2. Tap the Floating Action Button (+) to generate a sample note.

3. Observe how the note is instantly persisted in SQLite and displayed on your screen.

4. Restart the app, your notes will still be there!
## 🤝 Contributing

Contributions make the community amazing! Whether it's a bug fix or a new feature:


1. Fork the project.

2. Create a branch (`git checkout -b feature/AmazingFeature`).

3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).

4. Push to the branch (`git push origin feature/AmazingFeature`).

5. Open a Pull Request.

[!IMPORTANT] Please ensure `flutter analyze` and `flutter` test pass before submission.
## 💻 Development Stack

![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2?style=flat-square&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-Database-003B57?style=flat-square&logo=sqlite&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-4A90E2?style=flat-square)
![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-success?style=flat-square)
![Offline First](https://img.shields.io/badge/Offline-First-important?style=flat-square)
![Open Source](https://img.shields.io/badge/Open%20Source-Community-brightgreen?style=flat-square)

