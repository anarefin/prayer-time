const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkUserData() {
  try {
    console.log('\n🔍 Checking Firestore User Data\n');
    console.log('=' .repeat(50));
    
    // Check arefin user
    const arefinUID = 'XuluFeg2EygURMEdA7XHQSH1fC93';
    const arefinDoc = await db.collection('users').doc(arefinUID).get();
    
    console.log(`\n👤 User: arefin@arefin.com`);
    console.log(`UID: ${arefinUID}`);
    
    if (arefinDoc.exists) {
      const data = arefinDoc.data();
      console.log('\n📄 Raw Firestore Data:');
      console.log(JSON.stringify(data, null, 2));
      
      console.log('\n🔍 Field Analysis:');
      console.log(`  email: ${typeof data.email} = "${data.email}"`);
      console.log(`  role: ${typeof data.role} = "${data.role}"`);
      console.log(`  favorites: ${typeof data.favorites} = ${Array.isArray(data.favorites) ? 'Array' : 'NOT ARRAY'}`);
      if (data.favorites) {
        console.log(`  favorites length: ${data.favorites.length}`);
        console.log(`  favorites content: ${JSON.stringify(data.favorites)}`);
      }
    } else {
      console.log('❌ User document DOES NOT EXIST in Firestore!');
    }
    
    console.log('\n' + '='.repeat(50));
    
    // Check test user
    const testUID = 'xHGgjrOau6X06Elw6zv4Q4TZ69X2';
    const testDoc = await db.collection('users').doc(testUID).get();
    
    console.log(`\n👤 User: test@test.com`);
    console.log(`UID: ${testUID}`);
    
    if (testDoc.exists) {
      const data = testDoc.data();
      console.log('\n📄 Raw Firestore Data:');
      console.log(JSON.stringify(data, null, 2));
      
      console.log('\n🔍 Field Analysis:');
      console.log(`  email: ${typeof data.email} = "${data.email}"`);
      console.log(`  role: ${typeof data.role} = "${data.role}"`);
      console.log(`  favorites: ${typeof data.favorites} = ${Array.isArray(data.favorites) ? 'Array' : 'NOT ARRAY'}`);
      if (data.favorites) {
        console.log(`  favorites length: ${data.favorites.length}`);
        console.log(`  favorites content: ${JSON.stringify(data.favorites)}`);
      }
    } else {
      console.log('❌ User document DOES NOT EXIST in Firestore!');
    }
    
    console.log('\n' + '='.repeat(50) + '\n');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkUserData();

