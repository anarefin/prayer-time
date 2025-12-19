#!/usr/bin/env node

/**
 * Firestore Initialization Script
 * 
 * This script initializes your Firestore database with sample data
 * including users, areas, mosques, and prayer times.
 * 
 * Prerequisites:
 * 1. Install: npm install firebase-admin
 * 2. Download service account key from Firebase Console
 * 3. Set GOOGLE_APPLICATION_CREDENTIALS environment variable
 * 
 * Usage:
 * node init-firestore.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
try {
  // Try to use service account key file if it exists
  const serviceAccountPath = path.join(__dirname, 'service-account-key.json');
  
  if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    console.log('✅ Firebase Admin initialized with service account key');
  } else {
    // Use default credentials (requires GOOGLE_APPLICATION_CREDENTIALS env var)
    admin.initializeApp();
    console.log('✅ Firebase Admin initialized with default credentials');
  }
} catch (error) {
  console.error('❌ Failed to initialize Firebase Admin:', error.message);
  console.log('\n📝 Setup instructions:');
  console.log('1. Download service account key from Firebase Console:');
  console.log('   - Go to: Project Settings > Service Accounts');
  console.log('   - Click "Generate new private key"');
  console.log('   - Save as: service-account-key.json');
  console.log('\n2. Or set GOOGLE_APPLICATION_CREDENTIALS environment variable:');
  console.log('   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"');
  process.exit(1);
}

const db = admin.firestore();

// Load sample data
const sampleDataPath = path.join(__dirname, 'firestore-sample-data.json');
let sampleData;

try {
  sampleData = JSON.parse(fs.readFileSync(sampleDataPath, 'utf8'));
  console.log('✅ Sample data loaded');
} catch (error) {
  console.error('❌ Failed to load sample data:', error.message);
  process.exit(1);
}

/**
 * Initialize a collection with sample data
 */
async function initializeCollection(collectionName, data) {
  console.log(`\n📦 Initializing ${collectionName} collection...`);
  
  const batch = db.batch();
  let count = 0;
  
  for (const [docId, docData] of Object.entries(data)) {
    const docRef = db.collection(collectionName).doc(docId);
    
    // Check if document already exists
    const doc = await docRef.get();
    if (doc.exists) {
      console.log(`   ⚠️  Document ${docId} already exists, skipping`);
      continue;
    }
    
    batch.set(docRef, docData);
    count++;
    console.log(`   ✓ Queued: ${docId}`);
  }
  
  if (count > 0) {
    await batch.commit();
    console.log(`   ✅ Created ${count} documents in ${collectionName}`);
  } else {
    console.log(`   ℹ️  No new documents to create`);
  }
  
  return count;
}

/**
 * Verify collections exist and have data
 */
async function verifyCollections() {
  console.log('\n🔍 Verifying collections...');
  
  const collections = ['users', 'areas', 'mosques', 'prayer_times'];
  const results = {};
  
  for (const collectionName of collections) {
    const snapshot = await db.collection(collectionName).get();
    results[collectionName] = snapshot.size;
    console.log(`   ${collectionName}: ${snapshot.size} documents`);
  }
  
  return results;
}

/**
 * Update existing user roles (for existing Firebase Auth users)
 */
async function updateUserRoles() {
  console.log('\n👥 Updating user roles...');
  
  const usersToUpdate = [
    { uid: '6fAVoF9OgtYKI70a2ZDDjyafEhE2', email: 'arefin@arefin.com', role: 'admin' },
    { uid: 'DSpqEl1rjzZjWdOzxRVjQ8g1lNj2', email: 'test@test.com', role: 'user' }
  ];
  
  for (const user of usersToUpdate) {
    try {
      await db.collection('users').doc(user.uid).set({
        email: user.email,
        role: user.role,
        favorites: []
      }, { merge: true });
      
      console.log(`   ✓ Updated ${user.email} (${user.role})`);
    } catch (error) {
      console.log(`   ⚠️  Could not update ${user.email}: ${error.message}`);
    }
  }
}

/**
 * Main execution
 */
async function main() {
  console.log('🚀 Starting Firestore initialization...\n');
  console.log('Project ID:', admin.app().options.projectId || '(default)');
  
  try {
    // Initialize collections
    let totalCreated = 0;
    
    // Update existing users first
    await updateUserRoles();
    
    // Then create other collections
    totalCreated += await initializeCollection('areas', sampleData.areas);
    totalCreated += await initializeCollection('mosques', sampleData.mosques);
    totalCreated += await initializeCollection('prayer_times', sampleData.prayer_times);
    
    // Verify all collections
    const results = await verifyCollections();
    
    // Summary
    console.log('\n✅ Initialization complete!');
    console.log(`   📊 Total documents created: ${totalCreated}`);
    console.log('\n📋 Final collection counts:');
    console.log(`   - users: ${results.users}`);
    console.log(`   - areas: ${results.areas}`);
    console.log(`   - mosques: ${results.mosques}`);
    console.log(`   - prayer_times: ${results.prayer_times}`);
    
    console.log('\n🎉 Your Firestore database is ready!');
    console.log('\n📱 You can now test the app with:');
    console.log('   Admin: arefin@arefin.com');
    console.log('   User: test@test.com');
    
  } catch (error) {
    console.error('\n❌ Initialization failed:', error);
    throw error;
  }
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

