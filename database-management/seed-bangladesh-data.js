/**
 * Seed Script for Bangladesh Districts and Areas
 * 
 * This script populates Firestore with:
 * - 64 Bangladesh districts across 8 divisions
 * - Sample areas for major districts
 * 
 * Usage: node seed-bangladesh-data.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('./service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Load districts from JSON
const districtsData = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'assets/data/bangladesh_districts.json'), 'utf8')
);

// Sample areas for major districts
const sampleAreas = {
  // Dhaka District Areas
  'Dhaka': [
    { name: 'Gulshan', order: 1 },
    { name: 'Banani', order: 2 },
    { name: 'Dhanmondi', order: 3 },
    { name: 'Mirpur', order: 4 },
    { name: 'Uttara', order: 5 },
    { name: 'Mohammadpur', order: 6 },
    { name: 'Motijheel', order: 7 },
    { name: 'Old Dhaka', order: 8 },
    { name: 'Tejgaon', order: 9 },
    { name: 'Khilgaon', order: 10 }
  ],
  // Chittagong District Areas
  'Chittagong': [
    { name: 'Agrabad', order: 1 },
    { name: 'Pahartali', order: 2 },
    { name: 'Halishahar', order: 3 },
    { name: 'Panchlaish', order: 4 },
    { name: 'Khulshi', order: 5 },
    { name: 'Nasirabad', order: 6 }
  ],
  // Sylhet District Areas
  'Sylhet': [
    { name: 'Zindabazar', order: 1 },
    { name: 'Ambarkhana', order: 2 },
    { name: 'Bandar Bazar', order: 3 },
    { name: 'Upashahar', order: 4 }
  ],
  // Rajshahi District Areas
  'Rajshahi': [
    { name: 'Shaheb Bazar', order: 1 },
    { name: 'Motihar', order: 2 },
    { name: 'Kazla', order: 3 },
    { name: 'Boalia', order: 4 }
  ],
  // Khulna District Areas
  'Khulna': [
    { name: 'Shibbari', order: 1 },
    { name: 'Khalishpur', order: 2 },
    { name: 'Sonadanga', order: 3 },
    { name: 'Daulatpur', order: 4 }
  ],
  // Barishal District Areas
  'Barishal': [
    { name: 'Nathullabad', order: 1 },
    { name: 'Kawnia', order: 2 },
    { name: 'Kalijira', order: 3 }
  ],
  // Rangpur District Areas
  'Rangpur': [
    { name: 'Dhap', order: 1 },
    { name: 'Tajhat', order: 2 },
    { name: 'Mahiganj', order: 3 }
  ],
  // Mymensingh District Areas
  'Mymensingh': [
    { name: 'Charpara', order: 1 },
    { name: 'Akua', order: 2 },
    { name: 'Mashkanda', order: 3 }
  ]
};

async function seedDistricts() {
  console.log('🌍 Starting to seed Bangladesh districts...\n');
  
  const districtIds = {};
  let totalDistricts = 0;

  try {
    // Check if districts already exist
    const existingDistricts = await db.collection('districts').limit(1).get();
    if (!existingDistricts.empty) {
      console.log('⚠️  Districts already exist. Skipping district seeding...');
      console.log('   To re-seed, delete the districts collection first.\n');
      
      // Get existing district IDs for area seeding
      const allDistricts = await db.collection('districts').get();
      allDistricts.forEach(doc => {
        const data = doc.data();
        districtIds[data.name] = doc.id;
      });
      
      return districtIds;
    }

    // Seed districts
    const batch = db.batch();
    let batchCount = 0;

    for (const division of districtsData.divisions) {
      console.log(`📍 Seeding ${division.name} Division...`);
      
      for (const district of division.districts) {
        const docRef = db.collection('districts').doc();
        batch.set(docRef, {
          name: district.name,
          divisionName: division.name,
          order: district.order
        });
        
        districtIds[district.name] = docRef.id;
        totalDistricts++;
        batchCount++;

        // Firestore batch limit is 500
        if (batchCount >= 500) {
          await batch.commit();
          console.log(`   ✓ Committed batch (${totalDistricts} districts so far)`);
          batchCount = 0;
        }
      }
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    console.log(`\n✅ Successfully seeded ${totalDistricts} districts!\n`);
    return districtIds;

  } catch (error) {
    console.error('❌ Error seeding districts:', error);
    throw error;
  }
}

async function seedAreas(districtIds) {
  console.log('🏘️  Starting to seed sample areas...\n');
  
  let totalAreas = 0;

  try {
    // Check if areas already exist
    const existingAreas = await db.collection('areas').limit(1).get();
    if (!existingAreas.empty) {
      console.log('⚠️  Areas already exist. Skipping area seeding...');
      console.log('   To re-seed, delete the areas collection first.\n');
      return;
    }

    const batch = db.batch();
    let batchCount = 0;

    for (const [districtName, areas] of Object.entries(sampleAreas)) {
      const districtId = districtIds[districtName];
      
      if (!districtId) {
        console.log(`⚠️  District not found: ${districtName}, skipping areas`);
        continue;
      }

      console.log(`📍 Seeding areas for ${districtName}...`);

      for (const area of areas) {
        const docRef = db.collection('areas').doc();
        batch.set(docRef, {
          name: area.name,
          districtId: districtId,
          order: area.order
        });
        
        totalAreas++;
        batchCount++;

        if (batchCount >= 500) {
          await batch.commit();
          console.log(`   ✓ Committed batch (${totalAreas} areas so far)`);
          batchCount = 0;
        }
      }
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    console.log(`\n✅ Successfully seeded ${totalAreas} areas!\n`);

  } catch (error) {
    console.error('❌ Error seeding areas:', error);
    throw error;
  }
}

async function main() {
  console.log('🚀 Bangladesh Data Seeding Script\n');
  console.log('=' .repeat(50));
  console.log('\n');

  try {
    // Seed districts first
    const districtIds = await seedDistricts();
    
    // Seed sample areas
    await seedAreas(districtIds);

    console.log('=' .repeat(50));
    console.log('\n✨ All data seeded successfully!\n');
    console.log('📊 Summary:');
    console.log('   - 64 Bangladesh districts (8 divisions)');
    console.log('   - Sample areas for major cities');
    console.log('\n💡 Next steps:');
    console.log('   1. Deploy Firestore rules: firebase deploy --only firestore:rules');
    console.log('   2. Verify data in Firebase Console');
    console.log('   3. Add more areas as needed through admin panel');
    console.log('\n');

  } catch (error) {
    console.error('\n❌ Seeding failed:', error);
    process.exit(1);
  }

  process.exit(0);
}

// Run the script
main();

