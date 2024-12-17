# Automated PVC Tube Delivery Verification System

**Project Title:** Design and Development of an Automated System for Verifying PVC Tube Deliveries Using a Camera and a Mobile Interface

**Developed by:** Menyara KHAIREDDINE  
**Company:** WinIT  
**Academic Year:** 2022/2023

---

## Table of Contents
1. [Overview](#overview)
2. [Technologies Used](#technologies-used)
3. [System Architecture](#system-architecture)
4. [Features](#features)
5. [User Interface](#user-interface)
6. [Example - Object Detection with Segment Anything](#example---object-detection-with-segment-anything)
7. [Setup Instructions](#setup-instructions)
8. [How It Works](#how-it-works)
9. [Evaluation and Results](#evaluation-and-results)
10. [Conclusion](#conclusion)

---

## Overview
This project automates the verification process of PVC tube deliveries using:
- **Intel RealSense D35i Camera** for depth image capture.
- **Raspberry Pi** as the main processing unit.
- **Mobile Application (Flutter)** for user interaction and real-time display.
- **Segment Anything Model (MobileSAM)** for object detection and segmentation.

The application allows users to:
1. Capture images of deliveries.
2. Automatically count PVC tubes.
3. Compare results with delivery invoices.

This ensures accuracy, saves time, and minimizes human errors.

---

## Technologies Used
| **Technology**            | **Purpose**                      |
|----------------------------|----------------------------------|
| **Flutter (Dart)**         | Mobile application development. |
| **Intel RealSense D35i**   | Image capture (depth camera).   |
| **Raspberry Pi**           | Processing unit.                |
| **Segment Anything (MobileSAM)** | Object detection and segmentation. |
| **Git**                    | Version control.                |
| **HTTP API**               | Backend communication.          |
| **Android Studio**         | Development environment.        |

---

## System Architecture
```
Intel RealSense D35i Camera --> Raspberry Pi --> Object Detection (MobileSAM) --> 
Processed Data --> Mobile App (Flutter) --> Display & Verification
```

---

## Features
1. **User Authentication**: Signup and Login functionality.
2. **Camera Integration**: Real-time video streaming and image capture.
3. **Invoice Management**: Fetch and display delivery invoices.
4. **Object Detection**: Automatic counting of PVC tubes using **Segment Anything (MobileSAM)**.
5. **Verification**: Cross-check the detected tube count with the invoice.
6. **User-Friendly Interface**: Multiple pages for smooth navigation and data visualization.

---
## Example - Object Detection with Segment Anything
This project uses **MobileSAM** for detecting and segmenting PVC tubes. MobileSAM is a lightweight implementation of the Segment Anything model, optimized for performance and speed.

### **Key Advantages of MobileSAM:**
- Lightweight (9.66M parameters).
- Fast (12ms per image on GPU).
- Accurate object segmentation.

### **Steps for Object Detection:**
1. **Image Capture**: The Intel RealSense camera captures depth images of the truck's contents.
2. **Processing**: MobileSAM processes the image to detect and segment PVC tubes.
3. **Output**: The total count of detected tubes is displayed in the mobile app.

### **Detection Example**

### Input Image, Segmented Output
<p float="left">
  <img src="https://github.com/user-attachments/assets/4be0495f-0465-4b17-91c5-9a3f6d515bd4" width="200"/>
  <img src="https://github.com/user-attachments/assets/f3cfbbd1-759c-4e17-a9fa-baafc18bf7da" width="215"/>
</p>

---
## User Interface
Below are the user interface screens developed during the project. 

### Sign Up, Sign In, Type Selection, and Device Selection Pages
<p float="left">
  <img src="https://github.com/user-attachments/assets/2c3dadbf-9b60-4514-b912-1bfdd2e12c7d" width="200"/>
  <img src="https://github.com/user-attachments/assets/b2542779-1635-4dd6-828b-ca5522d0e875" width="198"/>
  <img src="https://github.com/user-attachments/assets/9e9d93f0-20fb-43fa-8ffb-e38eb442ce1c" width="195"/>
  <img src="https://github.com/user-attachments/assets/2455af90-6509-41fe-89bf-697095e6e058" width="205"/>
</p>

### Invoice, Live Stream, Output, and Return Output Pages
<p float="left">
  <img src="https://github.com/user-attachments/assets/593c9092-b648-4525-b3d3-f22e7a6a2035" width="420"/>
  <img src="https://github.com/user-attachments/assets/4be0495f-0465-4b17-91c5-9a3f6d515bd4" width="180"/>
  <img src="https://github.com/user-attachments/assets/f3cfbbd1-759c-4e17-a9fa-baafc18bf7da" width="200"/>
  <img src="https://github.com/user-attachments/assets/8107c148-0239-4a64-b14d-5a08aac578dc" width="200"/>
</p>
---

## Setup Instructions
### **Requirements**
- Python >= 3.8
- PyTorch >= 1.7
- Flutter SDK
- Intel RealSense SDK
- MobileSAM Library
- Raspberry Pi OS

### **Steps to Run the Project**
1. **Clone the Repository**
   ```bash
   git clone https://github.com/username/pvc-verification-system.git
   cd pvc-verification-system
   ```
2. **Install Dependencies**
   - Install MobileSAM:
     ```bash
     pip install git+https://github.com/ChaoningZhang/MobileSAM.git
     ```
   - Install Flutter dependencies:
     ```bash
     flutter pub get
     ```
3. **Configure Intel RealSense Camera**
   - Follow [Intel RealSense Setup Guide](https://www.intelrealsense.com/).

4. **Run Mobile App**
   - Launch Android Studio and run the Flutter application:
     ```bash
     flutter run
     ```
5. **Connect Camera to Raspberry Pi**
   - Ensure the camera is connected and properly configured.

---

## How It Works
1. **User Logs In** to the mobile application.
2. **Selects Camera** and **Invoice** to verify delivery.
3. **Real-Time Video Stream** starts.
4. User **captures an image**.
5. Image is processed with **MobileSAM**.
6. The **tube count** is displayed and compared with the invoice.
7. Discrepancies are highlighted for verification.

---

## Evaluation and Results
During testing:
- The application performed efficiently in detecting and counting PVC tubes.
- **Accuracy**: 95% precision in detecting PVC tubes.
- **Performance**: Smooth functionality in debug and release modes.
- Error in HTTP handling in release mode was fixed by enabling secure HTTP configurations.

---

## Conclusion
This project successfully automated the PVC tube delivery verification process, combining cutting-edge technologies like **MobileSAM** and **Flutter**. The system:
1. Improved accuracy and reduced human errors.
2. Optimized the verification process with a user-friendly mobile interface.
3. Demonstrated the potential of AI-driven solutions in industrial automation.

The experience provided a comprehensive understanding of mobile development, object detection models, and hardware-software integration.

---

## References
1. [Flutter Documentation](https://docs.flutter.dev)
2. [MobileSAM GitHub Repository](https://github.com/ChaoningZhang/MobileSAM)
3. Intel RealSense D35i Documentation

---
**Author:** Menyara KHAIREDDINE
