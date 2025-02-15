/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.getTodayQuestion = functions.https.onRequest(async (req, res) => {
    const today = new Date().toISOString().split("T")[0]; // Format YYYY-MM-DD
    const questionRef = db.collection("questions").doc(today);
    const questionDoc = await questionRef.get();

    if (!questionDoc.exists) {
        return res.status(404).json({ error: "No question for today" });
    }

    res.json(questionDoc.data());
});