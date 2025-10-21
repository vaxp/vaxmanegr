## ⚙️ Vaxmanager - Official Task Manager for VAXP-OS

### 🚀 Overview & Description

Vaxmanager is the official, internally developed Task Manager for the VAXP-OS distribution. It is designed to provide comprehensive monitoring of system performance and processes with a modern, fast user interface.

The application is built using the Flutter framework and follows the Clean Architecture approach, ensuring high efficiency and responsiveness. Vaxmanager utilizes the powerful `flutter_bloc` library for state management and real-time system data handling.

---

### ✨ Key Features

- **Full Integration with VAXP-OS:**
  - Dark Theme matching the distribution's aesthetics for a consistent and attractive experience.
- **Comprehensive Resource Monitoring:**
  - Displays clear, up-to-date summaries of CPU, memory, network traffic, and disk activity.
- **Advanced Process Management:**
  - Provides a detailed list of running processes, including process name, CPU usage, and RAM consumption.
- **Quick Actions for Processes:**
  - Direct options for any selected process, including: Kill Process, Show Log, and Restart Process.
- **Robust Technical Structure:**
  - Built on Clean Architecture and uses `flutter_bloc` for reliable, continuous system data updates.

---

### 🖼️ Screenshots
- System and process overview
- Process management options

---

### 🛠️ Installation & Build

The application is open source and available in the official GitHub repository: [https://github.com/vaxp/vaxmanegr](https://github.com/vaxp/vaxmanegr)

#### VAXP-OS (Official Distribution)
Vaxmanager is integrated and pre-installed in all VAXP-OS releases as a core system monitoring tool. No additional installation is required for users.

#### Build from Source (For Developers)
Since the application is built with Flutter, building it requires the Flutter SDK development environment.

**Clone the repository:**
```bash
git clone https://github.com/vaxp/vaxmanegr
cd vaxmanegr
```

**Get dependencies:**
```bash
flutter pub get
```

**Build and install on Linux/GNOME:**
```bash
flutter build linux
```

---

### 📜 License
This application is licensed under the GNU GPLv3.