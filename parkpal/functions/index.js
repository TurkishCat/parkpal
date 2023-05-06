const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.createUserInFirestore = functions.auth.user().onCreate(async (user) => {
  try {
    const appUserRef = admin.firestore().collection('users').doc(user.uid);
    const appUser = {
      uid: user.uid,
      email: user.email,
      parkSpots: [],
      cars: []
    };
    await appUserRef.set(appUser);
    console.log(`User ${user.uid} created in Firestore.`);
  } catch (error) {
    console.error(`Error creating user ${user.uid} in Firestore: ${error}`);
  }
});
