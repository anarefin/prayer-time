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
const dhakaМosques = [
  // --- Gulshan Area ---
  {
    name: 'Gulshan Central Mosque (Azad Mosque)',
    address: 'Road 27, Gulshan 1, Dhaka',
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
    description: 'Large central mosque with modern facilities.'
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
    hasCycleParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: true,
    hasChairPrayer: true,
    description: 'Modern architectural landmark in Gulshan.'
  },
  {
    name: 'Gulshan 1 DC Market Mosque',
    address: 'Gulshan 1 DC Market, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7780,
    longitude: 90.4160,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasBikeParking: true,
    hasWudu: true,
    hasAC: true,
    isWheelchairAccessible: false,
    description: 'Market mosque convenient for shoppers.'
  },
  {
    name: 'Gulshan 2 Jame Masjid',
    address: 'Gulshan 2 Circle, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7940,
    longitude: 90.4140,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasBikeParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque near the Gulshan 2 circle.'
  },
  {
    name: 'Niketan Central Mosque',
    address: 'Block E, Niketan, Gulshan 1, Dhaka',
    areaName: 'Gulshan',
    latitude: 23.7750,
    longitude: 90.4100,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque for Niketan residents.'
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
    address: 'Banani Super Market, Banani, Dhaka',
    areaName: 'Banani',
    latitude: 23.7910,
    longitude: 90.4050,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Mosque located within the Banani market area.'
  },
  {
    name: 'Banani Chairman Bari Masjid',
    address: 'Chairman Bari, Banani, Dhaka',
    areaName: 'Banani',
    latitude: 23.7850,
    longitude: 90.4020,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque in Chairman Bari area.'
  },
  {
    name: 'Mohakhali Wireless Gate Jame Masjid',
    address: 'Wireless Gate, Banani, Dhaka',
    areaName: 'Banani',
    latitude: 23.7820,
    longitude: 90.4005,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Located near the busy Wireless Gate junction.'
  },
  {
    name: 'Banani DOHS Jame Masjid',
    address: 'Banani DOHS, Dhaka',
    areaName: 'Banani',
    latitude: 23.7980,
    longitude: 90.3950,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Quiet and spacious mosque inside DOHS.'
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
    name: 'Dhanmondi Eidgah Masjid',
    address: 'Road 6A, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7420,
    longitude: 90.3750,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Located next to the historical Dhanmondi Eidgah.'
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
    name: 'Baitul Aman Masjid',
    address: 'Road 7, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7450,
    longitude: 90.3780,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque on Road 7.'
  },
  {
    name: 'Sat Masjid (Seven Domed Mosque)',
    address: 'Sat Masjid Road, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7290,
    longitude: 90.3854,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: false,
    description: 'Historic Mughal era mosque.'
  },
  {
    name: 'Dhanmondi Road 15 Mosque',
    address: 'Road 15, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7527,
    longitude: 90.3758,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Popular mosque on Road 15 (Kakoli).'
  },
  {
    name: 'Kalabagan Staff Quarter Mosque',
    address: 'Kalabagan, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7480,
    longitude: 90.3850,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Staff quarter mosque in Kalabagan.'
  },
  {
    name: 'Dhanmondi Central Mosque',
    address: 'Road 8, Dhanmondi, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7460,
    longitude: 90.3770,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central community mosque.'
  },
  {
    name: 'Science Lab Jame Masjid',
    address: 'Science Lab, Dhaka',
    areaName: 'Dhanmondi',
    latitude: 23.7390,
    longitude: 90.3830,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Located in the Science Laboratory compound.'
  },
  {
    name: 'Lalmatia Block D Mosque',
    address: 'Block D, Lalmatia, Dhaka',
    areaName: 'Dhanmondi', // Mapping Lalmatia to Dhanmondi/Mohammadpur area broadly if Lalmatia area doesn't exist separately
    latitude: 23.7600,
    longitude: 90.3720,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Main mosque for Lalmatia Block D.'
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
    description: 'Major mosque in Mirpur 1.'
  },
  {
    name: 'Rainkhola Jame Masjid',
    address: 'Zoo Road, Mirpur 2, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8150,
    longitude: 90.3550,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Located near the National Zoo.'
  },
  {
    name: 'Mirpur DOHS Central Masjid',
    address: 'Mirpur DOHS, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8347,
    longitude: 90.3658,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Beautiful mosque serving DOHS residents.'
  },
  {
    name: 'Baitul Jannat Jame Masjid',
    address: 'Mirpur 6, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8200,
    longitude: 90.3650,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque in Section 6.'
  },
  {
    name: 'Pallabi Central Mosque / Masjidul Jumuah',
    address: 'Mirpur 11.5, Pallabi, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8250,
    longitude: 90.3680,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque of Pallabi area.'
  },
  {
    name: 'Mirpur 12 Central Mosque',
    address: 'Mirpur 12 Bus Stand, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8300,
    longitude: 90.3700,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Busy mosque near the bus stand.'
  },
  {
    name: 'Kazipara Central Mosque',
    address: 'Kazipara, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.7980,
    longitude: 90.3730,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Main mosque for Kazipara residents.'
  },
  {
    name: 'Shewrapara Jame Masjid',
    address: 'Shewrapara, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.7900,
    longitude: 90.3750,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Located on the main Rokeya Sarani.'
  },
  {
    name: 'Senpara Parbata Jame Masjid',
    address: 'Senpara Parbata, Mirpur 10, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8050,
    longitude: 90.3720,
    hasWomenPrayer: true,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque in Senpara.'
  },
  {
    name: 'Baitul Aman Housing Society Mosque',
    address: 'Adabor, Shyamoli (near Mirpur), Dhaka',
    areaName: 'Mirpur', // Grouping under Mirpur/Mohammadpur depending on available areas
    latitude: 23.7750,
    longitude: 90.3600,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large housing society mosque.'
  },
  {
    name: 'Paikpara Government Staff Quarter Mosque',
    address: 'Paikpara, Mirpur 1, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8000,
    longitude: 90.3550,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Staff quarter mosque.'
  },
  {
    name: 'Shah Ali Mazar Mosque',
    address: 'Mirpur 1, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8130,
    longitude: 90.3580,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Famous shrine and mosque complex.'
  },
  {
    name: 'Mirpur 13 Central Masjid',
    address: 'Mirpur 13, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8200,
    longitude: 90.3750,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Serving Section 13 residents.'
  },
  {
    name: 'Rupnagar Residential Area Mosque',
    address: 'Rupnagar, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8220,
    longitude: 90.3620,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Residential area mosque.'
  },
  {
    name: 'Baitul Mukarram (Mirpur 1)',
    address: 'Mazar Road, Mirpur 1, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8110,
    longitude: 90.3570,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Not the national mosque, but a local one.'
  },
  {
    name: 'Monipur Central Mosque',
    address: 'Monipur, Mirpur 2, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8080,
    longitude: 90.3650,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'High school attached mosque.'
  },
  {
    name: 'Ibrahimpur Central Masjid',
    address: 'Ibrahimpur, Mirpur 14, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8000,
    longitude: 90.3850,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Dense residential area mosque.'
  },
  {
    name: 'Kafrul Jame Masjid',
    address: 'Kafrul, Mirpur 13, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8020,
    longitude: 90.3820,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Old mosque in Kafrul.'
  },
  {
    name: 'Bhashantek Jame Masjid',
    address: 'Bhashantek, Mirpur, Dhaka',
    areaName: 'Mirpur',
    latitude: 23.8180,
    longitude: 90.3900,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
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
    name: 'Uttara Sector 4 Central Mosque',
    address: 'Road 7, Sector 4, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8650,
    longitude: 90.3980,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Central mosque of Sector 4.'
  },
  {
    name: 'Uttara Sector 6 Jame Masjid',
    address: 'Sector 6, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8720,
    longitude: 90.4000,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
  {
    name: 'Uttara Sector 11 Central Mosque',
    address: 'Sector 11, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8800,
    longitude: 90.3880,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Large mosque in Sector 11.'
  },
  {
    name: 'Uttara Sector 13 Jame Masjid',
    address: 'Sector 13, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8720,
    longitude: 90.3850,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Sector 13 central mosque.'
  },
  {
    name: 'Uttara Sector 14 Central Mosque',
    address: 'Sector 14, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8750,
    longitude: 90.3820,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Newly renovated mosque.'
  },
  {
    name: 'Baitul Momur Jame Masjid',
    address: 'Sector 10, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8850,
    longitude: 90.3900,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Local mosque in Sector 10.'
  },
  {
    name: 'Azampur Jame Masjid',
    address: 'Azampur, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8689,
    longitude: 90.3895,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near Azampur bus stand.'
  },
  {
    name: 'Abdullahpur Jame Masjid',
    address: 'Abdullahpur, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8880,
    longitude: 90.3950,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Near the river crossing.'
  },
  {
    name: 'Sector 1 Central Mosque',
    address: 'Sector 1, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8600,
    longitude: 90.3950,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'One of the first mosques in Uttara.'
  },
  {
    name: 'Rajuk Uttara Apartment Project Mosque',
    address: 'Sector 18, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8900,
    longitude: 90.3700,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Modern mosque for apartment residents.'
  },
  {
    name: 'Koshai Bari Jumma Mosque',
    address: 'Koshai Bari, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8550,
    longitude: 90.4100,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: false,
    description: 'Traditional mosque.'
  },
  {
    name: 'Baunia Jame Masjid',
    address: 'Baunia, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8800,
    longitude: 90.3600,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Rural-style mosque in Baunia.'
  },
  {
    name: 'Diabari Central Mosque',
    address: 'Diabari, Uttara, Dhaka',
    areaName: 'Uttara',
    latitude: 23.8820,
    longitude: 90.3650,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Scenic mosque in Diabari.'
  },

  // --- Mohammadpur Area ---
  {
    name: 'Mohammadpur Town Hall Mosque',
    address: 'Town Hall, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7660,
    longitude: 90.3580,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Busy central mosque.'
  },
  {
    name: 'Saat Masjid (Seven Domed)',
    address: 'Mohammadpur Bus Stand, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7600,
    longitude: 90.3550,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: false,
    description: 'Historic landmark.'
  },
  {
    name: 'Baitul Aman Housing Mosque',
    address: 'Road 1, Baitul Aman Housing, Mohammadpur',
    areaName: 'Mohammadpur',
    latitude: 23.7700,
    longitude: 90.3580,
    hasWomenPrayer: true,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Housing society mosque.'
  },
  {
    name: 'Krishi Market Mosque',
    address: 'Krishi Market, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7680,
    longitude: 90.3620,
    hasWomenPrayer: false,
    hasCarParking: true,
    hasWudu: true,
    hasAC: true,
    description: 'Market workers mosque.'
  },
  {
    name: 'Japan Garden City Mosque',
    address: 'Ring Road, Mohammadpur, Dhaka',
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
    name: 'Salek Garden Jame Masjid',
    address: 'Salek Garden, Mohammadpur',
    areaName: 'Mohammadpur',
    latitude: 23.7620,
    longitude: 90.3520,
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
    longitude: 90.3600,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Located on the famous Tajmahal Road.'
  },
  {
    name: 'Nurjahan Road Mosque',
    address: 'Nurjahan Road, Mohammadpur, Dhaka',
    areaName: 'Mohammadpur',
    latitude: 23.7630,
    longitude: 90.3610,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque.'
  },
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
    areaName: 'Old Dhaka',
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
    areaName: 'Old Dhaka',
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
    areaName: 'Old Dhaka',
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
    areaName: 'Old Dhaka',
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
    areaName: 'Old Dhaka',
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
    areaName: 'Old Dhaka',
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
    areaName: 'Old Dhaka',
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
    areaName: 'Old Dhaka',
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
    areaName: 'Old Dhaka',
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
    areaName: 'Old Dhaka',
    latitude: 23.7050,
    longitude: 90.4150,
    hasWomenPrayer: false,
    hasCarParking: false,
    hasWudu: true,
    hasAC: true,
    description: 'Community mosque in Sutrapur.'
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
    areaName: 'Old Dhaka', // Border
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
    areaName: 'Old Dhaka', // Nearby/Shahbagh
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
    areaName: 'Old Dhaka',
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

    for (const mosque of dhakaМosques) {
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
