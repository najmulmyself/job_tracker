#!/bin/bash

# Job Tracker - Production Environment Runner
# This script runs the app in PROD flavor with the PROD Firebase project

echo "🚀 Starting Job Tracker in PRODUCTION mode..."
echo "📱 This will use your PRODUCTION Firebase project"
echo "⚠️  WARNING: Real data will be affected!"
echo ""

flutter run --flavor prod -t lib/main_prod.dart
