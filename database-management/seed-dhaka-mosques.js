/**
 * Seed Sample Mosques and Prayer Times for Dhaka District
 * 
 * This script will:
 * 1. Seed mosques with facilities
 * 2. Generate 30 days of prayer times for each mosque
 * 3. Include Jummah times for Fridays
 * 
 * Usage: node seed-dhaka-mosques.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Sample mosques for Dhaka areas
const dhakaМosques = [
  // Gulshan Area
  {
    name: 'Gulshan Central Mosque',
    address: 'Gulshan Avenue, Road 11, Gulshan, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7925,
    longitude: 90.4078,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasBikeParking: true,
    hasCycleParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    hasChairPrayer: true,
    description: 'Large mosque with modern facilities in the heart of Gulshan'
  },
  {
    name: 'Gulshan Azad Mosque',
    address: 'Road 27, Gulshan 1, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7805,
    longitude: 90.4168,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasBikeParking: true,
    hasCycleParking: false,
    hasWudu: true,
    hasAC: false,
    isWheelchairAccessible: false,
    hasChairPrayer: false,
    description: 'Community mosque in Gulshan residential area'
  },
  // Banani Area
  {
    name: 'Banani Jame Masjid',
    address: 'Road 12, Block C, Banani, Dhaka',
    areaName: 'Banani',
    latitude: 23.7937,
    longitude: 90.4066,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasBikeParking: true,
    hasCycleParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    hasChairPrayer: true,
    description: 'Modern mosque with excellent facilities'
  },
  // Dhanmondi Area
  {
    name: 'Dhanmondi 27 Mosque',
    address: 'Road 27, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7461,
    longitude: 90.3742,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasBikeParking: true,
    hasCycleParking: true,
    hasWudu: true,
    hasAC: false,
    isWheelchairAccessible: false,
    hasChairPrayer: false,
    description: 'Community mosque in Dhanmondi residential area'
  },
  {
    name: 'Sat Masjid (Seven Domed Mosque)',
    address: 'Sat Masjid Road, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7290,
    longitude: 90.3854,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasBikeParking: true,
    hasCycleParking: true,
    hasWudu: true,
    hasAC: false,
    isWheelchairAccessible: false,
    hasChairPrayer: false,
    description: 'Historic mosque dating back to Mughal era'
  },
  // Mirpur Area
  {
    name: 'Mirpur 10 Central Mosque',
    address: 'Mirpur 10 Circle, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8069,
    longitude: 90.3687,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasBikeParking: true,
    hasCycleParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    hasChairPrayer: true,
    description: 'Large central mosque serving Mirpur community'
  },
  // Uttara Area
  {
    name: 'Uttara Sector 3 Jame Masjid',
    address: 'Sector 3, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8759,
    longitude: 90.3795,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasBikeParking: true,
    hasCycleParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    hasChairPrayer: true,
    description: 'Modern mosque with state-of-the-art facilities'
  },
  {
    name: 'Uttara Azampur Mosque',
    address: 'Azampur, Sector 15, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8689,
    longitude: 90.3895,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasBikeParking: true,
    hasCycleParking: true,
    hasWudu: true,
    hasAC: false,
    isWheelchairAccessible: false,
    hasChairPrayer: false,
    description: 'Community mosque in Uttara'
  },
  // Mohammadpur Area
  {
    name: 'Mohammadpur Town Hall Mosque',
    address: 'Town Hall, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7654,
    longitude: 90.3563,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasBikeParking: true,
    hasCycleParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    hasChairPrayer: true,
    description: 'Central mosque in Mohammadpur with large prayer hall'
  },
  // Motijheel Area
  {
    name: 'Baitul Mukarram National Mosque',
    address: 'Topkhana Road, Motijheel, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7308,
    longitude: 90.4153,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasBikeParking: true,
    hasCycleParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    hasChairPrayer: true,
    description: 'National Mosque of Bangladesh with capacity for 30,000 worshippers'
  },
  // Old Dhaka Area
  {
    name: 'Khan Mohammad Mridha Mosque',
    address: 'Lalbagh, Old Dhaka',
    areaName: 'Old Dhaka',
    latitude: 23.7197,
    longitude: 90.3876,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasBikeParking: true,
    hasCycleParking: false,
    hasWudu: true,
    hasAC: false,
    isWheelchairAccessible: false,
    hasChairPrayer: false,
    description: 'Historic Mughal-era mosque built in 1704-05'
  },
  {
    name: 'Star Mosque (Tara Masjid)',
    address: 'Armanitola, Old Dhaka',
    areaName: 'Old Dhaka',
    latitude: 23.7172,
    longitude: 90.4138,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasBikeParking: false,
    hasCycleParking: false,
    hasWudu: true,
    hasAC: false,
    isWheelchairAccessible: false,
    hasChairPrayer: false,
    description: 'Historic mosque famous for its star motifs and Japanese porcelain tiles'
  },
  // Tejgaon Area
  {
    name: 'Tejgaon Industrial Area Mosque',
    address: 'Tejgaon Industrial Area, Dhaka',
    areaName: 'Tejgaon',
    latitude: 23.7644,
    longitude: 90.3987,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasBikeParking: true,
    hasCycleParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    hasChairPrayer: true,
    description: 'Large mosque serving the industrial area workers'
  },
  // Khilgaon Area
  {
    name: 'Khilgaon Chowdhury Para Mosque',
    address: 'Chowdhury Para, Khilgaon, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7542,
    longitude: 90.4254,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasBikeParking: true,
    hasCycleParking: true,
    hasWudu: true,
    hasAC: false,
    isWheelchairAccessible: false,
    hasChairPrayer: false,
    description: 'Community mosque in Khilgaon residential area'
  }
];

/**
 * Generate prayer times for a specific date with slight random variations
 */
