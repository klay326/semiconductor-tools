# Semiconductor Tools

A comprehensive iOS application built with SwiftUI designed to streamline semiconductor product test engineering workflows. This toolkit provides essential calculators and reference tools for engineers working in semiconductor manufacturing and quality assurance.

## 📱 Overview

**Semiconductor Tools** is an all-in-one companion app for product test engineers in the semiconductor industry. It combines multiple specialized calculators and reference tables into one intuitive, easy-to-use interface.

**Platforms:** iOS 15+  
**Built with:** Swift, SwiftUI, Xcode  
**Architecture:** MVVM with SwiftUI Data Persistence

---

## 🛠️ Features

### 1. **Yield Binning Calculator**
Track and analyze semiconductor wafer yields with customizable test bins.

**Key Capabilities:**
- Create wafer/lot records with die test data
- Define custom bins (default: Good, Fail, Marginal) with color coding
- Automatic calculations:
  - Overall yield percentage
  - Per-bin distribution percentages
  - Defects Per Million (DPM) per bin
  - Total die counts and summaries
- Multi-wafer trend tracking across lots
- Historical data persistence
- Bin management interface for custom configurations

**Perfect for:**
- Tracking production yields across wafers
- Identifying problem bins or test anomalies
- Building trend reports for quality management
- Meeting quality metrics

---

### 2. **Parametric Test Spec Calculator**
Define test specifications and verify measured values against limits in real-time.

**Key Capabilities:**
- Create test specs with custom min/max limits
- Support for multiple measurement units (V, mV, A, mA, μA, Ω, kΩ, Hz, MHz, GHz, ns, μs)
- Quick measurement entry with automatic timestamps
- Pass/Fail status indicators:
  - ✅ Green: Within spec limits
  - ❌ Red: Out of spec
  - ⭕ Gray: No measurements yet
- Test margin calculation (distance from limits as percentage)
- Measurement history tracking
- Persistent storage of all specs and measurements

**Perfect for:**
- Defining device specifications before testing
- Verifying measured values meet requirements
- Tracking test margins and identifying marginal parts
- Building parametric test data records

---

### 3. **Statistical Analysis Tool**
Perform statistical calculations on data sets with process capability analysis.

**Key Capabilities:**
- Create named data sets and add individual measurements
- Automatic calculations:
  - Count, Mean, Median
  - Standard Deviation, Variance
  - Min, Max, Range
  - **Cpk Index** (Process Capability Index)
  - **Ppk Index** (Performance Capability Index)
- Color-coded capability status:
  - 🟢 Green (≥1.33): Process is capable
  - 🟠 Orange (1.0-1.33): Process is marginal
  - 🔴 Red (<1.0): Process is not capable
- Custom LSL/USL (Lower/Upper Spec Limit) support
- Full measurement history and data review

**Perfect for:**
- Analyzing production test data distributions
- Calculating process capability metrics
- Identifying process stability issues
- Generating statistical reports for quality teams

---

### 4. **Test Time Calculator**
Estimate total test time and production throughput based on test profiles.

**Key Capabilities:**
- Create test profiles with multiple sequential test steps
- Define step duration (seconds, minutes, hours)
- Automatic calculations:
  - Time per device
  - Total test time for N devices
  - Parallel testing support (divide by number of parallel slots)
  - **Throughput calculation** (devices per hour)
- Real-time calculator with instant results
- Save and reuse test profiles

**Perfect for:**
- Planning test schedules
- Estimating production capacity
- Optimizing test sequences
- Calculating test cost per device

---

### 5. **Period/Frequency Converter**
Convert between time periods and frequencies with full bidirectional support.

**Key Capabilities:**
- **Bi-directional conversion:**
  - Period → Frequency
  - Frequency → Period
- Time units supported: nanoseconds (ns), microseconds (μs), milliseconds (ms), seconds (s)
- Frequency units supported: Hz, kHz, MHz, GHz
- Real-time calculation as you type
- Toggle between conversion modes instantly
- No data persistence (pure calculator tool)

**Perfect for:**
- Signal timing analysis
- RF/clock frequency calculations
- Digital signal integrity verification
- Quick frequency-to-period conversions

---

### 6. **Reference Tables**
Quick lookup of common semiconductor test parameters, standards, and thresholds.

**Included Tables:**

1. **Common Voltage Thresholds** - Logic level specifications for 5V, 3.3V, 1.8V CMOS
2. **Common Current Limits** - Leakage, supply, drive, and ESD thresholds
3. **Common Frequency Standards** - Crystal, audio, USB, DDR, PCIe standards
4. **Standard Temperature Ranges** - Commercial, industrial, automotive, military grades
5. **Power Consumption Classes** - Ultra-low to high-power classifications
6. **Common Resistor Values** - E12 series standard resistor values
7. **Common Capacitor Values** - Pico to micro farad capacitor values
8. **Signal Integrity Standards** - Setup/hold times, rise/fall time specifications

**Key Capabilities:**
- 🔍 Search across all reference tables
- 📋 Browse by category
- 📱 Tap for detailed descriptions and context
- ⚡ Instant lookup for quick reference

**Perfect for:**
- Quick spec lookups during testing
- Verifying standard values
- Reference during design reviews
- Training new test engineers

---

## 🎨 Interface Design

