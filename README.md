## Gen Finance (iOS)

A SwiftUI-based personal finance toolkit. The first tool included is a FIRE (Financial Independence, Retire Early) calculator that helps you estimate the retirement corpus you’ll need and projects your corpus growth based on your current and future investments.

---

### Features
- **FIRE Calculator**: Input current age, retirement age, expected monthly expenses, safe withdrawal rate, and inflation.
- **Investments modeling**: Add multiple investments with lumpsum, monthly SIP, expected return, and yearly increment.
- **Results view**: See required corpus vs projected corpus with animated numbers and a yearly corpus chart (Swift Charts).
- **Delightful UI**: Themed UI with subtle animations, blur, and gradients.
- **State persistence**: Inputs are preserved between app launches via AppStorage.
- **Splash screen**: Lightweight animated splash.

---

### Requirements
- **Xcode**: 15 or later
- **iOS**: 17.0 or later (SwiftUI/SwiftData/Charts used)
- **Swift**: 5.9+

---

### Getting Started
1. Open the project:
   - Double-click `Gen Finance.xcodeproj`.
2. Select the `Gen Finance` scheme and choose an iOS Simulator or device.
3. Press Run (⌘R).

No additional configuration is required.

---

### Usage
- Launch the app to see the list of tools. Start with the "Fire Calculator".
- Fill in:
  - Current age and Retirement age
  - Expected Monthly expense (today’s value)
  - Expected Withdrawal Rate from corpus (e.g., 4%)
  - Expected Annual Inflation
- Add one or more investments:
  - Lumpsum amount
  - Monthly contribution (SIP)
  - Expected yearly return
  - Expected yearly increase in contribution
- Tap "Calculate FIRE Corpus" to view:
  - Required FIRE corpus (inflation-adjusted)
  - Projected corpus at retirement (from all investments)
  - Yearly corpus chart with a rule mark for the required corpus

Use the Reset button in the top-right to restore defaults.

---

### Screenshots
Add screenshots into `docs/images/` and they'll render here.

- Calculator Form

  <img src="docs/images/calculator-form.png" alt="Calculator Form" height="300" />

- FIRE Results

  <img src="docs/images/fire-results.png" alt="FIRE Results" height="300" />

- Yearly Corpus Chart

  <img src="docs/images/yearly-corpus-chart.png" alt="Yearly Corpus Chart" height="300" />

---

### Tech Stack
- **SwiftUI** for UI
- **Swift Charts** for the corpus chart
- **AppStorage** for lightweight persistence
- **SwiftData** model container is initialized for future expansion

---

### Contributing
- Fork the repo and create a feature branch.
- Make your changes with clear commit messages.
- Open a Pull Request describing the change and any UI impacts.

---

### License
This project is provided under the MIT License. See `LICENSE` if/when added.

---

### Notes
- The calculator provides estimates only; do not treat as financial advice.
