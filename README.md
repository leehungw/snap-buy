# SnapBuy

SnapBuy is a modern e-commerce mobile application built with SwiftUI, supporting both buyers and sellers. The app features product browsing, cart management, order processing, PayPal integration for sellers, chat, notifications, and more.

## Features
- Buyer and Seller modes
- Product listing and detail views
- Shopping cart and checkout (COD & PayPal)
- Seller onboarding with PayPal
- Order management
- Review and rating system
- Chat between buyers and sellers
- Notification system

## Installation

### Prerequisites
- Xcode 14 or newer
- Swift 5.7 or newer
- CocoaPods (if using pods for dependencies)
- A Mac running macOS 12 or newer

### Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/leehungw/snap-buy
   cd SnapBuy
   ```

2. **Install dependencies:**
   - If using CocoaPods:
     ```bash
     pod install
     open SnapBuy.xcworkspace
     ```
   - If using Swift Package Manager, open the project in Xcode and resolve packages.

3. **Configure secret files:**
   - The project requires some secret configuration files for PayPal and other credentials:
     - `PayPalConfig.plist`
     - `credentials.plist`
   - **These files are not included in the repository.**
   - To obtain these files, please contact: **21520889@gm.uit.edu.vn**

4. **Build and run:**
   - Open the project in Xcode (`SnapBuy.xcworkspace` if using CocoaPods).
   - Select your simulator or device.
   - Press `Cmd + R` to build and run the app.

## Project Structure
- `Source/` — Main source code (modules for Buyer, Seller, Services, etc.)
- `Resource/` — App resources (images, fonts, etc.)
- `Root/` — App entry point
- `PayPalConfig.plist`, `credentials.plist` — Secret configuration files (not included)

## Contact
For any questions, issues, or to request secret configuration files, please email:

**21520889@gm.uit.edu.vn**

---
Happy shopping and selling with SnapBuy!
