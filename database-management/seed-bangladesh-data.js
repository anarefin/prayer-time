/**
 * Seed Script for Bangladesh Districts and Areas
 * 
 * This script populates Firestore with:
 * - 64 Bangladesh districts across 8 divisions
 * - All Upazilas (Areas) for each district
 * 
 * usage: node seed-bangladesh-data.js
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

// Helper to load and parse specific table data from the raw JSON structure
function loadData(filename, tableName) {
  const filePath = path.join(__dirname, 'assets/data', filename);
  const rawData = fs.readFileSync(filePath, 'utf8');
  const jsonContent = JSON.parse(rawData);

  // Find the table data
  const table = jsonContent.find(item => item.type === 'table' && item.name === tableName);
  if (!table || !table.data) {
    throw new Error(`Could not find table '${tableName}' in ${filename}`);
  }
  return table.data;
}

// Load data
const divisionsData = loadData('divisions.json', 'divisions');
const districtsData = loadData('districts.json', 'districts');
const upazilasData = loadData('upazilas.json', 'upazilas');

async function seedDistricts() {
  console.log('🌍 Starting to seed Bangladesh districts...\n');

  // Map legacy ID to new Firestore ID
  const districtIdMap = {};
  let totalDistricts = 0;

  try {
    // Check if districts already exist
    const existingDistricts = await db.collection('districts').limit(1).get();
    if (!existingDistricts.empty) {
      console.log('⚠️  Districts already exist. Skipping district seeding...');
      console.log('   To re-seed, delete the districts collection first.\n');

      // If we are skipping, we still need the map for areas
      // However, since we might have generated random IDs, we can't easily map back 
      // from the external JSON IDs unless we stored them. 
      // For this task, we assume we are seeding fresh or replacing. 
      // If data exists, we will TRY to match by name, but it's safer to recommend clearing.
      console.log('⚠️  Cannot safely map existing districts to source data for area seeding.');
      console.log('⚠️  Please delete existing \'districts\' and \'areas\' collections to ensure integrity.');
      return null;
    }

    const batch = db.batch();
    let batchCount = 0;

    // Create a lookup for division names
    const divisionMap = {};
    divisionsData.forEach(div => {
      divisionMap[div.id] = div.name;
    });

    for (const district of districtsData) {
      const docRef = db.collection('districts').doc();

      const districtPayload = {
        name: district.name,
        bnName: district.bn_name,
        divisionName: divisionMap[district.division_id] || 'Unknown',
        divisionId: district.division_id, // Store source ID for reference
        lat: district.lat,
        lon: district.lon,
        url: district.url,
        order: parseInt(district.id) // Use source ID as order or simple sort key
      };

      batch.set(docRef, districtPayload);

      // Map the source ID (e.g., "1") to the new Firestore ID
      districtIdMap[district.id] = docRef.id;

      totalDistricts++;
      batchCount++;

      if (batchCount >= 500) {
        await batch.commit();
        console.log(`   ✓ Committed batch (${totalDistricts} districts so far)`);
        batchCount = 0;
      }
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    console.log(`\n✅ Successfully seeded ${totalDistricts} districts!\n`);
    return districtIdMap;

  } catch (error) {
    console.error('❌ Error seeding districts:', error);
    throw error;
  }
}

// Hardcoded Dhaka City Thanas (Administrative Units within City Corporations)
// These are not in the standard upazila list but are crucial for urban Dhaka context.
const dhakaThanas = [
  // DNCC
  { name: 'Gulshan', bnName: 'গুলশান' },
  { name: 'Banani', bnName: 'বনানী' },
  { name: 'Uttara', bnName: 'উত্তরা' },
  { name: 'Mirpur', bnName: 'মিরপুর' },
  { name: 'Mohammadpur', bnName: 'মোহাম্মদপুর' },
  { name: 'Badda', bnName: 'বাড্ডা' },
  { name: 'Tejgaon', bnName: 'তেজগাঁও' },
  { name: 'Cantonment', bnName: 'ক্যান্টনমেনট' },
  { name: 'Pallabi', bnName: 'পল্লবী' },
  { name: 'Kafrul', bnName: 'কাফরুল' },
  { name: 'Rampura', bnName: 'রামপুরা' },
  { name: 'Khilkhet', bnName: 'খিলক্ষেত' },
  // DSCC
  { name: 'Dhanmondi', bnName: 'ধানমন্ডি' },
  { name: 'Motijheel', bnName: 'মতিঝিল' },
  { name: 'Ramna', bnName: 'রমনা' },
  { name: 'Shahbag', bnName: 'শাহবাগ' },
  { name: 'Lalbagh', bnName: 'লালবাগ' },
  { name: 'Wari', bnName: 'ওয়ারী' },
  { name: 'Jatrabari', bnName: 'যাত্রাবাড়ী' },
  { name: 'Khilgaon', bnName: 'খিলগাঁও' },
  { name: 'Kotwali', bnName: 'কোতোয়ালী' },
  { name: 'Sutrapur', bnName: 'সূত্রাপুর' },
  { name: 'Chawkbazar', bnName: 'চকবাজার' }
];

async function seedAreas(districtIdMap) {
  if (!districtIdMap) return;

  console.log('🏘️  Starting to seed areas (Upazilas & Thanas)...\n');

  let totalAreas = 0;

  try {
    const existingAreas = await db.collection('areas').limit(1).get();
    if (!existingAreas.empty) {
      console.log('⚠️  Areas already exist. Skipping area seeding...');
      return;
    }

    // We will batch process
    // Firestore batch limit is 500 operations
    const BATCH_SIZE = 500;
    let batch = db.batch();
    let batchCount = 0;

    // 1. Seed Standard Upazilas
    console.log('   📍 Processing standard Upazilas...');
    for (const upazila of upazilasData) {
      const firestoreDistrictId = districtIdMap[upazila.district_id];

      if (!firestoreDistrictId) {
        console.warn(`   ⚠️  Skipping upazila ${upazila.name}: District ID ${upazila.district_id} not found in map.`);
        continue;
      }

      const docRef = db.collection('areas').doc();

      batch.set(docRef, {
        name: upazila.name,
        bnName: upazila.bn_name,
        districtId: firestoreDistrictId,
        url: upazila.url,
        order: parseInt(upazila.id),
        type: 'upazila' // Mark as standard upazila
      });

      totalAreas++;
      batchCount++;

      if (batchCount >= BATCH_SIZE) {
        await batch.commit();
        console.log(`   ✓ Committed batch (${totalAreas} areas so far)`);
        batch = db.batch();
        batchCount = 0;
      }
    }

    // 2. Seed Dhaka Thanas
    // We need to find the Firestore ID for 'Dhaka' district.
    // The source ID for Dhaka district in the JSON is usually known or we can look it up in districtsData.
    // In standard nuhil/bangladesh-geocode, Dhaka district has an ID.
    // Let's find it dynamically from the source data to be safe.
    const dhakaDistrictSource = districtsData.find(d => d.name === 'Dhaka');

    if (dhakaDistrictSource) {
      const dhakaFirestoreId = districtIdMap[dhakaDistrictSource.id];

      if (dhakaFirestoreId) {
        console.log('   📍 Processing Dhaka City Thanas...');

        for (const thana of dhakaThanas) {
          const docRef = db.collection('areas').doc();

          batch.set(docRef, {
            name: thana.name,
            bnName: thana.bnName,
            districtId: dhakaFirestoreId,
            url: '', // Thanas might not have URLs in this specific context, or we leave empty
            order: 9000 + totalAreas, // Arbitrary high order to put them at end or distinct
            type: 'thana' // Mark as urban thana
          });

          totalAreas++;
          batchCount++;

          if (batchCount >= BATCH_SIZE) {
            await batch.commit();
            console.log(`   ✓ Committed batch (${totalAreas} areas so far)`);
            batch = db.batch();
            batchCount = 0;
          }
        }
      } else {
        console.warn('   ⚠️  Creation of Dhaka Thanas skipped: Dhaka district ID not found in map.');
      }
    } else {
      console.warn('   ⚠️  Creation of Dhaka Thanas skipped: Dhaka district not found in source data.');
    }

    // Final commit
    if (batchCount > 0) {
      await batch.commit();
    }

    console.log(`\n✅ Successfully seeded ${totalAreas} areas (Upazilas & Thanas)!\n`);

  } catch (error) {
    console.error('❌ Error seeding areas:', error);
    throw error;
  }
}

async function main() {
  console.log('🚀 Bangladesh Data Seeding Script (Full Data)\n');
  console.log('='.repeat(50));
  console.log('\n');

  try {
    // Seed districts and get id map
    const districtIdMap = await seedDistricts();

    // Seed areas if districts were seeded successfully
    if (districtIdMap) {
      await seedAreas(districtIdMap);
    }

    console.log('='.repeat(50));
    console.log('\n✨ Data seeding process completed.\n');
    console.log('💡 Note: If you see "Skipping..." messages, clear your Firestore "districts" and "areas" collections and run this script again.');
    console.log('\n');

  } catch (error) {
    console.error('\n❌ Seeding failed:', error);
    process.exit(1);
  }

  process.exit(0);
}

// Run the script
main();
