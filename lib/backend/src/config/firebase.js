const admin = require('firebase-admin');
const path = require('path');

console.log('Initializing Firebase Admin...');

// Check if already initialized
if (admin.apps.length === 0) {
  const serviceAccountPath = path.join(__dirname, '../../serviceAccountKey.json');

  try {
    const serviceAccount = require(serviceAccountPath);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      storageBucket: `${serviceAccount.project_id}.appspot.com`,
    });

    console.log('Firebase Admin initialized successfully');
    console.log(`Project: ${serviceAccount.project_id}`);

  } catch (error) {
    console.error('Firebase initialization failed:', error.message);
    throw error;
  }
} else {
  console.log('Firebase Admin already initialized');
}

const db = admin.firestore();
const auth = admin.auth();
const storage = admin.storage();

// Test connection
db.collection('_health_check')
  .doc('test')
  .set({ timestamp: new Date().toISOString() })
  .then(() => {
    console.log('Firestore connection successful');
  })
  .catch((error) => {
    console.error('Firestore test failed:', error.message);
  });

module.exports = { admin, db, auth, storage };