function generatePrayerTimes(date) {
  // Base prayer times for Dhaka, Bangladesh (approximate)
  const baseTimes = {
    fajr: { hour: 5, minute: 10 },
    dhuhr: { hour: 12, minute: 20 },
    asr: { hour: 16, minute: 10 },
    maghrib: { hour: 18, minute: 5 },
    isha: { hour: 19, minute: 25 },
    jummah: { hour: 13, minute: 0 }
  };

  // Add slight variations (±15 minutes) for mosque-specific times
  const variation = () => Math.floor(Math.random() * 31) - 15; // -15 to +15 minutes

  const formatTime = (hour, minute, vary = true) => {
    let totalMinutes = hour * 60 + minute;
    if (vary) {
      totalMinutes += variation();
    }
    const h = Math.floor(totalMinutes / 60) % 24;
    const m = totalMinutes % 60;
    return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`;
  };

  const prayerTimes = {
    fajr: formatTime(baseTimes.fajr.hour, baseTimes.fajr.minute),
    dhuhr: formatTime(baseTimes.dhuhr.hour, baseTimes.dhuhr.minute),
    asr: formatTime(baseTimes.asr.hour, baseTimes.asr.minute),
    maghrib: formatTime(baseTimes.maghrib.hour, baseTimes.maghrib.minute),
    isha: formatTime(baseTimes.isha.hour, baseTimes.isha.minute)
  };

  // Add Jummah time if it's Friday (day 5, since Sunday is 0)
  if (date.getDay() === 5) {
    prayerTimes.jummah = formatTime(baseTimes.jummah.hour, baseTimes.jummah.minute);
  }

  return prayerTimes;
}

/**
 * Format date as YYYY-MM-DD
 */
function formatDate(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/**
 * Seed prayer times for all mosques (30 days from today)
 */
async function seedPrayerTimes(mosqueIds) {
  console.log('\n' + '='.repeat(50));
  console.log('⏰ Seeding prayer times...\n');

  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const days = 30;

  let batch = db.batch();
  let batchCount = 0;
  let totalPrayerTimes = 0;

  for (const mosqueId of mosqueIds) {
    console.log(`\n📅 Generating prayer times for mosque: ${mosqueId}`);
    
    for (let i = 0; i < days; i++) {
      const date = new Date(today);
      date.setDate(date.getDate() + i);
      
      const dateStr = formatDate(date);
      const prayerTimes = generatePrayerTimes(date);
      
      // Document ID format: mosqueId_YYYY-MM-DD
      const docId = `${mosqueId}_${dateStr}`;
      
      const prayerTimeDoc = {
        mosqueId: mosqueId,
        date: dateStr,
        ...prayerTimes
      };

      const docRef = db.collection('prayer_times').doc(docId);
      batch.set(docRef, prayerTimeDoc);
      
      batchCount++;
      totalPrayerTimes++;

      // Commit batch every 500 documents
      if (batchCount >= 500) {
        await batch.commit();
        console.log(`   ✓ Committed batch (${totalPrayerTimes} prayer times so far)`);
        batch = db.batch();
        batchCount = 0;
      }
    }
    
    console.log(`   ✓ Added ${days} days of prayer times`);
  }

  // Commit remaining documents
  if (batchCount > 0) {
    await batch.commit();
  }

  console.log('\n' + '='.repeat(50));
  console.log(`\n✅ Successfully seeded ${totalPrayerTimes} prayer times!`);
  console.log(`   - ${mosqueIds.length} mosques`);
  console.log(`   - ${days} days per mosque`);
  console.log(`   - Includes Jummah times for Fridays\n`);
}

async function seedMosques() {
  console.log('🕌 Starting to seed Dhaka mosques...\n');

  try {
    // Get Dhaka district ID
    const districtsSnapshot = await db.collection('districts')
      .where('name', '==', 'Dhaka')
      .limit(1)
      .get();

    if (districtsSnapshot.empty) {
      console.error('❌ Dhaka district not found! Please seed districts first.');
      process.exit(1);
    }

    const dhakaDistrictId = districtsSnapshot.docs[0].id;
    console.log(`✓ Found Dhaka district: ${dhakaDistrictId}\n`);

    // Get area IDs for Dhaka district
    const areasSnapshot = await db.collection('areas')
      .where('districtId', '==', dhakaDistrictId)
      .get();

    const areaMap = {};
    areasSnapshot.docs.forEach(doc => {
      const data = doc.data();
      areaMap[data.name] = doc.id;
    });

    console.log(`✓ Found ${Object.keys(areaMap).length} areas in Dhaka district\n`);

    // Seed mosques
    const batch = db.batch();
    let batchCount = 0;
    let totalMosques = 0;
    let skippedMosques = 0;
    const mosqueIds = []; // Track mosque IDs for prayer time seeding

    for (const mosque of dhakaМosques) {
      const areaId = areaMap[mosque.areaName];
      
      if (!areaId) {
        console.log(`⚠️  Area "${mosque.areaName}" not found, skipping ${mosque.name}`);
        skippedMosques++;
        continue;
      }

      const { areaName, ...mosqueData } = mosque;
      mosqueData.areaId = areaId;

      const docRef = db.collection('mosques').doc();
      batch.set(docRef, mosqueData);
      
      mosqueIds.push(docRef.id); // Store the generated ID

      console.log(`✓ Adding: ${mosque.name} (${mosque.areaName})`);
      
      totalMosques++;
      batchCount++;

      if (batchCount >= 500) {
        await batch.commit();
        console.log(`   Committed batch (${totalMosques} mosques so far)`);
        batchCount = 0;
      }
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    console.log('\n' + '='.repeat(50));
    console.log(`\n✅ Successfully seeded ${totalMosques} mosques!`);
    if (skippedMosques > 0) {
      console.log(`⚠️  Skipped ${skippedMosques} mosques (areas not found)`);
    }

    // Now seed prayer times for all mosques
    if (mosqueIds.length > 0) {
      await seedPrayerTimes(mosqueIds);
    }

    console.log('\n' + '='.repeat(50));
    console.log('\n🎉 ALL DONE!\n');
    console.log('💡 Next steps:');
    console.log('   - Run the app and browse mosques in Dhaka');
    console.log('   - View prayer times for any mosque');
    console.log('   - Prayer times are set for the next 30 days');
    console.log('   - Fridays include Jummah prayer times\n');

  } catch (error) {
    console.error('❌ Error seeding data:', error);
    process.exit(1);
  }

  process.exit(0);
}

seedMosques();

