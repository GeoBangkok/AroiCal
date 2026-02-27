# AroiCal - AI-Powered Calorie Tracker

A smart iOS app that helps you track calories and make healthier food choices using AI-powered food and menu analysis.

## Features

- 📸 **Food Scanning**: Take photos of your meals for instant nutritional analysis
- 📋 **Menu Scanner**: Upload restaurant menus to get AI recommendations for healthiest and tastiest options
- 🌏 **Multilingual Support**: Available in English, Thai, and Japanese
- 📊 **Nutritional Tracking**: Track calories, protein, carbs, and fat
- 🔥 **Streak Tracking**: Maintain daily logging streaks
- 🤖 **AI-Powered Analysis**: Uses OpenAI's GPT-4o mini for accurate food analysis

## Setup

### Requirements

- iOS 16.0+
- Xcode 14.0+
- OpenAI API Key

### Installation

1. Clone the repository:
```bash
git clone https://github.com/GeoBangkok/AroiCal.git
cd AroiCal
```

2. Open in Xcode:
```bash
open AroiCal.xcodeproj
```

3. Set up your OpenAI API Key:

   **Option 1: Environment Variable (Recommended for development)**
   - Set the environment variable before running:
   ```bash
   export OPENAI_API_KEY="your_api_key_here"
   ```

   **Option 2: Direct Configuration (For testing only)**
   - Edit `AroiCal/Config.swift`
   - Replace `"YOUR_API_KEY_HERE"` with your actual API key
   - ⚠️ **Never commit API keys to version control!**

4. Build and run the project in Xcode

### Getting an OpenAI API Key

1. Visit [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign up or log in to your account
3. Create a new API key
4. Copy the key and follow the setup instructions above

## Usage

### Food Scanning
1. Tap "Scan Food" on the Food tab
2. Take a photo or upload from gallery
3. AI analyzes the food and provides nutritional information
4. Confirm to add to your daily log

### Menu Scanning
1. Tap "Scan Menu" on the Food tab
2. Take a photo or upload a screenshot of any menu
3. AI provides recommendations in three categories:
   - 🥗 **Healthiest Options**: Top nutritious choices
   - 🍽️ **Tastiest Options**: Most satisfying selections
   - ⚖️ **Balanced Choice**: Best of both worlds

## Technologies

- **SwiftUI**: Modern iOS UI framework
- **Vision Framework**: OCR for text extraction from menus
- **OpenAI GPT-4o mini**: Fast, affordable AI model for food analysis
- **StoreKit 2**: Native subscription management
- **Superwall**: Paywall analytics and optimization
- **Core Data**: Local data persistence

## Security Note

This app requires an OpenAI API key to function. Please:
- Never commit your API key to version control
- Use environment variables for production deployments
- Rotate your keys regularly
- Monitor your API usage on the OpenAI dashboard

## License

This project is available for educational and personal use.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.