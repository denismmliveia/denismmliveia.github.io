import * as admin from 'firebase-admin';

/**
 * Creates a minimal memory document for both participants of a link.
 * Memory docId = linkId (idempotent: safe to call multiple times).
 */
export async function createMemories(
  linkId: string,
  linkData: {
    userA: string;
    userB: string;
    linkedAt: admin.firestore.Timestamp | null;
    status: string;
    revokedBy?: string | null;
  },
  endedAt: admin.firestore.Timestamp
): Promise<void> {
  const db = admin.firestore();

  // Fetch both user profiles to get display names + photos
  const [profileA, profileB] = await Promise.all([
    db.collection('users').doc(linkData.userA).get(),
    db.collection('users').doc(linkData.userB).get(),
  ]);

  const dataA = profileA.data() ?? {};
  const dataB = profileB.data() ?? {};

  // revokedBy is intentionally not persisted in memories (minimal-memory policy)
  const baseMemory = {
    linkedAt: linkData.linkedAt ?? null,
    endedAt,
    status: linkData.status === 'revoked' ? 'revoked' : 'expired',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  const batch = db.batch();

  // Memory for userA: other user is userB
  batch.set(
    db.collection('memories').doc(linkData.userA).collection('cards').doc(linkId),
    {
      ...baseMemory,
      otherUid: linkData.userB,
      otherUserName: dataB.displayName ?? 'Desconocido',
      otherUserPhotoUrl: dataB.photoUrl ?? null,
    },
    { merge: true }
  );

  // Memory for userB: other user is userA
  batch.set(
    db.collection('memories').doc(linkData.userB).collection('cards').doc(linkId),
    {
      ...baseMemory,
      otherUid: linkData.userA,
      otherUserName: dataA.displayName ?? 'Desconocido',
      otherUserPhotoUrl: dataA.photoUrl ?? null,
    },
    { merge: true }
  );

  await batch.commit();
}

/**
 * Deletes all unviewed photo-once Storage objects for a link
 * and marks them as deletedFromStorage in Firestore.
 */
export async function cleanupPhotos(linkId: string): Promise<void> {
  const db = admin.firestore();
  const bucket = admin.storage().bucket();

  const messagesSnap = await db
    .collection('links')
    .doc(linkId)
    .collection('messages')
    .where('type', '==', 'photo_once')
    .where('deletedFromStorage', '==', false)
    .get();

  await Promise.all(
    messagesSnap.docs.map(async (doc) => {
      const photoRef: string | undefined = doc.data().photoRef;
      if (photoRef) {
        try {
          await bucket.file(photoRef).delete();
        } catch (err: unknown) {
          const code = (err as { code?: number }).code;
          if (code !== 404) {
            console.error(`cleanupPhotos: failed to delete ${photoRef}`, err);
            // Still mark deletedFromStorage:true to avoid blocking retries on transient errors
          }
        }
      }
      await doc.ref.update({ deletedFromStorage: true });
    })
  );
}
