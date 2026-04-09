import * as admin from 'firebase-admin';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { setGlobalOptions } from 'firebase-functions/v2';
import { createMemories, cleanupPhotos } from '../lib/helpers';

setGlobalOptions({ region: 'europe-west1' });

/**
 * Core logic extracted for testability.
 * Expires all linked links past their expiresAt and pending links past their pendingExpiresAt.
 */
export async function expireLinksBatch(): Promise<void> {
  const db = admin.firestore();
  const now = admin.firestore.Timestamp.now();

  // --- Expire active linked links ---
  const linkedSnap = await db
    .collection('links')
    .where('status', '==', 'linked')
    .where('expiresAt', '<=', now)
    .get();

  for (const doc of linkedSnap.docs) {
    const data = doc.data();
    try {
      await createMemories(
        doc.id,
        {
          userA: data.userA,
          userB: data.userB,
          linkedAt: data.linkedAt ?? null,
          status: 'expired',
          revokedBy: null,
        },
        now
      );
      await cleanupPhotos(doc.id);
    } catch (err) {
      console.error(`createMemories/cleanupPhotos failed for ${doc.id}:`, err);
    }
    await doc.ref.update({ status: 'expired' });
  }

  // --- Expire stale pending links ---
  const pendingSnap = await db
    .collection('links')
    .where('status', '==', 'pending')
    .where('pendingExpiresAt', '<=', now)
    .get();

  const batch = db.batch();
  for (const doc of pendingSnap.docs) {
    batch.update(doc.ref, { status: 'expired' });
  }
  if (!pendingSnap.empty) await batch.commit();
}

export const expireLinks = onSchedule(
  { schedule: 'every 5 minutes', region: 'europe-west1', timeoutSeconds: 540 },
  async () => expireLinksBatch()
);
