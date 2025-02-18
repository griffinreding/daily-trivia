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

export const submitAnswer = functions.https.onRequest(async (req, res): Promise<void> => {
    try {
        // Extract required fields from the request body.
        const { userId, userAnswer, date } = req.body;
        if (!userId || !userAnswer || !date) {
            res.status(400).json({ error: "Missing required fields: userId, userAnswer, and date." });
            return;
        }

        // Retrieve the question for the given date from the "questions" collection.
        const questionDoc = await db.collection("questions").doc(date).get();
        if (!questionDoc.exists) {
            res.status(404).json({ error: "No question found for the given date." });
            return;
        }

        const questionData = questionDoc.data();
        const correctAnswer = questionData?.correctAnswer;
        if (!correctAnswer) {
            res.status(500).json({ error: "Question data is incomplete. Missing correctAnswer field." });
            return;
        }

        // Clean and compare answers (case-insensitive).
        const userAnswerCleaned = userAnswer.trim().toLowerCase();
        const correctAnswerCleaned = String(correctAnswer).trim().toLowerCase();
        const isCorrect = userAnswerCleaned === correctAnswerCleaned;

        // Record the user's response in a "responses" collection.
        await db.collection("responses").add({
            userId,
            date,
            userAnswer,
            correct: isCorrect,
            timestamp: admin.firestore.FieldValue.serverTimestamp()
        });

        // Return the result. If incorrect, include the correct answer.
        res.json({
            correct: isCorrect,
            correctAnswer: isCorrect ? null : correctAnswer
        });
    } catch (error: unknown) {
        const err = error instanceof Error ? error : new Error("Unknown error");
        res.status(500).json({ error: "Internal server error", details: err.message });
    }
});