#!/bin/bash

# Job Tracker - Development Environment Runner
# This script runs the app in DEV flavor with the DEV Firebase project

echo "🚀 Starting Job Tracker in DEVELOPMENT mode..."
echo "📱 This will use your DEV Firebase project"
echo ""

flutter run --flavor dev -t lib/main_dev.dart
