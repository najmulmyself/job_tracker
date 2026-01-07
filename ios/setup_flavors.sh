#!/bin/bash

# This script sets up iOS schemes and configurations for dev and prod flavors

# Create build configurations
echo "Setting up iOS build configurations..."

# Update the project.pbxproj to include dev and prod configurations
# This script should be run once to set up the iOS project

# The script will:
# 1. Duplicate Debug configuration as Debug-dev and Debug-prod
# 2. Duplicate Release configuration as Release-dev and Release-prod
# 3. Create schemes for dev and prod

echo "⚠️  IMPORTANT: iOS Flavor Setup"
echo ""
echo "To complete iOS flavor setup, you need to:"
echo ""
echo "1. Open the project in Xcode:"
echo "   open ios/Runner.xcworkspace"
echo ""
echo "2. Set up Build Configurations:"
echo "   - Click on the Runner project in the Project Navigator"
echo "   - Select the Runner target > Info tab"
echo "   - Under 'Configurations', duplicate Debug and Release:"
echo "     • Debug → Debug-dev and Debug-prod"
echo "     • Release → Release-dev and Release-prod"
echo ""
echo "3. Create Schemes:"
echo "   - Click Product > Scheme > New Scheme..."
echo "   - Create 'dev' scheme using Debug-dev configuration"
echo "   - Create 'prod' scheme using Debug-prod configuration"
echo ""
echo "4. Update Info.plist to use dynamic bundle identifier:"
echo "   - Add PRODUCT_BUNDLE_IDENTIFIER to each configuration"
echo "   - dev: com.jobtracker.dev"
echo "   - prod: com.jobtracker.app"
echo ""
echo "5. Set up Firebase Config File Script:"
echo "   - Add a 'Run Script' build phase BEFORE 'Compile Sources'"
echo "   - Add the following script:"
echo ""
echo '   PLIST_DESTINATION="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"'
echo '   if [ "${CONFIGURATION}" == "Debug-dev" ] || [ "${CONFIGURATION}" == "Release-dev" ]; then'
echo '     cp "${SRCROOT}/Runner/dev/GoogleService-Info.plist" "${PLIST_DESTINATION}"'
echo '   else'
echo '     cp "${SRCROOT}/Runner/prod/GoogleService-Info.plist" "${PLIST_DESTINATION}"'
echo '   fi'
echo ""
echo "6. Update Bundle Identifier in User-Defined Settings:"
echo "   - For each configuration, set PRODUCT_BUNDLE_IDENTIFIER:"
echo "     • Debug-dev / Release-dev: com.jobtracker.dev"
echo "     • Debug-prod / Release-prod: com.jobtracker.app"
echo ""
