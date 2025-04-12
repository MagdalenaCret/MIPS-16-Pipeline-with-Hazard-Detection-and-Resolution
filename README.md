# 🚀 MIPS Pipeline Hazard Detection and Resolution Unit

## 📝 Project Overview

This project implements a specialized unit for detecting and resolving hazard situations in MIPS pipeline architectures. The implementation is designed for a 16-bit MIPS processor and focuses on resolving data hazards (RAW and Load) and control hazards.

## ✨ Key Components

The project enhances a standard MIPS pipeline architecture by adding:

1. **🔄 Register File Bypass** - For resolving data hazards
2. **🔮 Branch Prediction Buffer** - For resolving control hazards
3. **🔍 Hazard Detection Unit** - For detecting and managing load hazards

## 🛠️ Features

### 📊 Data Hazard Resolution
- **🔄 Register File Bypass**: Allows direct access to recently computed values in the pipeline stages
- **↪️ Forwarding Unit**: Redirects data between pipeline stages to avoid stalls
- 🔄 Support for forwarding in all critical pipeline stages (IF, EX, MEM)

### 🎯 Control Hazard Resolution
- **🧠 Dynamic Branch Prediction**: Uses a 2-bit saturating counter to predict branch directions
- **💾 Branch Target Buffer**: Stores branch targets for quick access
- **🧹 Flush Unit**: Clears pipeline when branch predictions are incorrect

### 💻 Implementation Details
- ⚙️ Full VHDL implementation
- 🖥️ Compatible with 16-bit MIPS pipeline processor
- ✅ Tested on various hazard scenarios


## 🚦 Getting Started

### 📋 Prerequisites
- 🔧 Xilinx Vivado (for synthesis and simulation)
- 🎛️ FPGA board (such as Basys3) for hardware testing

### 📥 Installation
1. Clone this repository
   ```
   git clone https://github.com/MagdalenaCret/MIPS-16-Pipeline-with-Hazard-Detection-and-Resolution.git
   ```
2. 📂 Open the project in Xilinx Vivado
3. ⚙️ Synthesize and implement the design
4. 🔌 (Optional) Deploy to an FPGA for hardware validation

## 🧪 Testing

The project includes several test programs to validate the hazard detection and resolution:

1. **📊 Data Hazard Tests**:
   - 📚 RAW (Read-After-Write) hazard testing
   - 🔄 Load hazard testing
   
2. **🎯 Control Hazard Tests**:
   - 🔀 Conditional branch testing
   - ➡️ Jump instruction testing
   
3. **🧩 Combined Tests**:
   - 🔍 A comprehensive program that tests all hazard types

## 🔮 Future Improvements

Potential optimizations include:
- 🧠 Implementation of the Tomasulo algorithm for more advanced hazard resolution
- 🔄 Extension to handle additional hazard types
- ⚡ Performance optimizations for the branch prediction mechanism
- 📈 Support for 32-bit MIPS architecture

## 👩‍💻 Authors

- 👩‍🎓 Maria-Magdalena Creț

## 🙏 Acknowledgments

- 🏫 Technical University of Cluj-Napoca
- 🎓 Faculty of Automation and Computer Science
- 📚 Documentation from Computer Architecture course

## 📄 License

This project is provided for educational purposes.
