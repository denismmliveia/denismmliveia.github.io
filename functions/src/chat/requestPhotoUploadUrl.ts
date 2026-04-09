import { onCall, CallableRequest, HttpsError } from 'firebase-functions/v2/https';
import { setGlobalOptions } from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

setGlobalOptions({ region: 'europe-west1' });

async function handler(request: CallableRequest<{ linkId: string; msgId: string }>) {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Not authenticated');

  const { linkId, msgId } = request.data;

  const linkDoc = await admin.firestore().collection('links').doc(linkId).get();
  if (!linkDoc.exists) throw new HttpsError('not-found', 'Link not found');

  const link = linkDoc.data()!;
  if (link.userA !== uid && link.userB !== uid) {
    throw new HttpsError('permission-denied', 'Not a participant');
  }
  if (link.status !== 'linked') {
    throw new HttpsError('failed-precondition', 'Link not active');
  }

  const photoRef = `chat/${linkId}/${msgId}/${uid}_${Date.now()}.jpg`;
  const bucket = admin.storage().bucket();
  const file = bucket.file(photoRef);

  const [uploadUrl] = await file.getSignedUrl({
    action: 'write',
    expires: Date.now() + 5 * 60 * 1000,
    contentType: 'image/jpeg',
  });

  return { uploadUrl, photoRef };
}

export const requestPhotoUploadUrl = onCall(handler);
(requestPhotoUploadUrl as any).__handler = handler;
