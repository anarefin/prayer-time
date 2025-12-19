# Testing Guide

Comprehensive testing scenarios for the Prayer Time app.

## Table of Contents
1. [Pre-Testing Setup](#pre-testing-setup)
2. [Admin Testing](#admin-testing)
3. [User Testing](#user-testing)
4. [Integration Testing](#integration-testing)
5. [Edge Cases](#edge-cases)
6. [Performance Testing](#performance-testing)
7. [Security Testing](#security-testing)

## Pre-Testing Setup

### Required Test Data
Create the following before testing:
- At least 2 areas
- At least 3 mosques (2 in one area, 1 in another)
- Prayer times for today and tomorrow
- 1 admin user
- 2 regular users

### Test Devices
Test on:
- Android device (physical or emulator)
- iOS device (physical or simulator) if available
- Different screen sizes

## Admin Testing

### Test Case 1: Admin Login
**Objective**: Verify admin authentication and role-based access

**Steps:**
1. Open app
2. Tap admin icon (top right)
3. Enter admin credentials
4. Tap "Sign In"

**Expected Results:**
- ✓ Redirected to Admin Dashboard
- ✓ Dashboard shows statistics
- ✓ Can access all management screens

**Failure Scenario:**
1. Try logging in with regular user credentials
2. **Expected**: Error message "Access denied. Admin credentials required."

### Test Case 2: Manage Areas
**Objective**: Test CRUD operations for areas

**Add Area:**
1. Dashboard → Manage Areas → "+"
2. Name: "Test Area", Order: 99
3. Save

**Expected:**
- ✓ Area added successfully
- ✓ Appears in list
- ✓ Visible in public area selection

**Edit Area:**
1. Tap edit icon on test area
2. Change name to "Modified Area"
3. Save

**Expected:**
- ✓ Area updated
- ✓ Changes reflected immediately

**Delete Area:**
1. Tap delete icon on test area
2. Confirm deletion

**Expected:**
- ✓ Area deleted (if no mosques)
- ✓ OR Error message if mosques exist

### Test Case 3: Manage Mosques
**Objective**: Test mosque management

**Add Mosque:**
1. Dashboard → Manage Mosques → "+"
2. Fill all fields:
   - Name: "Test Mosque"
   - Address: "123 Test St"
   - Area: Select an area
   - Latitude: 3.140853
   - Longitude: 101.693207
3. Save

**Expected:**
- ✓ Mosque added
- ✓ Appears in mosque list
- ✓ Visible in public mosque view

**Edit Mosque:**
1. Tap mosque card
2. Select "Edit Mosque"
3. Change address
4. Save

**Expected:**
- ✓ Mosque updated
- ✓ Changes visible immediately

**Search Mosque:**
1. Enter mosque name in search bar
2. Verify filtering works

**Expected:**
- ✓ Only matching mosques shown
- ✓ Clear button removes filter

**Delete Mosque:**
1. Tap mosque card
2. Select "Delete Mosque"
3. Confirm

**Expected:**
- ✓ Mosque deleted
- ✓ Associated prayer times deleted

### Test Case 4: Manage Prayer Times
**Objective**: Test prayer time configuration

**Set Prayer Times:**
1. Dashboard → Manage Prayer Times
2. Select mosque
3. Select today's date
4. Tap "Set Prayer Times"
5. Set all five prayer times
6. Save

**Expected:**
- ✓ Times saved successfully
- ✓ Visible in prayer times list
- ✓ Users can view these times

**Edit Prayer Times:**
1. Select same mosque and date
2. Tap "Edit Times"
3. Modify Fajr time
4. Save

**Expected:**
- ✓ Times updated
- ✓ Changes reflected for users

### Test Case 5: Admin Logout
**Objective**: Verify secure logout

**Steps:**
1. In Dashboard, tap logout icon
2. Confirm logout

**Expected:**
- ✓ Redirected to home screen
- ✓ Cannot access admin features
- ✓ Must login again to access admin

## User Testing

### Test Case 6: Browse Areas and Mosques
**Objective**: Test basic navigation

**Steps:**
1. Open app (as public user)
2. View area list
3. Tap an area
4. View mosque list
5. Use search to find mosque
6. Tap a mosque

**Expected:**
- ✓ All areas visible
- ✓ Mosques filtered by area
- ✓ Search works correctly
- ✓ Mosque details displayed

### Test Case 7: View Prayer Times
**Objective**: Test prayer time display

**Steps:**
1. Navigate to a mosque
2. View today's prayer times
3. Tap calendar icon
4. Select tomorrow
5. Observe next prayer highlighting

**Expected:**
- ✓ All five prayers displayed
- ✓ Times formatted correctly (HH:mm)
- ✓ Next prayer highlighted
- ✓ Time until next prayer shown
- ✓ Can change dates
- ✓ Show empty state if no times set

### Test Case 8: Qibla Compass
**Objective**: Test Qibla direction feature

**Steps:**
1. Home → Qibla tab
2. Grant location permission when prompted
3. Wait for compass to calibrate
4. Rotate device

**Expected:**
- ✓ Location permission requested
- ✓ Compass displays direction
- ✓ Arrow points to Qibla
- ✓ Degree measurement shown
- ✓ Updates in real-time
- ✓ Shows cardinal direction

**Failure Scenario:**
1. Deny location permission
2. **Expected**: Error message with option to retry

### Test Case 9: User Authentication
**Objective**: Test user registration and login

**Register:**
1. Favorites tab
2. Tap "Sign In"
3. Switch to "Create Account"
4. Email: test@example.com
5. Password: test123456
6. Tap "Register"

**Expected:**
- ✓ Account created
- ✓ Logged in automatically
- ✓ Can access favorites

**Login:**
1. Logout (if possible)
2. Favorites tab → Sign In
3. Enter credentials
4. Login

**Expected:**
- ✓ Logged in successfully
- ✓ Favorites accessible

**Error Cases:**
- Invalid email: Shows error
- Weak password: Shows error
- Existing email: Shows error
- Wrong password: Shows error

### Test Case 10: Favorites
**Objective**: Test favorite mosque management

**Add Favorite:**
1. Login as user
2. Navigate to mosque list
3. Tap heart icon on mosque card
4. Go to Favorites tab

**Expected:**
- ✓ Heart icon filled
- ✓ Mosque appears in favorites
- ✓ Can view from favorites tab

**Remove Favorite:**
1. In favorites, tap filled heart
2. OR in mosque list, tap filled heart

**Expected:**
- ✓ Heart icon unfilled
- ✓ Removed from favorites
- ✓ Changes reflected everywhere

**View Prayer Times from Favorites:**
1. Favorites tab
2. Tap mosque card

**Expected:**
- ✓ Navigate to prayer times
- ✓ Works same as regular navigation

### Test Case 11: Notifications
**Objective**: Test prayer time notifications

**Steps:**
1. View mosque prayer times
2. Tap notification bell icon
3. Grant notification permission
4. Confirm notifications enabled

**Expected:**
- ✓ Permission requested
- ✓ Notifications scheduled
- ✓ Icon shows active state
- ✓ Receive notification 15 min before prayer

**Disable Notifications:**
1. Tap notification icon again

**Expected:**
- ✓ Notifications canceled
- ✓ Icon shows inactive state

## Integration Testing

### Test Case 12: End-to-End Admin Flow
**Complete workflow:**
1. Login as admin
2. Add new area
3. Add mosque in that area
4. Set prayer times for mosque
5. Logout
6. View as public user
7. Verify all data visible

### Test Case 13: End-to-End User Flow
**Complete workflow:**
1. Register new user
2. Browse areas
3. Find mosque
4. View prayer times
5. Add to favorites
6. Enable notifications
7. Use Qibla compass
8. Verify all features work together

## Edge Cases

### Test Case 14: Empty States
**Test all empty states:**
- No areas created
- No mosques in area
- No prayer times for date
- No favorites
- No search results

**Expected**: Appropriate empty state message with helpful text

### Test Case 15: Network Issues
**Simulate offline:**
1. Turn off internet
2. Try to load data
3. Try to add data

**Expected:**
- ✓ Show loading then error
- ✓ Retry button available
- ✓ Graceful error messages

### Test Case 16: Permission Denials
**Test permission scenarios:**
- Deny location for Qibla
- Deny notifications
- Permanently deny permissions

**Expected:**
- ✓ Helpful error messages
- ✓ Guidance to enable in settings
- ✓ App doesn't crash

### Test Case 17: Data Validation
**Test invalid inputs:**
- Empty mosque name
- Invalid coordinates (lat > 90)
- Invalid prayer time format
- Duplicate area names

**Expected:**
- ✓ Validation errors shown
- ✓ Cannot submit invalid data
- ✓ Clear error messages

### Test Case 18: Date Boundaries
**Test date selection:**
- Past dates (should be blocked)
- Far future dates (1 year+)
- Date changes at midnight

**Expected:**
- ✓ Appropriate date limits
- ✓ Prayer times for correct date
- ✓ Next prayer updates at midnight

## Performance Testing

### Test Case 19: Load Testing
**Test with large datasets:**
- 20+ areas
- 100+ mosques
- 1000+ prayer times

**Expected:**
- ✓ Lists scroll smoothly
- ✓ Search is fast
- ✓ No lag or stuttering

### Test Case 20: Memory Usage
**Monitor memory:**
1. Navigate through all screens
2. Add/remove favorites multiple times
3. Switch between tabs
4. Check memory usage

**Expected:**
- ✓ Memory usage stable
- ✓ No memory leaks
- ✓ App doesn't crash

## Security Testing

### Test Case 21: Authentication Security
**Test security rules:**
1. Try to write data as non-admin
2. Try to access other user's favorites
3. Try to modify prayer times without login

**Expected:**
- ✓ All writes denied
- ✓ Appropriate error messages
- ✓ No data leakage

### Test Case 22: Role-Based Access
**Test role enforcement:**
1. Login as regular user
2. Try to access admin dashboard directly
3. Try admin features

**Expected:**
- ✓ Access denied
- ✓ Redirected or error shown
- ✓ Cannot see admin UI

## Regression Testing Checklist

After any code changes, verify:
- [ ] App launches successfully
- [ ] Can view areas and mosques
- [ ] Prayer times display correctly
- [ ] Qibla compass works
- [ ] Authentication works
- [ ] Favorites work
- [ ] Admin functions work
- [ ] No new crashes
- [ ] No performance degradation

## Bug Reporting Template

When you find a bug, report:
```
**Title**: Brief description
**Severity**: Critical/High/Medium/Low
**Steps to Reproduce**:
1. Step one
2. Step two
3. ...

**Expected Result**: What should happen
**Actual Result**: What actually happens
**Environment**:
- Device: 
- OS Version:
- App Version:
**Screenshots**: (if applicable)
```

## Test Sign-Off

Before considering testing complete:
- [ ] All test cases passed
- [ ] Edge cases handled
- [ ] Performance acceptable
- [ ] Security verified
- [ ] No critical bugs
- [ ] Documentation updated

---

**Testing Completed By**: _______________
**Date**: _______________
**App Version**: _______________

