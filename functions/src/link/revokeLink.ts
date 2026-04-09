import * as admin from 'firebase-admin';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { setGlobalOptions } from 'firebase-functions/v2';
import { createMemories, cleanupPhotos } from '../lib/helpers';

setGlobalOptions({ region: 'europe-west1' });

interface RevokeLinkData {
  linkId: string;
}

export const revokeLinkHandler = async (
  request: CallableRequest<RevokeLinkData>
): Promise<{ ok: boolean }> => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Must be authenticated');
  }

  const callerUid = request.auth.uid;
  const { linkId } = request.data;

  if (!linkId || typeof linkId !== 'string') {
    throw new HttpsError('invalid-argument', 'linkId is required');
  }

  const db = admin.firestore();
  const linkRef = db.collection('links').doc(linkId);
  const linkDoc = await linkRef.get();

  if (!linkDoc.exists) {
    throw new HttpsError('not-found', 'Link not found');
  }

  const data = linkDoc.data()!;

  if (data.userA !== callerUid && data.userB !== callerUid) {
    throw new HttpsError('permission-denied', 'Not a participant in this link');
  }

  if (data.status !== 'linked') {
    throw new HttpsError('failed-precondition', 'Link is not active');
  }

  const now = admin.firestore.Timestamp.now();

  await linkRef.update({ status: 'revoked', revokedBy: callerUid });

  await createMemories(
    linkId,
    {
      userA: data.userA,
      userB: data.userB,
      linkedAt: data.linkedAt ?? null,
      status: 'revoked',
      revokedBy: callerUid,
    },
    now
  );

  await cleanupPhotos(linkId);

  return { ok: true };
};

export const revokeLink = onCall(revokeLinkHandler);
