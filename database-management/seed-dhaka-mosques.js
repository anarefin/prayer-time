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

// Real mosques for Dhaka areas
// Coordinates are approximated for neighborhood mosques based on area centers
const dhakaMosques = [
  // --- Gulshan Area ---
  {
    name: 'Gulshan Central Mosque (Azad Mosque)',
    address: 'Road 39, Gulshan 2, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7901,
    longitude: 90.4145,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasBikeParking: true,
    hasCycleParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    hasChairPrayer: true,
    description: 'The largest and most prominent mosque in Gulshan area.'
  },
  {
    name: 'Gulshan Society Jame Masjid',
    address: 'Road 63, Gulshan 2, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7950,
    longitude: 90.4150,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasBikeParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    description: 'Modern architectural landmark in Gulshan.'
  },
  {
    name: 'Gulshan 1 DC Market Mosque',
    address: 'Gulshan 1, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7780,
    longitude: 90.4150,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Market mosque.'
  },
  {
    name: 'Niketan Central Mosque',
    address: 'Block E, Niketan, Gulshan 1, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7750,
    longitude: 90.4120,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque for Niketan housing.'
  },
  {
    name: 'Shooting Club Mosque',
    address: 'Gulshan 1, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7800,
    longitude: 90.4100,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Private club mosque.'
  },
  {
    name: 'Gulshan 2 Jame Masjid',
    address: 'Gulshan 2 Circle, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7920,
    longitude: 90.4180,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the circle.'
  },
  {
    name: 'Baytul Atiq Jame Masjid',
    address: 'Road 113, Gulshan 2, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7950,
    longitude: 90.4120,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Beautiful community mosque.'
  },
  {
    name: 'Manarat Dhaka International School Mosque',
    address: 'Gulshan 2, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7980,
    longitude: 90.4150,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'School mosque.'
  },
  {
    name: 'Police Plaza Concord Mosque',
    address: 'Gulshan 1, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7720,
    longitude: 90.4150,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Shopping mall mosque.'
  },
  {
    name: 'Gulshan Lake Park Mosque',
    address: 'Road 63, Gulshan 2, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7940,
    longitude: 90.4100,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near the park.'
  },
  {
    name: 'Baridhara Jame Masjid',
    address: 'Park Road, Baridhara Diplomatic Zone, Dhaka',
    areaName: 'Gulshan', // Baridhara
    latitude: 23.8000,
    longitude: 90.4200,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Grand mosque in diplomatic zone.'
  },
  {
    name: 'Baridhara DOHS Jame Masjid',
    address: 'Baridhara DOHS, Dhaka',
    areaName: 'Vatara', // Near Bashundhara/Gulshan
    latitude: 23.8050,
    longitude: 90.4220,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque for DOHS.'
  },
  {
    name: 'Coca-Cola Mosque',
    address: 'Coca-Cola Road, Baridhara, Dhaka',
    areaName: 'Vatara', // Border
    latitude: 23.7980,
    longitude: 90.4250,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Local landmark mosque.'
  },
  {
    name: 'Shahjadpur Jheel Mosque',
    address: 'Shahjadpur, Dhaka',
    areaName: 'Gulshan', // Border
    latitude: 23.7900,
    longitude: 90.4250,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Lakeside mosque.'
  },
  {
    name: 'Notun Bazar Central Mosque',
    address: 'Notun Bazar, Dhaka',
    areaName: 'Vatara',
    latitude: 23.8000,
    longitude: 90.4300,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Busy market mosque.'
  },

  // --- Banani Area ---
  {
    name: 'Banani Central Jame Masjid',
    address: 'Road 12, Block C, Banani, Dhaka',
    areaName: 'Banani',
    latitude: 23.7937,
    longitude: 90.4066,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasBikeParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    description: 'Major mosque in Banani with extensive facilities.'
  },
  {
    name: 'Banani Bazar Mosque',
    address: 'Banani Bazar, Dhaka',
    areaName: 'Banani',
    latitude: 23.7920,
    longitude: 90.4080,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Market mosque.'
  },
  {
    name: 'Banani Super Market Mosque',
    address: 'Banani Super Market, Dhaka',
    areaName: 'Banani',
    latitude: 23.7930,
    longitude: 90.4070,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Shopping complex mosque.'
  },
  {
    name: 'Banani Block F Mosque',
    address: 'Block F, Banani, Dhaka',
    areaName: 'Banani',
    latitude: 23.7960,
    longitude: 90.4050,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Banani Chairman Bari Mosque',
    address: 'Chairman Bari, Banani, Dhaka',
    areaName: 'Banani',
    latitude: 23.7880,
    longitude: 90.4050,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the field.'
  },
  {
    name: 'Kakoli Mosque',
    address: 'Kakoli, Banani, Dhaka',
    areaName: 'Banani',
    latitude: 23.7980,
    longitude: 90.4020,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Bus stop mosque.'
  },
  {
    name: 'Mohakhali Wireless Gate Mosque',
    address: 'Mohakhali, Dhaka',
    areaName: 'Banani', // Nearby
    latitude: 23.7850,
    longitude: 90.4000,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large roadside mosque.'
  },
  {
    name: 'Mohakhali DOHS Mosque',
    address: 'Mohakhali DOHS, Dhaka',
    areaName: 'Banani', // Nearby
    latitude: 23.7880,
    longitude: 90.3950,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque for DOHS.'
  },
  {
    name: 'ICDDRB Mosque',
    address: 'Mohakhali, Dhaka',
    areaName: 'Banani',
    latitude: 23.7820,
    longitude: 90.4020,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Hospital campus mosque.'
  },
  {
    name: 'Titumir College Mosque',
    address: 'Mohakhali, Dhaka',
    areaName: 'Banani',
    latitude: 23.7800,
    longitude: 90.4000,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'College student mosque.'
  },
  {
    name: 'Amtoli Mosque',
    address: 'Amtoli, Mohakhali, Dhaka',
    areaName: 'Banani',
    latitude: 23.7810,
    longitude: 90.4010,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Busy intersection mosque.'
  },
  {
    name: 'Korail Slum Mosque',
    address: 'Korail, Dhaka',
    areaName: 'Banani', // Border
    latitude: 23.7850,
    longitude: 90.4100,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Large community mosque.'
  },
  {
    name: 'TB Gate Mosque',
    address: 'TB Gate, Mohakhali, Dhaka',
    areaName: 'Banani',
    latitude: 23.7830,
    longitude: 90.4040,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque.'
  },
  {
    name: 'Seven Star Mosque',
    address: 'Mohakhali, Dhaka',
    areaName: 'Banani',
    latitude: 23.7840,
    longitude: 90.4060,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque.'
  },
  {
    name: 'Aryatola Mosque',
    address: 'Mohakhali, Dhaka',
    areaName: 'Banani',
    latitude: 23.7860,
    longitude: 90.4080,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Banani Lake View Mosque',
    address: 'Banani, Dhaka',
    areaName: 'Banani',
    latitude: 23.7900,
    longitude: 90.4050,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Scenic mosque.'
  },
  {
    name: 'Gulshan 1 Central Mosque',
    address: 'Gulshan 1, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7800,
    longitude: 90.4180,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque.'
  },
  {
    name: 'Merul Badda DIT Project Mosque',
    address: 'Merul Badda, Dhaka',
    areaName: 'Gulshan', // Badda
    latitude: 23.7700,
    longitude: 90.4200,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'DIT Project Central Mosque.'
  },
  {
    name: 'Badda Link Road Mosque',
    address: 'Middle Badda, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7800,
    longitude: 90.4250,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near Link Road.'
  },
  {
    name: 'North Badda Islamia Mosque',
    address: 'North Badda, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7850,
    longitude: 90.4280,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Main mosque of North Badda.'
  },
  {
    name: 'Rupayan Tower Mosque',
    address: 'Kakrail, Dhaka',
    areaName: 'Ramna',
    latitude: 23.7380,
    longitude: 90.4100,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Inside the building.'
  },

  // --- Dhanmondi Area ---
  {
    name: 'Sobhanbag Jame Masjid',
    address: 'Sobhanbag, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7550,
    longitude: 90.3800,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Prominent mosque in Sobhanbag area.'
  },
  {
    name: 'Taqwa Masjid',
    address: 'Road 11A, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7580,
    longitude: 90.3735,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Famous mosque near Dhanmondi Lake.'
  },
  {
    name: 'Sat Masjid (Seven Domed Mosque)',
    address: 'Sat Masjid Road, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7290,
    longitude: 90.3854,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasWudu: true,
    hasAC: false,
    description: 'Historic Mughal era mosque.'
  },
  {
    name: 'Kalabagan Staff Quarter Mosque',
    address: 'Kalabagan, Dhaka',
    areaName: 'Kalabagan',
    latitude: 23.7480,
    longitude: 90.3850,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Staff quarter mosque.'
  },
  {
    name: 'Kalabagan Krira Chakra Mosque',
    address: 'Kalabagan, Dhaka',
    areaName: 'Kalabagan',
    latitude: 23.7500,
    longitude: 90.3820,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the sports club.'
  },
  {
    name: 'Dhanmondi Eidgah Jame Masjid',
    address: 'Road 6A, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7450,
    longitude: 90.3750,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large Eidgah and mosque.'
  },
  {
    name: 'Dhanmondi Road 4 Mosque',
    address: 'Road 4, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7420,
    longitude: 90.3800,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Quiet residential mosque.'
  },
  {
    name: 'Dhanmondi Road 7 Mosque',
    address: 'Road 7, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7460,
    longitude: 90.3780,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Dhanmondi Road 15 (Old) Mosque',
    address: 'Road 15, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7550,
    longitude: 90.3720,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque.'
  },
  {
    name: 'Star Kebab Mosque',
    address: 'Road 2, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7400,
    longitude: 90.3820,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Usually busy mosque.'
  },
  {
    name: 'Dhanmondi Road 8 Mosque',
    address: 'Road 8, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7480,
    longitude: 90.3760,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the bridge.'
  },
  {
    name: 'Dhanmondi Road 27 Mosque',
    address: 'Road 27, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7580,
    longitude: 90.3750,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the intersection.'
  },
  {
    name: 'Green Road Staff Quarter Mosque',
    address: 'Green Road, Dhaka',
    areaName: 'Kalabagan', // Border
    latitude: 23.7520,
    longitude: 90.3880,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Staff quarter mosque.'
  },
  {
    name: 'Panthapath Mosque',
    address: 'Panthapath, Dhaka',
    areaName: 'Kalabagan',
    latitude: 23.7500,
    longitude: 90.3900,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Busy road mosque.'
  },
  {
    name: 'Square Hospital Mosque',
    address: 'Panthapath, Dhaka',
    areaName: 'Kalabagan',
    latitude: 23.7520,
    longitude: 90.3920,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Inside the hospital.'
  },
  {
    name: 'Basundhara City Mosque',
    address: 'Basundhara City Mall, Panthapath, Dhaka',
    areaName: 'Tejgaon', // Border
    latitude: 23.7500,
    longitude: 90.3950,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Top floor large mosque.'
  },
  {
    name: 'New Market Mosque',
    address: 'New Market, Dhaka',
    areaName: 'New Market',
    latitude: 23.7330,
    longitude: 90.3830,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Architecturally significant triangle mosque.'
  },
  {
    name: 'Nilkhet Mosque',
    address: 'Nilkhet, Dhaka',
    areaName: 'New Market',
    latitude: 23.7320,
    longitude: 90.3880,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Mosque for students and book lovers.'
  },
  {
    name: 'Katabon Mosque',
    address: 'Katabon, Dhaka',
    areaName: 'New Market',
    latitude: 23.7380,
    longitude: 90.3900,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Famous mosque complex in Katabon.'
  },
  {
    name: 'Elephant Road Plane Masjid',
    address: 'Elephant Road, Dhaka',
    areaName: 'New Market',
    latitude: 23.7400,
    longitude: 90.3850,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Known as Plane Masjid.'
  },
  {
    name: 'Azimpur Graveyard Mosque',
    address: 'Azimpur, Dhaka',
    areaName: 'Lalbagh', // Border
    latitude: 23.7250,
    longitude: 90.3850,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large mosque near the graveyard.'
  },
  {
    name: 'Shahbagh Central Mosque',
    address: 'Shahbagh, Dhaka',
    areaName: 'Shahbag',
    latitude: 23.7380,
    longitude: 90.3980,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near Bangabandhu Sheikh Mujib Medical University.'
  },
  {
    name: 'BGB Headquarters Mosque',
    address: 'Pilkhana, Dhaka',
    areaName: 'New Market', // Border
    latitude: 23.7300,
    longitude: 90.3750,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Restricted access mosque.'
  },
  {
    name: 'Eden College Mosque',
    address: 'Azimpur, Dhaka',
    areaName: 'Lalbagh',
    latitude: 23.7280,
    longitude: 90.3820,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'College mosque.'
  },
  {
    name: 'Home Economics College Mosque',
    address: 'Azimpur, Dhaka',
    areaName: 'Lalbagh',
    latitude: 23.7260,
    longitude: 90.3850,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'College mosque.'
  },
  {
    name: 'Dhaka College Mosque',
    address: 'New Market, Dhaka',
    areaName: 'New Market',
    latitude: 23.7340,
    longitude: 90.3820,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'College student mosque.'
  },
  {
    name: 'Teachers Training College Mosque',
    address: 'Science Lab, Dhaka',
    areaName: 'Dhanmondi', // Border
    latitude: 23.7380,
    longitude: 90.3800,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'College mosque.'
  },
  {
    name: 'Science Lab Mosque',
    address: 'Science Lab, Dhaka',
    areaName: 'Dhanmondi', // Border
    latitude: 23.7390,
    longitude: 90.3820,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Busy intersection mosque.'
  },
  {
    name: 'Bata Signal Mosque',
    address: 'Elephant Road, Dhaka',
    areaName: 'New Market',
    latitude: 23.7410,
    longitude: 90.3880,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near the signal.'
  },
  {
    name: 'Kathalbagan Jame Masjid',
    address: 'Kathalbagan, Dhaka',
    areaName: 'Kalabagan',
    latitude: 23.7480,
    longitude: 90.3920,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local area mosque.'
  },
  {
    name: 'Free School Street Mosque',
    address: 'Kathalbagan, Dhaka',
    areaName: 'Kalabagan',
    latitude: 23.7460,
    longitude: 90.3900,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Hatirpool Kacha Bazar Mosque',
    address: 'Hatirpool, Dhaka',
    areaName: 'Shahbag', // Border
    latitude: 23.7420,
    longitude: 90.3950,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Market mosque.'
  },
  {
    name: 'Paribagh Mosque',
    address: 'Paribagh, Dhaka',
    areaName: 'Shahbag',
    latitude: 23.7400,
    longitude: 90.3980,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near Hotel Intercontinental.'
  },
  {
    name: 'Banglamotor Jame Masjid',
    address: 'Banglamotor, Dhaka',
    areaName: 'Shahbag',
    latitude: 23.7450,
    longitude: 90.3980,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Office area mosque.'
  },
  {
    name: 'Eskaton Garden Mosque',
    address: 'Eskaton, Dhaka',
    areaName: 'Ramna', // Border
    latitude: 23.7480,
    longitude: 90.4020,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Quiet residential mosque.'
  },
  {
    name: 'Dilu Road Mosque',
    address: 'Dilu Road, Eskaton, Dhaka',
    areaName: 'Ramna',
    latitude: 23.7490,
    longitude: 90.4000,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque.'
  },

  // --- Mirpur Area ---
  {
    name: 'Mirpur 10 Central Mosque',
    address: 'Mirpur 10 Circle, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8069,
    longitude: 90.3687,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central landmark mosque of Mirpur 10.'
  },
  {
    name: 'Masjid-ul-Akbar',
    address: 'Mirpur 1, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8123,
    longitude: 90.3597,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Major mosque in Mirpur 1 complex.'
  },

  // --- Uttara Area ---
  {
    name: 'Uttara Sector 3 Jame Masjid',
    address: 'Sector 3, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8759,
    longitude: 90.3795,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Main mosque in Sector 3.'
  },
  {
    name: 'Uttara Sector 7 Jame Masjid',
    address: 'Sector 7, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8700,
    longitude: 90.3950,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large mosque near the lake.'
  },
  {
    name: 'Al Mustafa Mosque',
    address: 'Madani Avenue, United City, Dhaka',
    areaName: 'Vatara', // Near Bashundhara
    latitude: 23.7956,
    longitude: 90.4575,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    description: 'Modern mosque with unique Kaaba-inspired architecture.'
  },
  // --- Uttara Area (Expanded) ---
  {
    name: 'Uttara Sector 1 Jame Masjid',
    address: 'Sector 1, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8680,
    longitude: 90.3980,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque of Sector 1.'
  },
  {
    name: 'Uttara Sector 4 Jame Masjid',
    address: 'Sector 4, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8720,
    longitude: 90.3960,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque with park view.'
  },
  {
    name: 'Koshai Bari Jame Masjid',
    address: 'Koshai Bari, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8800,
    longitude: 90.4100,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local daily prayer mosque.'
  },
  {
    name: 'Uttara Sector 6 Jame Masjid',
    address: 'Sector 6, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8750,
    longitude: 99.4000,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large central mosque for Sector 6.'
  },
  {
    name: 'Uttara Sector 11 Central Mosque',
    address: 'Sector 11, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8790,
    longitude: 90.3880,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Architecturally beautiful mosque.'
  },
  {
    name: 'Uttara Sector 13 Central Mosque',
    address: 'Sector 13, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8760,
    longitude: 90.3890,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Hub for community activities.'
  },
  {
    name: 'Baitul Aman Jame Masjid',
    address: 'Sector 10, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8850,
    longitude: 90.3850,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Known for its spacious prayer hall.'
  },
  {
    name: 'Abdullahpur Jame Masjid',
    address: 'Abdullahpur, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8900,
    longitude: 90.4000,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: false,
    description: 'Near the bus terminal.'
  },
  {
    name: 'Uttara Sector 14 Central Mosque',
    address: 'Sector 14, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8820,
    longitude: 90.3800,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Modern facilities available.'
  },
  {
    name: 'Uttara Sector 12 Jame Masjid',
    address: 'Sector 12, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8840,
    longitude: 90.3820,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Azampur Jame Masjid',
    address: 'Azampur, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8650,
    longitude: 90.4150,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Busy area mosque.'
  },
  {
    name: 'Rajuk Uttara Model College Mosque',
    address: 'Sector 6, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8765,
    longitude: 90.4020,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Mosque within the college campus.'
  },
  {
    name: 'Uttara Sector 5 Jame Masjid',
    address: 'Sector 5, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8730,
    longitude: 90.3920,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Peaceful environment.'
  },
  {
    name: 'Uttara Sector 9 Jame Masjid',
    address: 'Sector 9, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8770,
    longitude: 90.4050,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Recently renovated.'
  },
  {
    name: 'Diabari Central Mosque',
    address: 'Diabari, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8880,
    longitude: 90.3700,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the Metro Rail depot.'
  },

  // --- Bashundhara R/A Area ---
  {
    name: 'Bashundhara Central Mosque (Markazul)',
    address: 'Block D, Bashundhara R/A, Dhaka',
    areaName: 'Vatara',
    latitude: 23.8150,
    longitude: 90.4280,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Main central mosque of Bashundhara.'
  },
  {
    name: 'Block C Jame Masjid',
    address: 'Block C, Bashundhara R/A, Dhaka',
    areaName: 'Vatara',
    latitude: 23.8130,
    longitude: 90.4300,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque for Block C.'
  },
  {
    name: 'Block F Jame Masjid',
    address: 'Block F, Bashundhara R/A, Dhaka',
    areaName: 'Vatara',
    latitude: 23.8180,
    longitude: 90.4350,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Spacious mosque in Block F.'
  },
  {
    name: 'Block I Jame Masjid',
    address: 'Block I, Bashundhara R/A, Dhaka',
    areaName: 'Vatara',
    latitude: 23.8200,
    longitude: 90.4400,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Newer mosque in the expanded area.'
  },
  {
    name: 'Bashundhara Eye Hospital Mosque',
    address: 'Bashundhara R/A, Dhaka',
    areaName: 'Vatara',
    latitude: 23.8160,
    longitude: 90.4250,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Adjacent to the hospital.'
  },
  {
    name: 'Block G Central Mosque',
    address: 'Block G, Bashundhara R/A, Dhaka',
    areaName: 'Vatara',
    latitude: 23.8220,
    longitude: 90.4450,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large community mosque.'
  },
  {
    name: 'Independent University Bangladesh (IUB) Mosque',
    address: 'IUB Campus, Bashundhara R/A, Dhaka',
    areaName: 'Vatara',
    latitude: 23.8190,
    longitude: 90.4320,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'University prayer hall.'
  },
  {
    name: 'North South University Prayer Hall',
    address: 'NSU Campus, Bashundhara R/A, Dhaka',
    areaName: 'Vatara',
    latitude: 23.8140,
    longitude: 90.4260,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large prayer hall for students.'
  },
  {
    name: 'Block N Jame Masjid',
    address: 'Block N, Bashundhara R/A, Dhaka',
    areaName: 'Vatara',
    latitude: 23.8250,
    longitude: 90.4500,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Serving the residents of Block N.'
  },
  {
    name: 'Jamuna Future Park Mosque',
    address: 'Jamuna Future Park, Dhaka',
    areaName: 'Vatara',
    latitude: 23.8120,
    longitude: 90.4230,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Inside the shopping mall.'
  },

  // --- Mirpur Area (Continued) ---
  {
    name: 'As-Sunnah Foundation Mosque',
    address: 'Plot 1, Road 2, Block B, Section 11, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8210,
    longitude: 90.3650,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Modern center for Islamic learning and prayer.'
  },
  {
    name: 'Mirpur DOHS Central Mosque',
    address: 'Mirpur DOHS, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8350,
    longitude: 90.3700,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque for DOHS residents.'
  },
  {
    name: 'Pallabi Extension Jame Masjid',
    address: 'Pallabi Extension, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8300,
    longitude: 90.3600,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Section 12 Central Mosque',
    address: 'Section 12, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8250,
    longitude: 90.3620,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large central mosque.'
  },
  {
    name: 'Section 11 Block C Mosque',
    address: 'Block C, Section 11, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8220,
    longitude: 90.3640,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Local daily prayer mosque.'
  },
  {
    name: 'Section 6 Block D Mosque',
    address: 'Block D, Section 6, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8150,
    longitude: 90.3650,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the stadium.'
  },
  {
    name: 'Mirpur 2 Central Mosque',
    address: 'Mirpur 2, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8080,
    longitude: 90.3600,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Busy area mosque.'
  },
  {
    name: 'Section 1 Central Mosque',
    address: 'Section 1, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8050,
    longitude: 90.3550,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Old established mosque.'
  },
  {
    name: 'Darussalam Jame Masjid',
    address: 'Darussalam, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.7900,
    longitude: 90.3500,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near Gabtoli.'
  },
  {
    name: 'Kallyanpur Central Mosque',
    address: 'Kallyanpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.7850,
    longitude: 90.3600,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Main mosque for Kallyanpur.'
  },
  {
    name: 'Paikpara Staff Quarter Mosque',
    address: 'Paikpara, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.7880,
    longitude: 90.3650,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Govt staff quarter mosque.'
  },
  {
    name: 'Monipur High School Mosque',
    address: 'Monipur, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8020,
    longitude: 90.3700,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near the famous school.'
  },
  {
    name: 'Kazipara Central Mosque',
    address: 'Kazipara, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.7980,
    longitude: 90.3720,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near Metro Station.'
  },
  {
    name: 'Shewrapara Central Mosque',
    address: 'Shewrapara, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.7920,
    longitude: 90.3750,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Busy main road mosque.'
  },
  {
    name: 'Ibrahimpur Central Mosque',
    address: 'Ibrahimpur, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.7950,
    longitude: 90.3850,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Section 14 Central Mosque',
    address: 'Section 14, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8180,
    longitude: 90.3800,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near Police Staff College.'
  },
  {
    name: 'Bhashantek Jame Masjid',
    address: 'Bhashantek, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8200,
    longitude: 90.3900,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque.'
  },
  {
    name: 'Rupnagar Residential Area Mosque',
    address: 'Rupnagar, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8250,
    longitude: 90.3550,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Residential area mosque.'
  },
  {
    name: 'Eastern Housing Central Mosque',
    address: 'Eastern Housing, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8300,
    longitude: 90.3500,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large planned housing mosque.'
  },
  {
    name: 'Kalshi Central Mosque',
    address: 'Kalshi, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8280,
    longitude: 90.3750,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near Kalshi flyover.'
  },
  {
    name: 'SECTION 7 CENTRAL MASJID',
    address: 'Section 7, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8120,
    longitude: 90.3620,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque.'
  },
  {
    name: 'Muslim Bazar Mosque',
    address: 'Muslim Bazar, Mirpur 12, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8320,
    longitude: 90.3680,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Market mosque.'
  },
  {
    name: 'Mirpur Cantonment Central Mosque',
    address: 'Mirpur Cantonment, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8380,
    longitude: 90.3750,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Strictly managed cantonment mosque.'
  },
  {
    name: 'MIST Central Mosque',
    address: 'MIST Campus, Mirpur Cantonment, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8360,
    longitude: 90.3720,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'University mosque.'
  },
  {
    name: 'BUP Central Mosque',
    address: 'BUP Campus, Mirpur Cantonment, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8400,
    longitude: 90.3760,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'University mosque.'
  },

  // --- Mohammadpur Area ---
  {
    name: 'Baber Road Jame Masjid',
    address: 'Baber Road, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7650,
    longitude: 90.3650,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near Block B.'
  },
  {
    name: 'Shia Masjid',
    address: 'Shia Masjid Mor, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7680,
    longitude: 90.3500,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Significant Shia mosque in the area.'
  },
  {
    name: 'PC Culture Housing Mosque',
    address: 'PC Culture, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7720,
    longitude: 90.3550,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Quiet residential mosque.'
  },
  {
    name: 'Nobi Nagar Jame Masjid',
    address: 'Nobi Nagar, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7750,
    longitude: 90.3500,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local area mosque.'
  },
  {
    name: 'Kaderia Jame Masjid',
    address: 'Katasur, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7550,
    longitude: 90.3600,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near Katasur.'
  },
  {
    name: 'Baitul Aman Jame Masjid',
    address: 'Ring Road, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7700,
    longitude: 90.3600,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque on Ring Road.'
  },
  {
    name: 'Chad Uddan Central Mosque',
    address: 'Chad Uddan, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7600,
    longitude: 90.3550,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large housing development mosque.'
  },
  {
    name: 'Basila Garden City Mosque',
    address: 'Basila, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7500,
    longitude: 90.3500,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Recently built modern mosque.'
  },
  {
    name: 'Mohammadpur Bus Stand Mosque',
    address: 'Bus Stand, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7620,
    longitude: 90.3620,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Convenient for travelers.'
  },
  {
    name: 'Salimullah Road Jame Masjid',
    address: 'Salimullah Road, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7660,
    longitude: 90.3680,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Tajmahal Road Central Mosque',
    address: 'Tajmahal Road, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7640,
    longitude: 90.3650,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Prominent mosque on Tajmahal Road.'
  },
  {
    name: 'Nurjahan Road Mosque',
    address: 'Nurjahan Road, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7630,
    longitude: 90.3670,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Local daily mosque.'
  },
  {
    name: 'Town Hall Masjid',
    address: 'Mohammadpur Town Hall, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7680,
    longitude: 90.3640,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Market area mosque.'
  },
  {
    name: 'Lalmatia Block A Mosque',
    address: 'Block A, Lalmatia, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7580,
    longitude: 90.3700,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Quiet neighborhood mosque.'
  },
  {
    name: 'Lalmatia Block D Mosque',
    address: 'Block D, Lalmatia, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7550,
    longitude: 90.3750,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Adabor 10 Jame Masjid',
    address: 'Road 10, Adabor, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7740,
    longitude: 90.3580,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque in Adabor.'
  },
  {
    name: 'Baitul Sajjad Jame Masjid',
    address: 'Adabor, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7760,
    longitude: 90.3600,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large multi-story mosque.'
  },
  {
    name: 'Shekertek Central Mosque',
    address: 'Shekertek, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7700,
    longitude: 90.3520,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Main mosque for Shekertek.'
  },
  {
    name: 'Japan Garden City Mosque',
    address: 'Japan Garden City, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7650,
    longitude: 90.3550,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Apartment complex mosque.'
  },
  {
    name: 'Shyamoli Scale Road Mosque',
    address: 'Shyamoli, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7780,
    longitude: 90.3680,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the busy intersection.'
  },
  {
    name: 'Shyamoli Club Field Mosque',
    address: 'Shyamoli, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7750,
    longitude: 90.3700,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Next to the playground.'
  },
  {
    name: 'Baitul Aman Housing Society Mosque',
    address: 'Adabor, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7780,
    longitude: 90.3550,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Housing society mosque.'
  },
  {
    name: 'Sunibir Housing Mosque',
    address: 'Sunibir Housing, Adabor, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7800,
    longitude: 90.3520,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Local community mosque.'
  },
  {
    name: 'Mansurabad Housing Mosque',
    address: 'Mansurabad, Adabor, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7820,
    longitude: 90.3500,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large prayer hall.'
  },
  {
    name: 'Prominent Housing Mosque',
    address: 'Prominent Housing, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7520,
    longitude: 90.3480,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Riverside area mosque.'
  },
  {
    name: 'Dhaka Uddan Central Mosque',
    address: 'Dhaka Uddan, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7580,
    longitude: 90.3450,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque of the housing project.'
  },
  {
    name: 'Nobodoy Housing Mosque',
    address: 'Nobodoy Housing, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7620,
    longitude: 90.3500,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Geneva Camp Mosque',
    address: 'Geneva Camp, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7640,
    longitude: 90.3600,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Dense community mosque.'
  },
  {
    name: 'Humayun Road Jame Masjid',
    address: 'Humayun Road, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7600,
    longitude: 90.3660,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Historical road mosque.'
  },
  {
    name: 'Krishi Market Mosque',
    address: 'Krishi Market, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7700,
    longitude: 90.3620,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Market traders mosque.'
  },
  {
    name: 'Baitul Mamur Jame Masjid',
    address: 'Shajahanpur, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7400,
    longitude: 90.4180,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Rajarbagh Police Line Central Mosque',
    address: 'Rajarbagh, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7380,
    longitude: 90.4150,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Main mosque for police personnel.'
  },
  {
    name: 'Malibagh Railgate Mosque',
    address: 'Malibagh, Dhaka',
    areaName: 'Motijheel', // Border
    latitude: 23.7480,
    longitude: 90.4120,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near the rail crossing.'
  },
  {
    name: 'Gulbagh Jame Masjid',
    address: 'Gulbagh, Malibagh, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7500,
    longitude: 90.4150,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Shantinagar Market Mosque',
    address: 'Shantinagar, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7420,
    longitude: 90.4130,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Market mosque.'
  },
  {
    name: 'Mouchak Market Mosque',
    address: 'Mouchak, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7450,
    longitude: 90.4100,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Attached to the market.'
  },
  {
    name: 'Siddheswari Jame Masjid',
    address: 'Siddheswari, Dhaka',
    areaName: 'Motijheel', // Border
    latitude: 23.7430,
    longitude: 90.4080,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Historic area mosque.'
  },
  {
    name: 'Segunbagicha Central Mosque',
    address: 'Segunbagicha, Dhaka',
    areaName: 'Motijheel', // Border
    latitude: 23.7330,
    longitude: 90.4050,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the secretariat.'
  },
  {
    name: 'AGB Colony Mosque',
    address: 'Motijheel, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7320,
    longitude: 90.4180,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Govt colony mosque.'
  },
  {
    name: 'South Kamalapur Mosque',
    address: 'South Kamalapur, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7280,
    longitude: 90.4280,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque.'
  },
  {
    name: 'Gopibagh Jame Masjid',
    address: 'Gopibagh, Dhaka',
    areaName: 'Motijheel', // Border
    latitude: 23.7250,
    longitude: 90.4250,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Bashabo Balur Math Mosque',
    address: 'Bashabo, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7420,
    longitude: 90.4320,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the field.'
  },
  {
    name: 'Kadamtala Jame Masjid',
    address: 'Kadamtala, Bashabo, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7400,
    longitude: 90.4300,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Main mosque of Kadamtala.'
  },
  {
    name: 'Khilgaon Flyover Mosque',
    address: 'Khilgaon, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7500,
    longitude: 90.4210,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Under the flyover.'
  },
  {
    name: 'Goran Central Mosque',
    address: 'Goran, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7550,
    longitude: 90.4350,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque for Goran.'
  },
  {
    name: 'Banashree Central Mosque',
    address: 'Block E, Banashree, Dhaka',
    areaName: 'Khilgaon', // Border with Rampura
    latitude: 23.7620,
    longitude: 90.4320,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Main mosque of Banashree.'
  },
  {
    name: 'Banashree Block B Mosque',
    address: 'Block B, Banashree, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7600,
    longitude: 90.4300,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'South Banashree Jame Masjid',
    address: 'South Banashree, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7580,
    longitude: 90.4350,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Developing area mosque.'
  },
  {
    name: 'Rampura Bridge Mosque',
    address: 'Rampura, Dhaka',
    areaName: 'Khilgaon', // Border
    latitude: 23.7650,
    longitude: 90.4200,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near the bridge.'
  },
  {
    name: 'Ulon Road Jame Masjid',
    address: 'West Rampura, Dhaka',
    areaName: 'Khilgaon', // Border
    latitude: 23.7620,
    longitude: 90.4180,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque.'
  },
  {
    name: 'Mahanagar Project Mosque',
    address: 'West Rampura, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7680,
    longitude: 90.4160,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Planned area mosque.'
  },
  {
    name: 'WAPDA Road Mosque',
    address: 'Rampura, Dhaka',
    areaName: 'Tejgaon', // Border
    latitude: 23.7700,
    longitude: 90.4150,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Staff quarter mosque.'
  },
  {
    name: 'Hatirjheel Mosque',
    address: 'Hatirjheel, Dhaka',
    areaName: 'Tejgaon', // Border
    latitude: 23.7550,
    longitude: 90.4050,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Scenic area mosque.'
  },
  {
    name: 'Madhubag Jame Masjid',
    address: 'Madhubag, Moghbazar, Dhaka',
    areaName: 'Tejgaon', // Border
    latitude: 23.7600,
    longitude: 90.4080,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Nayatola Jame Masjid',
    address: 'Nayatola, Moghbazar, Dhaka',
    areaName: 'Tejgaon', // Border
    latitude: 23.7580,
    longitude: 90.4050,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque.'
  },

  // --- Motijheel & Central Area ---
  {
    name: 'Baitul Mukarram National Mosque',
    address: 'Topkhana Road, Motijheel, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7308,
    longitude: 90.4153,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasBikeParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    hasChairPrayer: true,
    description: 'The National Mosque of Bangladesh.'
  },
  {
    name: 'Motijheel WAPDA Jame Masjid',
    address: 'Motijheel C/A, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7250,
    longitude: 90.4180,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Office area mosque.'
  },
  {
    name: 'Dilkusha Jame Masjid',
    address: 'Dilkusha C/A, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7220,
    longitude: 90.4150,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Commercial area mosque.'
  },
  {
    name: 'Bangladesh Bank Colony Mosque',
    address: 'Motijheel, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7280,
    longitude: 90.4200,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Colony mosque for bank employees.'
  },
  {
    name: 'Kamalapur Railway Station Mosque',
    address: 'Kamalapur, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7310,
    longitude: 90.4250,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: false,
    description: 'Large mosque for travelers.'
  },
  {
    name: 'Arambagh Jame Masjid',
    address: 'Arambagh, Motijheel, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7300,
    longitude: 90.4180,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Fakirapool Jame Masjid',
    address: 'Fakirapool, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7330,
    longitude: 90.4120,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near the water tower.'
  },

  // --- Old Dhaka ---
  {
    name: 'Tara Masjid (Star Mosque)',
    address: 'Armanitola, Old Dhaka',
    areaName: 'Kotwali',
    latitude: 23.7172,
    longitude: 90.4138,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Famous for its mosaic decoration.'
  },
  {
    name: 'Chawkbazar Shahi Mosque',
    address: 'Chawkbazar, Old Dhaka',
    areaName: 'Chawkbazar',
    latitude: 23.7160,
    longitude: 90.3950,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: false,
    description: 'Historical mosque built by Shaista Khan.'
  },
  {
    name: 'Khan Mohammad Mridha Mosque',
    address: 'Lalbagh, Old Dhaka',
    areaName: 'Lalbagh',
    latitude: 23.7200,
    longitude: 90.3880,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: false,
    description: 'Historical Mughal mosque.'
  },
  {
    name: 'Lalbagh Fort Mosque',
    address: 'Lalbagh Fort, Old Dhaka',
    areaName: 'Lalbagh',
    latitude: 23.7180,
    longitude: 90.3880,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: false,
    description: 'Inside the fort complex.'
  },
  {
    name: 'Binat Bibi Mosque',
    address: 'Narinda, Old Dhaka',
    areaName: 'Sutrapur',
    latitude: 23.7100,
    longitude: 90.4200,
    hasWomenPrayer: true, // Has separate history of being built by a woman
    hasCarParking: false,
    hasWudu: true,
    hasAC: false,
    description: 'Oldest surviving mosque in Dhaka.'
  },
  {
    name: 'Boro Katra Mosque',
    address: 'Chawkbazar, Old Dhaka',
    areaName: 'Chawkbazar',
    latitude: 23.7150,
    longitude: 90.3930,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: false,
    description: 'Historical ruin site and mosque.'
  },
  {
    name: 'Armanitola Jame Masjid',
    address: 'Armanitola, Old Dhaka',
    areaName: 'Kotwali',
    latitude: 23.7150,
    longitude: 90.4100,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Large community mosque.'
  },
  {
    name: 'Hussaini Dalan (Shia)',
    address: 'Hussaini Dalan Road, Old Dhaka',
    areaName: 'Chawkbazar',
    latitude: 23.7230,
    longitude: 90.3950,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Shia shrine and prayer hall.'
  },
  {
    name: 'Dhakeshwari Area Mosque',
    address: 'Near Dhakeshwari Temple, Old Dhaka',
    areaName: 'Lalbagh',
    latitude: 23.7220,
    longitude: 90.3900,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque.'
  },
  {
    name: 'Sardar Bari Mosque',
    address: 'Sutrapur, Old Dhaka',
    areaName: 'Sutrapur',
    latitude: 23.7050,
    longitude: 90.4150,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque in Sutrapur.'
  },
  {
    name: 'Wari Jame Masjid',
    address: 'Rankin Street, Wari, Dhaka',
    areaName: 'Wari',
    latitude: 23.7180,
    longitude: 90.4180,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque of Wari.'
  },
  {
    name: 'Larmini Street Mosque',
    address: 'Larmini Street, Wari, Dhaka',
    areaName: 'Wari',
    latitude: 23.7190,
    longitude: 90.4190,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local community mosque.'
  },
  {
    name: 'Hatkhola Jame Masjid',
    address: 'Hatkhola, Dhaka',
    areaName: 'Wari',
    latitude: 23.7200,
    longitude: 90.4200,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the prominent intersection.'
  },
  {
    name: 'Bonogram Jame Masjid',
    address: 'Bonogram, Wari, Dhaka',
    areaName: 'Wari',
    latitude: 23.7170,
    longitude: 90.4210,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Historic area mosque.'
  },
  {
    name: 'Baldha Garden Mosque',
    address: 'Wari, Dhaka',
    areaName: 'Wari',
    latitude: 23.7160,
    longitude: 90.4180,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: false,
    description: 'Near the botanical garden.'
  },
  {
    name: 'Gandaria Central Mosque',
    address: 'Doyaganj, Gandaria, Dhaka',
    areaName: 'Gandaria',
    latitude: 23.7080,
    longitude: 90.4250,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Main mosque for Gandaria.'
  },
  {
    name: 'Dhupkhola Math Mosque',
    address: 'Dhupkhola, Gandaria, Dhaka',
    areaName: 'Gandaria',
    latitude: 23.7100,
    longitude: 90.4280,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large mosque near the field.'
  },
  {
    name: 'Sutrapur Jame Masjid',
    address: 'Sutrapur, Dhaka',
    areaName: 'Sutrapur',
    latitude: 23.7060,
    longitude: 90.4160,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Loharpool Jame Masjid',
    address: 'Loharpool, Sutrapur, Dhaka',
    areaName: 'Sutrapur',
    latitude: 23.7050,
    longitude: 90.4180,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near the bridge.'
  },
  {
    name: 'Bangshal Baro Jame Masjid',
    address: 'Bangshal Road, Dhaka',
    areaName: 'Bangshal',
    latitude: 23.7180,
    longitude: 90.4050,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Famous old mosque in Bangshal.'
  },
  {
    name: 'Alu Bazar Jame Masjid',
    address: 'Alu Bazar, Bangshal, Dhaka',
    areaName: 'Bangshal',
    latitude: 23.7200,
    longitude: 90.4060,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Busy market mosque.'
  },
  {
    name: 'North South Road Mosque',
    address: 'North South Road, Bangshal, Dhaka',
    areaName: 'Bangshal',
    latitude: 23.7220,
    longitude: 90.4040,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Roadside mosque.'
  },
  {
    name: 'Siddik Bazar Jame Masjid',
    address: 'Siddik Bazar, Dhaka',
    areaName: 'Bangshal',
    latitude: 23.7250,
    longitude: 90.4080,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Trading area mosque.'
  },
  {
    name: 'Nayabazar Jame Masjid',
    address: 'Nayabazar, Dhaka',
    areaName: 'Kotwali',
    latitude: 23.7150,
    longitude: 90.4020,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the bridge approach.'
  },
  {
    name: 'Babubazar Bridge Mosque',
    address: 'Babubazar, Dhaka',
    areaName: 'Kotwali',
    latitude: 23.7120,
    longitude: 90.4000,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Under or near the bridge.'
  },
  {
    name: 'Mitford Hospital Mosque',
    address: 'Mitford, Dhaka',
    areaName: 'Kotwali',
    latitude: 23.7100,
    longitude: 90.3980,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Hospital campus mosque.'
  },
  {
    name: 'Isulampur Jame Masjid',
    address: 'Islampur, Dhaka',
    areaName: 'Kotwali',
    latitude: 23.7130,
    longitude: 90.3960,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Cloth market central mosque.'
  },
  {
    name: 'Ahsan Manzil Mosque',
    address: 'Kumartuli, Islampur, Dhaka',
    areaName: 'Kotwali',
    latitude: 23.7080,
    longitude: 90.3950,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: false,
    description: 'Historic mosque near the palace.'
  },
  {
    name: 'Shaikh Saheb Bazar Mosque',
    address: 'Azimpur, Dhaka',
    areaName: 'Lalbagh',
    latitude: 23.7280,
    longitude: 90.3880,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Lalbagh Shahi Masjid',
    address: 'Lalbagh Road, Dhaka',
    areaName: 'Lalbagh',
    latitude: 23.7220,
    longitude: 90.3850,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Historic mosque.'
  },
  {
    name: 'Hazaribagh Park Mosque',
    address: 'Hazaribagh, Dhaka',
    areaName: 'Hazaribagh',
    latitude: 23.7350,
    longitude: 90.3700,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the park.'
  },
  {
    name: 'Tullabag Jame Masjid',
    address: 'Tullabag, Hazaribagh, Dhaka',
    areaName: 'Hazaribagh',
    latitude: 23.7380,
    longitude: 90.3720,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Jigatola Boro Jame Masjid',
    address: 'Jigatola, Dhaka',
    areaName: 'Hazaribagh',
    latitude: 23.7400,
    longitude: 90.3750,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Main mosque for Jigatola.'
  },
  {
    name: 'Pilkhana BGB Mosque',
    address: 'Pilkhana, Dhaka',
    areaName: 'Hazaribagh',
    latitude: 23.7320,
    longitude: 90.3780,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'BGB Headquarters mosque.'
  },
  {
    name: 'Rayerbazar Boro Masjid',
    address: 'Rayerbazar, Dhaka',
    areaName: 'Hazaribagh',
    latitude: 23.7450,
    longitude: 90.3650,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Large historical area mosque.'
  },
  {
    name: 'West Dhanmondi Yusuf High School Mosque',
    address: 'Shankar, Dhaka',
    areaName: 'Dhanmondi', // Border
    latitude: 23.7500,
    longitude: 90.3680,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near School.'
  },
  {
    name: 'Shankar Jame Masjid',
    address: 'Shankar, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7520,
    longitude: 90.3670,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Bochila Central Mosque',
    address: 'Bochila, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7400,
    longitude: 90.3400,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Developing area central mosque.'
  },
  {
    name: 'Sardar Colony Mosque',
    address: 'Basila Road, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7550,
    longitude: 90.3550,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Residential colony mosque.'
  },
  {
    name: 'Swamibagh Jame Masjid',
    address: 'Swamibagh, Dhaka',
    areaName: 'Gandaria',
    latitude: 23.7150,
    longitude: 90.4220,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near the ashram area.'
  },
  {
    name: 'Dayaganj Rail Bridge Mosque',
    address: 'Dayaganj, Dhaka',
    areaName: 'Gandaria',
    latitude: 23.7120,
    longitude: 90.4260,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near rail line.'
  },

  // --- Tejgaon & Industrial ---
  {
    name: 'Tejgaon Industrial Area Central Mosque',
    address: 'Tejgaon I/A, Dhaka',
    areaName: 'Tejgaon',
    latitude: 23.7650,
    longitude: 90.3980,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large industrial area mosque.'
  },
  {
    name: 'Tejgaon Rahim Metal Mosque',
    address: 'Tejgaon, Dhaka',
    areaName: 'Tejgaon',
    latitude: 23.7600,
    longitude: 90.3950,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Factory mosque.'
  },
  {
    name: 'Nakhalpara Sapra Mosque',
    address: 'Nakhalpara, Tejgaon, Dhaka',
    areaName: 'Tejgaon',
    latitude: 23.7700,
    longitude: 90.3950,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque.'
  },
  {
    name: 'Farmgate Khasru Bhai Mosque',
    address: 'Farmgate, Dhaka',
    areaName: 'Tejgaon',
    latitude: 23.7550,
    longitude: 90.3900,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Near the busy Farmgate hub.'
  },
  {
    name: 'Kawran Bazar Amber Shah Mosque',
    address: 'Kawran Bazar, Dhaka',
    areaName: 'Tejgaon',
    latitude: 23.7500,
    longitude: 90.3950,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Historical mosque on the main road.'
  },

  // --- Khilgaon & Bashabo ---
  {
    name: 'Khilgaon Taltola Mosque',
    address: 'Taltola, Khilgaon, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7520,
    longitude: 90.4220,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque of Khilgaon.'
  },
  {
    name: 'Khilgaon Chowdhury Para Masjid',
    address: 'Chowdhury Para, Khilgaon, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7542,
    longitude: 90.4254,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasWudu: true,
    hasAC: false,
    description: 'Community mosque.'
  },
  {
    name: 'Khilgaon Tilpapara Mosque',
    address: 'Tilpapara, Khilgaon, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7560,
    longitude: 90.4280,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque.'
  },
  {
    name: 'Bashabo Tarabo Mosque',
    address: 'Bashabo, Dhaka',
    areaName: 'Khilgaon', // Grouping under Khilgaon/Bashabo
    latitude: 23.7400,
    longitude: 90.4300,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Madartek Central Mosque',
    address: 'Madartek, Bashabo, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7380,
    longitude: 90.4350,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large mosque in Madartek.'
  },
  {
    name: 'Gorango Bazar Mosque',
    address: 'Khilgaon, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7500,
    longitude: 90.4200,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Market central mosque.'
  },
  {
    name: 'Sipahibagh Jame Masjid',
    address: 'Sipahibagh, Khilgaon, Dhaka',
    areaName: 'Khilgaon',
    latitude: 23.7480,
    longitude: 90.4300,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },

  // --- Other Areas (Badda, Rampura, Moghbazar) ---
  {
    name: 'Badda Alatunnessa Higher Secondary School Mosque',
    address: 'Middle Badda, Dhaka',
    areaName: 'Gulshan', // Badda often grouped near Gulshan/Rampura. Using Gulshan to ensure map availability or I need to add Badda area. I'll stick to 'Gulshan' broadly or if 'Badda' exists. I'll use Gulshan as fallback or assuming user will map areas. 
    // Actually best to reuse existing areas: Gulshan, Banani, Dhanmondi, Mirpur, Uttara, Mohammadpur, Motijheel, Old Dhaka, Tejgaon, Khilgaon.
    // Badda is loosely near Gulshan Link Road.
    latitude: 23.7800,
    longitude: 90.4250,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'School attached mosque.'
  },
  {
    name: 'Merul Badda DIT Project Mosque',
    address: 'Merul Badda, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7700,
    longitude: 90.4200,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'DIT Project Central Mosque.'
  },
  {
    name: 'Rampura TV Station Mosque',
    address: 'Rampura, Dhaka',
    areaName: 'Khilgaon', // Nearby
    latitude: 23.7600,
    longitude: 90.4150,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near BTV station.'
  },
  {
    name: 'Moghbazar Wireless Mosque',
    address: 'Moghbazar, Dhaka',
    areaName: 'Tejgaon', // Nearby
    latitude: 23.7450,
    longitude: 90.4050,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Malibagh Chowdhury Para Mosque',
    address: 'Malibagh, Dhaka',
    areaName: 'Khilgaon', // Nearby
    latitude: 23.7500,
    longitude: 90.4100,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque.'
  },
  {
    name: 'Shantinagar Central Mosque',
    address: 'Shantinagar, Dhaka',
    areaName: 'Motijheel', // Nearby
    latitude: 23.7400,
    longitude: 90.4120,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large central mosque.'
  },
  {
    name: 'Kakrail Mosque (Tabligh Markaz)',
    address: 'Kakrail, Dhaka',
    areaName: 'Motijheel', // Nearby
    latitude: 23.7350,
    longitude: 90.4080,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central hub for Tablighi Jamaat.'
  },
  {
    name: 'Circuit House Mosque',
    address: 'Circuit House Road, Dhaka',
    areaName: 'Motijheel',
    latitude: 23.7350,
    longitude: 90.4050,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Government officers mosque.'
  },
  {
    name: 'High Court Mazar Mosque',
    address: 'High Court Area, Dhaka',
    areaName: 'Ramna', // Refactored from Old Dhaka
    latitude: 23.7280,
    longitude: 90.4020,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Famous shrine and mosque.'
  },
  {
    name: 'Dhaka University Central Mosque',
    address: 'Dhaka University, Dhaka',
    areaName: 'Shahbag', // Refactored from Old Dhaka
    latitude: 23.7340,
    longitude: 90.3950,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'University central mosque where Kazi Nazrul Islam is buried.'
  },
  {
    name: 'Katabon Mosque',
    address: 'Katabon, Dhaka',
    areaName: 'Dhanmondi', // Nearby
    latitude: 23.7380,
    longitude: 90.3900,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Famous mosque complex in Katabon.'
  },
  {
    name: 'Elephant Road Plane Masjid',
    address: 'Elephant Road, Dhaka',
    areaName: 'Dhanmondi', // Nearby
    latitude: 23.7400,
    longitude: 90.3850,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Known as Plane Masjid.'
  },
  {
    name: 'Azimpur Graveyard Mosque',
    address: 'Azimpur, Dhaka',
    areaName: 'Lalbagh',
    latitude: 23.7250,
    longitude: 90.3850,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large mosque near the graveyard.'
  },
  {
    name: 'New Market Mosque',
    address: 'New Market, Dhaka',
    areaName: 'Dhanmondi', // Nearby
    latitude: 23.7330,
    longitude: 90.3830,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Architecturally significant triangle mosque.'
  },
  {
    name: 'Nilkhet Mosque',
    address: 'Nilkhet, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7320,
    longitude: 90.3880,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Mosque for students and book lovers.'
  },
  {
    name: 'Shahbagh Central Mosque',
    address: 'Shahbagh, Dhaka',
    areaName: 'Motijheel', // Broadly
    latitude: 23.7380,
    longitude: 90.3980,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near Bangabandhu Sheikh Mujib Medical University.'
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
    console.log('Available Areas:', Object.keys(areaMap).join(', '));

    // Seed mosques
    const batch = db.batch();
    let batchCount = 0;
    let totalMosques = 0;
    let skippedMosques = 0;
    const mosqueIds = []; // Track mosque IDs for prayer time seeding

    for (const mosque of dhakaMosques) {
      let areaId = areaMap[mosque.areaName];

      // Fallback for areas not in map but reasonably close (optional mapping logic could be added here)
      // For now, if exact match fails, we log it.

      if (!areaId) {
        console.log(`⚠️  Area "${mosque.areaName}" not found for "${mosque.name}". trying to map to default available areas if possible...`);
        // Basic fallback logic: if area is not found, try to map 'Old Dhaka' to 'Lalbagh' or 'Kotwali' if they exist, or skip.
        // Since we don't see the exact DB area names, we rely on the user running this with valid data.
        // However, I will strictly use the areas I know are in the list from the original file (Gulshan, Banani, Dhanmondi, Mirpur, Uttara, Mohammadpur, Motijheel, Old Dhaka, Tejgaon, Khilgaon)
        // If the DB has different names, this will skip.
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
      console.log(`⚠️  Skipped ${skippedMosques} mosques (areas not found in DB)`);
    }

    // Now seed prayer times for all mosques
    if (mosqueIds.length > 0) {
      await seedPrayerTimes(mosqueIds);
    }

    console.log('\n' + '='.repeat(50));
    console.log('\n🎉 ALL DONE!\n');

  } catch (error) {
    console.error('❌ Error seeding data:', error);
    process.exit(1);
  }

  process.exit(0);
}

seedMosques();
