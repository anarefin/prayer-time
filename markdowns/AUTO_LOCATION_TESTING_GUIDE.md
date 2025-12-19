# Auto Location-Based Area Selection - Testing Guide

## Overview
This guide outlines test scenarios for the automatic location-based area selection feature.

## Implementation Summary

### Features Implemented
1. **Automatic Location Detection**: On app startup, the app requests location permission and attempts to auto-select the user's area
2. **Smart Fallback**: If location is unavailable, users see informative toast messages and can select manually
3. **Seamless UX**: Auto-selected values are pre-populated in dropdowns but can be changed anytime

### Files Modified
- `lib/services/firestore_service.dart` - Added `getAreaById()` and `getDistrictById()` methods
- `lib/providers/district_provider.dart` - Added `autoSelectLocationFromArea()` and helper methods
- `lib/screens/public/home_screen_new.dart` - Implemented auto-location logic in `ImprovedHomeTab`

## Test Scenarios

### 1. Happy Path - Location Permission Granted

**Steps:**
1. Fresh install or clear app data
2. Launch the app
3. Grant location permission when prompted
4. Wait for GPS to acquire location

**Expected Result:**
- Green snackbar appears: "Auto-selected [Area Name] based on your location. You can change it anytime."
- Division dropdown pre-selected
- District dropdown pre-selected
- Area dropdown pre-selected
- User can still change selections manually
- "Find Mosques" button is enabled

### 2. Location Permission Denied

**Steps:**
1. Fresh install or clear app data
2. Launch the app
3. Deny location permission when prompted

**Expected Result:**
- Orange snackbar appears: "Location permission denied. Please select your area manually."
- All dropdowns are empty
- User can select manually using dropdowns

### 3. Location Permission Permanently Denied

**Steps:**
1. Open device Settings → Apps → Prayer Time
2. Deny location permission permanently
3. Launch the app

**Expected Result:**
- Orange snackbar appears: "Location permission permanently denied. Please enable it in settings or select your area manually."
- All dropdowns are empty
- User can select manually using dropdowns

### 4. Location Services Disabled

**Steps:**
1. Disable GPS/Location services in device settings
2. Launch the app

**Expected Result:**
- Orange snackbar appears: "Location services are disabled. Please enable them or select your area manually."
- All dropdowns are empty
- User can select manually using dropdowns

### 5. No Nearby Mosques Found

**Steps:**
1. Use GPS spoofing to set location far from Bangladesh (e.g., Antarctica)
2. Grant location permission
3. Launch the app

**Expected Result:**
- Orange snackbar appears: "No nearby mosques found. Please select your area manually."
- All dropdowns are empty
- User can select manually using dropdowns

### 6. GPS Timeout

**Steps:**
1. Grant location permission
2. Test in area with poor GPS signal (e.g., indoors, basement)
3. Launch the app

**Expected Result:**
- After 10-second timeout, orange snackbar appears: "Unable to get your location. Please select your area manually."
- All dropdowns are empty
- User can select manually using dropdowns

### 7. Manual Override After Auto-Selection

**Steps:**
1. Grant location permission
2. Wait for auto-selection to complete
3. Manually change Division dropdown
4. Select different District
5. Select different Area

**Expected Result:**
- Auto-selected values are replaced with manual selections
- No issues or conflicts
- "Find Mosques" button works with new selection

### 8. Network Issues During Auto-Selection

**Steps:**
1. Enable airplane mode
2. Launch the app
3. Grant location permission (cached)

**Expected Result:**
- Orange snackbar appears with error message
- User can select manually once network is restored

### 9. App Restart After Auto-Selection

**Steps:**
1. Complete auto-selection successfully
2. Close app completely
3. Reopen app

**Expected Result:**
- Auto-selection runs again (it's not persistent)
- Same area is likely selected if user is in same location
- No crashes or errors

### 10. Multiple Mosques in Same Area

**Steps:**
1. Be in location with multiple mosques in database
2. Grant location permission
3. Launch the app

**Expected Result:**
- Nearest mosque's area is selected
- Auto-selection completes successfully
- User can see all mosques when clicking "Find Mosques"

## Edge Cases Handled

✅ Permission denied at any stage
✅ Location services disabled
✅ GPS timeout (10 seconds)
✅ No mosques in database near user
✅ User outside Bangladesh
✅ Network connectivity issues
✅ Firestore query failures
✅ Invalid area/district data
✅ Concurrent state updates
✅ Widget disposal during async operations

## Testing Checklist

- [ ] Test on Android device
- [ ] Test on iOS device (if applicable)
- [ ] Test with location permission granted
- [ ] Test with location permission denied
- [ ] Test with location permission permanently denied
- [ ] Test with location services disabled
- [ ] Test in area with mosques in database
- [ ] Test in area without mosques (far from Bangladesh)
- [ ] Test manual override after auto-selection
- [ ] Test app restart behavior
- [ ] Verify all toast messages appear correctly
- [ ] Verify no crashes or errors in any scenario
- [ ] Verify manual selection still works in all cases

## Success Criteria

✅ No crashes in any scenario
✅ Appropriate error messages for each failure case
✅ Auto-selection works when conditions are met
✅ Manual selection always available as fallback
✅ User experience is smooth and intuitive
✅ No blocking or frozen UI states
✅ Performance is acceptable (no long delays)

## Notes

- Auto-location runs once per app session (not persisted)
- 50km radius is used to find nearest mosque
- 10-second timeout for GPS acquisition
- All async operations check `mounted` before using context
- Error handling is comprehensive and user-friendly

