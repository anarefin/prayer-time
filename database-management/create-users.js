#!/usr/bin/env node

/**
 * Create Firebase Auth Users and Firestore Documents
 * 
 * This script creates users in BOTH Firebase Authentication and Firestore
 * 
 * Usage: node create-users.js
 */

const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
try {
  const serviceAccount = require(path.join(__dirname, 'service-account-key.json'));
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('✅ Firebase Admin initialized\n');
} catch (error) {
  console.error('❌ Failed to initialize Firebase Admin:', error.message);
  console.log('\n📝 Make sure service-account-key.json exists!');
  process.exit(1);
}

const auth = admin.auth();
const db = admin.firestore();

// Users to create
const users = [
  {
    email: 'arefin@arefin.com',
    password: 'arefin',
    role: 'admin',
    displayName: 'Admin User'
  },
  {
    email: 'test@test.com',
    password: '123456',
    role: 'user',
    displayName: 'Test User'
  }
];

/**
 * Create or update a user in both Firebase Auth and Firestore
 */
async function createUser(userData) {
  console.log(`\n📝 Processing: ${userData.email}`);
  
  let uid;
  
  try {
    // Step 1: Check if user exists in Firebase Auth
    let userRecord;
    try {
      userRecord = await auth.getUserByEmail(userData.email);
      console.log(`   ✓ User exists in Firebase Auth (UID: ${userRecord.uid})`);
      uid = userRecord.uid;
      
      // Update password
      await auth.updateUser(uid, {
        password: userData.password,
        displayName: userData.displayName
      });
      console.log(`   ✓ Password updated to: ${userData.password}`);
      
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        // User doesn't exist, create new
        userRecord = await auth.createUser({
          email: userData.email,
          password: userData.password,
          displayName: userData.displayName,
          emailVerified: false
        });
        uid = userRecord.uid;
        console.log(`   ✓ Created in Firebase Auth (UID: ${uid})`);
        console.log(`   ✓ Password set to: ${userData.password}`);
      } else {
        throw error;
      }
    }
    
    // Step 2: Create/update Firestore document
    const firestoreData = {
      email: userData.email,
      role: userData.role,
      favorites: []
    };
    
    await db.collection('users').doc(uid).set(firestoreData, { merge: true });
    console.log(`   ✓ Firestore document created/updated`);
    console.log(`   ✓ Role: ${userData.role}`);
    
    return { success: true, uid };
    
  } catch (error) {
    console.error(`   ❌ Error: ${error.message}`);
    return { success: false, error: error.message };
  }
}

/**
 * Verify user can authenticate
 */
async function verifyUser(email, uid) {
  try {
    const userDoc = await db.collection('users').doc(uid).get();
    if (userDoc.exists) {
      const data = userDoc.data();
      console.log(`   ✓ Firestore verification passed`);
      console.log(`     - Email: ${data.email}`);
      console.log(`     - Role: ${data.role}`);
      console.log(`     - Favorites: ${data.favorites.length} items`);
      return true;
    } else {
      console.log(`   ⚠️  Firestore document missing`);
      return false;
    }
  } catch (error) {
    console.log(`   ❌ Verification failed: ${error.message}`);
    return false;
  }
}

/**
 * Main execution
 */
async function main() {
  console.log('🚀 Creating Firebase Users\n');
  console.log('This will create/update users in:');
  console.log('  1. Firebase Authentication (with passwords)');
  console.log('  2. Firestore Database (with profile data)');
  console.log('─'.repeat(50));
  
  const results = [];
  
  for (const userData of users) {
    const result = await createUser(userData);
    if (result.success) {
      await verifyUser(userData.email, result.uid);
    }
    results.push({ ...userData, ...result });
    console.log('─'.repeat(50));
  }
  
  // Summary
  console.log('\n📊 Summary:\n');
  
  const successful = results.filter(r => r.success);
  const failed = results.filter(r => !r.success);
  
  if (successful.length > 0) {
    console.log('✅ Successfully created/updated:');
    successful.forEach(user => {
      console.log(`   - ${user.email} (${user.role})`);
      console.log(`     Password: ${user.password}`);
      console.log(`     UID: ${user.uid}`);
    });
  }
  
  if (failed.length > 0) {
    console.log('\n❌ Failed:');
    failed.forEach(user => {
      console.log(`   - ${user.email}: ${user.error}`);
    });
  }
  
  console.log('\n🎉 Done! You can now log in with these credentials:\n');
  successful.forEach(user => {
    console.log(`${user.role === 'admin' ? '👑' : '👤'} ${user.displayName}`);
    console.log(`   Email: ${user.email}`);
    console.log(`   Password: ${user.password}`);
    console.log('');
  });
  
  console.log('📱 Test in your app now!');
}

// Run the script
main()
  .then(() => {
    console.log('\n✅ Script completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Script failed:', error);
    process.exit(1);
  });

