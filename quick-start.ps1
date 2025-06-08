# Quick Start Script for Lifeline Blood Donation App
# Run this script to quickly set up and run the application

param(
    [switch]$Setup,
    [switch]$Run,
    [switch]$Clean,
    [switch]$Test,
    [switch]$Build,
    [string]$Device = ""
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Success($message) {
    Write-Host $message -ForegroundColor Green
}

function Write-Info($message) {
    Write-Host $message -ForegroundColor Cyan
}

function Write-Warning($message) {
    Write-Host $message -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host $message -ForegroundColor Red
}

# Check if Flutter is installed
function Test-FlutterInstallation {
    try {
        $flutterVersion = flutter --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "✓ Flutter is installed"
            return $true
        }
    }
    catch {
        Write-Error "✗ Flutter is not installed or not in PATH"
        Write-Info "Please install Flutter from: https://docs.flutter.dev/get-started/install"
        return $false
    }
}

# Run Flutter Doctor
function Invoke-FlutterDoctor {
    Write-Info "Running Flutter Doctor..."
    flutter doctor
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Please fix any issues shown by 'flutter doctor' before proceeding"
    }
}

# Setup project
function Invoke-Setup {
    Write-Info "🚀 Setting up Lifeline Blood Donation App..."
    
    # Check Flutter installation
    if (-not (Test-FlutterInstallation)) {
        exit 1
    }
    
    # Run Flutter Doctor
    Invoke-FlutterDoctor
    
    # Clean previous builds
    Write-Info "Cleaning previous builds..."
    flutter clean
    
    # Get dependencies
    Write-Info "Getting Flutter dependencies..."
    flutter pub get
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ Dependencies installed successfully"
    } else {
        Write-Error "✗ Failed to install dependencies"
        exit 1
    }
    
    # Check for .env file
    if (-not (Test-Path ".env")) {
        Write-Warning "⚠️  .env file not found!"
        Write-Info "Creating sample .env file..."
        
        $envContent = @"
# Firebase Configuration
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_AUTH_DOMAIN=your_project_id.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project_id.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id

# Google Maps API (Optional)
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here

# App Configuration
APP_ENVIRONMENT=development
DEBUG_MODE=true
"@
        
        $envContent | Out-File -FilePath ".env" -Encoding UTF8
        Write-Info "Sample .env file created. Please update it with your Firebase configuration."
        Write-Info "See SETUP.md for detailed instructions on getting Firebase keys."
    } else {
        Write-Success "✓ .env file found"
    }
    
    # Check for Firebase configuration
    if (-not (Test-Path "lib\firebase_options.dart")) {
        Write-Warning "⚠️  Firebase configuration not found!"
        Write-Info "Please run 'flutterfire configure' to set up Firebase."
        Write-Info "See SETUP.md for detailed Firebase setup instructions."
    } else {
        Write-Success "✓ Firebase configuration found"
    }
    
    Write-Success "🎉 Setup completed!"
    Write-Info "Next steps:"
    Write-Info "1. Update .env file with your Firebase configuration"
    Write-Info "2. Run 'flutterfire configure' if you haven't already"
    Write-Info "3. Run this script with -Run flag to start the app"
}

# Clean project
function Invoke-Clean {
    Write-Info "🧹 Cleaning project..."
    
    flutter clean
    
    if (Test-Path "build") {
        Remove-Item -Recurse -Force "build"
        Write-Success "✓ Build directory cleaned"
    }
    
    Write-Info "Getting fresh dependencies..."
    flutter pub get
    
    Write-Success "✓ Project cleaned successfully"
}

# Run tests
function Invoke-Test {
    Write-Info "🧪 Running tests..."
    
    # Check if test directory exists
    if (-not (Test-Path "test")) {
        Write-Warning "No test directory found, creating basic test structure..."
        New-Item -ItemType Directory -Path "test" -Force | Out-Null
        
        $basicTest = @"
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeline_blood_donation_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('Lifeline'), findsOneWidget);
  });
}
"@
        $basicTest | Out-File -FilePath "test\widget_test.dart" -Encoding UTF8
    }
    
    flutter test
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ All tests passed"
    } else {
        Write-Error "✗ Some tests failed"
    }
}

# Build project
function Invoke-Build {
    Write-Info "🔨 Building project..."
    
    # Build APK for Android
    Write-Info "Building Android APK..."
    flutter build apk --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ Android APK built successfully"
        Write-Info "APK location: build\app\outputs\flutter-apk\app-release.apk"
    } else {
        Write-Error "✗ Android build failed"
    }
}

# Run the app
function Invoke-Run {
    Write-Info "🚀 Starting Lifeline Blood Donation App..."
    
    # Check if Flutter is installed
    if (-not (Test-FlutterInstallation)) {
        exit 1
    }
    
    # List available devices
    if ([string]::IsNullOrEmpty($Device)) {
        Write-Info "Available devices:"
        flutter devices
        Write-Info ""
    }
    
    # Run the app
    if ([string]::IsNullOrEmpty($Device)) {
        Write-Info "Starting app on default device..."
        flutter run
    } else {
        Write-Info "Starting app on device: $Device"
        flutter run -d $Device
    }
}

# Analyze code
function Invoke-Analyze {
    Write-Info "🔍 Analyzing code..."
    
    flutter analyze
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✓ No analysis issues found"
    } else {
        Write-Warning "⚠️  Analysis found issues (see above)"
    }
}

# Main script logic
Write-Info "🩸 Lifeline Blood Donation App - Quick Start Script"
Write-Info "================================================="

if ($Setup) {
    Invoke-Setup
}
elseif ($Run) {
    Invoke-Run
}
elseif ($Clean) {
    Invoke-Clean
}
elseif ($Test) {
    Invoke-Test
}
elseif ($Build) {
    Invoke-Build
}
else {
    Write-Info "Usage: .\quick-start.ps1 [options]"
    Write-Info ""
    Write-Info "Options:"
    Write-Info "  -Setup    : Set up the project (install dependencies, create .env file)"
    Write-Info "  -Run      : Run the application"
    Write-Info "  -Clean    : Clean build files and reinstall dependencies"
    Write-Info "  -Test     : Run tests"
    Write-Info "  -Build    : Build release version"
    Write-Info "  -Device   : Specify device to run on (use with -Run)"
    Write-Info ""
    Write-Info "Examples:"
    Write-Info "  .\quick-start.ps1 -Setup"
    Write-Info "  .\quick-start.ps1 -Run"
    Write-Info "  .\quick-start.ps1 -Run -Device chrome"
    Write-Info "  .\quick-start.ps1 -Clean"
    Write-Info ""
    Write-Info "For detailed setup instructions, see SETUP.md"
    Write-Info "For development guidelines, see DEVELOPMENT.md"
}
