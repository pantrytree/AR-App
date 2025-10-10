const admin = require('firebase-admin');
const path = require('path');

let serviceAccount;

if (process.env.FIREBASE_PRIVATE_KEY_PATH) {
  serviceAccount = require(path.resolve(process.env.FIREBASE_PRIVATE_KEY_PATH));
} else {
  serviceAccount = {
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  };
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: process.env.FIREBASE_PROJECT_ID,
});

const db = admin.firestore();
const auth = admin.auth();

const collections = {
  USERS: 'users',
  PROJECTS: 'projects',
  DESIGNS: 'designs',
  DESIGN_OBJECTS: 'design_objects',
  FURNITURE_ITEMS: 'furniture_items',
  FAVORITES: 'favorites',
  COLLABORATIONS: 'collaborations',
};

module.exports = {
  admin,
  db,
  auth,
  collections,
};