### Home Screen
The app features a scalable grid-based home screen with tile cards for each tool. Each tool is represented by:
- **Color-coded card** for quick visual identification
- **System icon** representing the tool's function
- **Tool name and description**
- **Navigation chevron** for easy access

The 2-column grid layout scales seamlessly as more tools are added in the future.

### Data Management
- **Persistent Storage:** All data is automatically saved using UserDefaults
- **Batch Operations:** Easily manage, edit, and delete records
- **Data Export Ready:** Structure supports future CSV/PDF export capabilities

---

## 🚀 Getting Started

### Prerequisites
- iOS 15.0 or later
- Xcode 13.0 or later
- Swift 5.5+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/klay326/semiconductor-tools.git
```

2. Open the project in Xcode:
```bash
cd semiconductor-tools
open "semiconductor tools.xcodeproj"
```

3. Build and run on your iOS device or simulator:
   - Select your target device
   - Press `Cmd + R` to build and run

---

## 📁 Project Structure

```
semiconductor-tools/
├── Models/
│   ├── EnhancedYieldModel.swift          # Yield binning data model
│   ├── ParametricSpecModel.swift         # Parametric specs model
│   ├── PeriodFrequencyModel.swift        # Period/frequency conversion
│   ├── ReferenceTablesModel.swift        # Reference data tables
│   ├── StatisticalAnalysisModel.swift    # Statistical calculations
│   ├── TestTimeCalculatorModel.swift     # Test time estimation
│   └── WaferDieModel.swift               # Legacy wafer/die model
│
├── Views/
│   ├── HomeView.swift                    # Main navigation grid
│   ├── EnhancedYieldCalculatorView.swift # Yield binning interface
│   ├── ParametricSpecCalculatorView.swift# Parametric specs interface
│   ├── PeriodFrequencyCalculatorView.swift # Period/frequency converter
│   ├── ReferenceTablesView.swift         # Reference tables interface
│   ├── StatisticalAnalysisView.swift     # Statistics interface
│   └── TestTimeCalculatorView.swift      # Test time calculator interface
│
├── ContentView.swift                     # App root view
├── semiconductor_toolsApp.swift          # App entry point
└── Assets.xcassets/                      # App icons and colors
```

---

## 💾 Data Persistence

All calculator data is automatically persisted using iOS UserDefaults:
- **Yield Binning:** Wafer records, custom bins, historical data
- **Parametric Specs:** Test specs, measurements, and historical data
- **Statistical Analysis:** Data sets and calculated statistics
- **Test Time:** Saved test profiles and calculations
- **Reference Tables:** Pre-populated with standard values

Data persists between app sessions and survives app updates.

---

## 🔧 Future Enhancements

Planned features for future releases:
- 📊 **Data Export:** CSV/PDF report generation
- 📈 **Charting:** Visual representations of yields, statistics, and trends
- ☁️ **Cloud Sync:** iCloud integration for multi-device support
- 📱 **iPad Support:** Optimized iPad interface with larger screens
- 🔔 **Alerts:** Notifications for out-of-spec conditions
- 📚 **Defect Tracking:** Root cause analysis tool
- 🌐 **Web Companion:** Desktop dashboard for data review
- 🔐 **Data Security:** Encrypted storage for sensitive specs

---

## 📊 Use Cases

### Scenario 1: Daily Yield Tracking
A test engineer uses the **Yield Binning Calculator** to track wafer results throughout the day:
1. Create a new wafer record with lot number
2. Enter die counts for each bin (Good, Fail, Marginal)
3. Review yield % and DPM at a glance
4. Compare with previous wafers to identify trends

### Scenario 2: Spec Verification During Test
A test technician uses the **Parametric Specs Calculator**:
1. Retrieve stored specs for the device under test
2. Enter measured values as tests complete
3. Instantly see pass/fail status and test margins
4. Flag marginal parts for further analysis

### Scenario 3: Statistical Process Control
A quality engineer uses the **Statistical Analysis Tool**:
1. Load test data from a batch of devices
2. Calculate Cpk/Ppk to verify process capability
3. Identify if process is in statistical control
4. Generate reports for management

### Scenario 4: Test Schedule Planning
A production manager uses the **Test Time Calculator**:
1. Create test profile with all test steps
2. Enter expected device count
3. Calculate total test time and throughput
4. Optimize test order or add parallel testers

---

## 🤝 Contributing

This project is actively developed. Feature requests and improvements are welcome. To contribute:

1. Create a feature branch
2. Implement your feature
3. Test thoroughly
4. Submit a pull request with description

---

## 📝 License

This project is provided as-is for semiconductor engineering use.

---

## 👨‍💻 Author

**Klay Adams**  
Semiconductor Product Test Engineering Tools  
GitHub: [@klay326](https://github.com/klay326)

---

## 📧 Support

For questions, bug reports, or feature requests, please open an issue on the [GitHub repository](https://github.com/klay326/semiconductor-tools).

---

## 🎯 Quick Tips

- **Search in Reference Tables:** Use the search bar to quickly find specs and standards
- **Custom Bins:** Add your company's unique test bins in Yield Binning settings
- **Data Backup:** Regularly backup your device to iCloud for data safety
- **Period/Frequency:** Perfect for quick calculations during design reviews
- **Statistical Analysis:** Keep 30+ data points for reliable Cpk/Ppk calculations

---

**Last Updated:** December 2025  
**Version:** 1.0  
**Status:** Active Development
