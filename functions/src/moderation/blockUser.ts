import * as admin from 'firebase-admin';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { setGlobalOptions } from 'firebase-functions/v2';
import { createMemories, cleanupPhotos } from '../lib/helpers';

setGlobalOptions({ region: 'europe-west1' });

interface BlockUserData {
  targetUid: string;
  linkId?: string; // optional: revoke this active link at the same time
}

export const blockUserHandler = async (
  request: CallableRequest<BlockUserData>
): Promise<{ ok: boolean }> => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Must be authenticated');
  }

  const callerUid = request.auth.uid;
  const { targetUid, linkId } = request.data;

  if (!targetUid || typeof targetUid !== 'string') {
    throw new HttpsError('invalid-argument', 'targetUid is required');
  }
  if (targetUid === callerUid) {
    throw new HttpsError('invalid-argument', 'Cannot block yourself');
  }

  const db = admin.firestore();

  // Create the block record (flat doc: blocks/{callerUid}_{targetUid})
  await db
    .collection('blocks')
    .doc(`${callerUid}_${targetUid}`)
    .set({
      blockerUid: callerUid,
      blockedUid: targetUid,
      blockedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  // If there is an active link to revoke, do it
  if (linkId && typeof linkId === 'string') {
    const linkRef = db.collection('links').doc(linkId);
    const linkDoc = await linkRef.get();
    if (linkDoc && linkDoc.exists) {
      const data = linkDoc.data()!;
      if (data.status === 'linked' &&
          (data.userA === callerUid || data.userB === callerUid)) {
        const now = admin.firestore.Timestamp.now();
        await linkRef.update({ status: 'revoked', revokedBy: callerUid });
        await createMemories(
          linkId,
          { userA: data.userA, userB: data.userB, linkedAt: data.linkedAt ?? null, status: 'revoked', revokedBy: callerUid },
          now
        );
        await cleanupPhotos(linkId);
      }
    }
  }

  return { ok: true };
};

export const blockUser = onCall(blockUserHandler);
