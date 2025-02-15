/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

export const getTodayQuestion = functions.https.onRequest(async (req, res) => {
    try {
        const today = new Date().toISOString().split("T")[0]; // Format YYYY-MM-DD
        const questionRef = db.collection("questions").doc(today);
        const questionDoc = await questionRef.get();

        if (!questionDoc.exists) {
            return res.status(404).json({ error: "No question for today" });
        }

        res.json(questionDoc.data());
    } catch (error) {
        res.status(500).json({ error: "Internal server error", details: error });
    }
});