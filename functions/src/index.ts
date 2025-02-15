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

export const getTodayQuestion = functions.https.onRequest(async (_req, res): Promise<void> => {
    try {
        const today = new Date().toISOString().split("T")[0]; // Format YYYY-MM-DD
        const questionRef = db.collection("questions").doc(today);
        const questionDoc = await questionRef.get();

        if (!questionDoc.exists) {
            res.status(404).json({ error: "No question for today" });
            return;  // Explicitly return to handle all paths
        }

        res.json(questionDoc.data());
        return; // Ensure we return void after sending the response
    } catch (error: unknown) {
        const err = error instanceof Error ? error : new Error("Unknown error");
        res.status(500).json({ error: "Internal server error", details: err.message });
        return;
      }
});


export const submitAnswer = functions.https.onRequest(async (req, res): Promise<void> => {
    try {
        const { userId, userAnswer } = req.body;

        if (!userId || !userAnswer) {
            res.status(400).json({ error: "Missing required fields" });
            return;
        }

        const today = new Date().toISOString().split("T")[0];
        const questionRef = db.collection("questions").doc(today);
        const questionDoc = await questionRef.get();

        if (!questionDoc.exists) {
            res.status(404).json({ error: "No question for today" });
            return;
        }

        const correctAnswer: string = questionDoc.data()?.correctAnswer;
        const isCorrect = userAnswer.trim().toLowerCase() === correctAnswer.toLowerCase();

        // Save response
        await db.collection("responses").add({
            userId,
            date: today,
            userAnswer,
            correct: isCorrect,
        });

        res.json({ correct: isCorrect });
        return;
    } catch (error: unknown) {
        const err = error instanceof Error ? error : new Error("Unknown error");
        res.status(500).json({ error: "Internal server error", details: err.message });
        return;
      }
});