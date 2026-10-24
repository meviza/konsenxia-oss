import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// ─────────────────────────────────────────────────────────────────────────────
// 1. onCaseCreated — Firestore trigger: cases/{caseId} onCreate
// ─────────────────────────────────────────────────────────────────────────────
export const onCaseCreated = functions.firestore
  .document("cases/{caseId}")
  .onCreate(async (snap, context) => {
    const caseData = snap.data();
    const authorId = caseData.authorId as string | undefined;
    const specialties: string[] = caseData.specialties ?? [];
    const caseId = context.params.caseId;

    const batch = db.batch();

    // Award 50 XP to the case author
    if (authorId) {
      const userRef = db.collection("users").doc(authorId);
      batch.update(userRef, {
        xp: admin.firestore.FieldValue.increment(50),
        xpThisWeek: admin.firestore.FieldValue.increment(50),
        xpThisMonth: admin.firestore.FieldValue.increment(50),
        caseCount: admin.firestore.FieldValue.increment(1),
      });
    }

    // Update community stats
    const statsRef = db.collection("meta").doc("stats");
    batch.set(
      statsRef,
      {
        totalCases: admin.firestore.FieldValue.increment(1),
        lastCaseAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    await batch.commit();

    // Send notification to followers of the specialty (up to 500)
    if (specialties.length > 0) {
      const primarySpecialty = specialties[0];
      const followers = await db
        .collection("users")
        .where("specialty", "==", primarySpecialty)
        .limit(500)
        .get();

      const notifBatch = db.batch();
      let count = 0;

      for (const follower of followers.docs) {
        // Don't notify the author themselves
        if (follower.id === authorId) continue;

        const notifRef = db
          .collection("notifications")
          .doc(follower.id)
          .collection("items")
          .doc();

        notifBatch.set(notifRef, {
          type: "new_case",
          title: "Yeni vaka paylaşıldı",
          body: `${primarySpecialty} alanında yeni bir vaka: ${caseData.title ?? ""}`,
          data: { caseId },
          isRead: false,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

        count++;
        // Firestore batch limit is 500 writes
        if (count >= 498) break;
      }

      if (count > 0) {
        await notifBatch.commit();
      }
    }

    functions.logger.info(`onCaseCreated: caseId=${caseId}, author=${authorId}`);
  });

// ─────────────────────────────────────────────────────────────────────────────
// 2. onCommentAdded — Firestore trigger: cases/{caseId}/comments/{commentId}
// ─────────────────────────────────────────────────────────────────────────────
export const onCommentAdded = functions.firestore
  .document("cases/{caseId}/comments/{commentId}")
  .onCreate(async (snap, context) => {
    const commentData = snap.data();
    const commenterId = commentData.authorId as string | undefined;
    const caseId = context.params.caseId;

    // Get the case document to find the case author
    const caseDoc = await db.collection("cases").doc(caseId).get();
    const caseAuthorId = caseDoc.data()?.authorId as string | undefined;

    const batch = db.batch();

    // Award 10 XP to the commenter
    if (commenterId) {
      const commenterRef = db.collection("users").doc(commenterId);
      batch.update(commenterRef, {
        xp: admin.firestore.FieldValue.increment(10),
        xpThisWeek: admin.firestore.FieldValue.increment(10),
        xpThisMonth: admin.firestore.FieldValue.increment(10),
        totalComments: admin.firestore.FieldValue.increment(1),
      });
    }

    // Award 5 XP to the case author (for engagement on their case)
    if (caseAuthorId && caseAuthorId !== commenterId) {
      const caseAuthorRef = db.collection("users").doc(caseAuthorId);
      batch.update(caseAuthorRef, {
        xp: admin.firestore.FieldValue.increment(5),
        xpThisWeek: admin.firestore.FieldValue.increment(5),
        xpThisMonth: admin.firestore.FieldValue.increment(5),
      });
    }

    // Update the case's commentCount
    const caseRef = db.collection("cases").doc(caseId);
    batch.update(caseRef, {
      commentCount: admin.firestore.FieldValue.increment(1),
    });

    await batch.commit();

    // Send notification to case author
    if (caseAuthorId && caseAuthorId !== commenterId) {
      const commenterName = commentData.authorName ?? "Bir doktor";
      await db
        .collection("notifications")
        .doc(caseAuthorId)
        .collection("items")
        .add({
          type: "comment",
          title: "Vakanıza yorum geldi",
          body: `${commenterName} vakanıza yorum ekledi.`,
          data: { caseId, commentId: context.params.commentId },
          isRead: false,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
    }

    functions.logger.info(
      `onCommentAdded: caseId=${caseId}, commenter=${commenterId}`
    );
  });

// ─────────────────────────────────────────────────────────────────────────────
// 3. onAcceptedAnswer — Firestore trigger: comment isAccepted update
// ─────────────────────────────────────────────────────────────────────────────
export const onAcceptedAnswer = functions.firestore
  .document("cases/{caseId}/comments/{commentId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Only trigger when isAcceptedAnswer changes from false/undefined to true
    if (before.isAcceptedAnswer === true || after.isAcceptedAnswer !== true) {
      return;
    }

    const caseId = context.params.caseId;
    const answerId = after.authorId as string | undefined;
    const answerAuthorName = after.authorName ?? "Bir doktor";

    const batch = db.batch();

    // Award 25 XP to the accepted answer author
    if (answerId) {
      const answerAuthorRef = db.collection("users").doc(answerId);
      batch.update(answerAuthorRef, {
        xp: admin.firestore.FieldValue.increment(25),
        xpThisWeek: admin.firestore.FieldValue.increment(25),
        xpThisMonth: admin.firestore.FieldValue.increment(25),
        acceptedAnswers: admin.firestore.FieldValue.increment(1),
      });
    }

    // Mark the case as solved
    const caseRef = db.collection("cases").doc(caseId);
    batch.update(caseRef, {
      isSolved: true,
      status: "solved",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // Send notification to the answer author
    if (answerId) {
      await db
        .collection("notifications")
        .doc(answerId)
        .collection("items")
        .add({
          type: "accepted_answer",
          title: "Cevabınız kabul edildi!",
          body: `Tebrikler ${answerAuthorName}! Cevabınız doğru yanıt olarak seçildi. +25 XP kazandınız.`,
          data: { caseId, commentId: context.params.commentId },
          isRead: false,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
    }

    functions.logger.info(
      `onAcceptedAnswer: caseId=${caseId}, answerer=${answerId}`
    );
  });

// ─────────────────────────────────────────────────────────────────────────────
// 4. aggregateStats — Scheduled: every 1 hour
// ─────────────────────────────────────────────────────────────────────────────
export const aggregateStats = functions.pubsub
  .schedule("every 60 minutes")
  .timeZone("Europe/Istanbul")
  .onRun(async () => {
    const now = new Date();

    // Total doctors
    const usersSnap = await db.collection("users").count().get();
    const totalDoctors = usersSnap.data().count;

    // Active today (lastSeen within the last 24 hours)
    const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    const activeTodaySnap = await db
      .collection("users")
      .where("lastSeen", ">=", admin.firestore.Timestamp.fromDate(oneDayAgo))
      .count()
      .get();
    const activeToday = activeTodaySnap.data().count;

    // Cases this week
    const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    const casesThisWeekSnap = await db
      .collection("cases")
      .where(
        "createdAt",
        ">=",
        admin.firestore.Timestamp.fromDate(oneWeekAgo)
      )
      .count()
      .get();
    const casesThisWeek = casesThisWeekSnap.data().count;

    // Total cases and solved cases for solved percentage
    const totalCasesSnap = await db.collection("cases").count().get();
    const totalCases = totalCasesSnap.data().count;

    const solvedCasesSnap = await db
      .collection("cases")
      .where("isSolved", "==", true)
      .count()
      .get();
    const solvedCases = solvedCasesSnap.data().count;

    const solvedPercentage =
      totalCases > 0 ? Math.round((solvedCases / totalCases) * 100) : 0;

    // Write aggregated stats
    await db
      .collection("meta")
      .doc("stats")
      .set(
        {
          totalDoctors,
          activeToday,
          casesThisWeek,
          totalCases,
          solvedCases,
          solvedPercentage,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

    functions.logger.info(
      `aggregateStats: doctors=${totalDoctors}, active=${activeToday}, ` +
        `casesThisWeek=${casesThisWeek}, solved=${solvedPercentage}%`
    );
  });

// ─────────────────────────────────────────────────────────────────────────────
// 5. cleanupNotifications — Scheduled: daily at 03:00 Istanbul time
// ─────────────────────────────────────────────────────────────────────────────
export const cleanupNotifications = functions.pubsub
  .schedule("every day 03:00")
  .timeZone("Europe/Istanbul")
  .onRun(async () => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const cutoff = admin.firestore.Timestamp.fromDate(thirtyDaysAgo);

    // Get all user IDs that have notification subcollections
    // We iterate over users in batches of 100
    let deletedTotal = 0;
    let lastUserDoc: admin.firestore.QueryDocumentSnapshot | undefined;

    // eslint-disable-next-line no-constant-condition
    while (true) {
      let usersQuery = db.collection("users").limit(100);
      if (lastUserDoc) {
        usersQuery = usersQuery.startAfter(lastUserDoc);
      }

      const usersSnap = await usersQuery.get();
      if (usersSnap.empty) break;

      for (const userDoc of usersSnap.docs) {
        const oldNotifs = await db
          .collection("notifications")
          .doc(userDoc.id)
          .collection("items")
          .where("isRead", "==", true)
          .where("timestamp", "<", cutoff)
          .limit(500)
          .get();

        if (oldNotifs.empty) continue;

        const batch = db.batch();
        for (const notifDoc of oldNotifs.docs) {
          batch.delete(notifDoc.ref);
        }
        await batch.commit();
        deletedTotal += oldNotifs.size;
      }

      lastUserDoc = usersSnap.docs[usersSnap.docs.length - 1];

      // If we got fewer than 100 users, we've reached the end
      if (usersSnap.size < 100) break;
    }

    functions.logger.info(
      `cleanupNotifications: deleted ${deletedTotal} old read notifications`
    );
  });
