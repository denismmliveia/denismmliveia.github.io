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

  const msgRef = admin.firestore()
    .collection('links').doc(linkId)
    .collection('messages').doc(msgId);
  const msgDoc = await msgRef.get();
  if (!msgDoc.exists) throw new HttpsError('not-found', 'Message not found');

  const msg = msgDoc.data()!;
  if (msg.type !== 'photo_once') throw new HttpsError('invalid-argument', 'Not a photo message');
  if (msg.deletedFromStorage) throw new HttpsError('not-found', 'Photo already deleted');
  if ((msg.viewedBy as string[]).includes(uid)) {
    throw new HttpsError('already-exists', 'Already viewed');
  }

  const bucket = admin.storage().bucket();
  const file = bucket.file(msg.photoRef as string);

  const [viewUrl] = await file.getSignedUrl({
    action: 'read',
    expires: Date.now() + 15 * 1000,
  });

  await msgRef.update({
    viewedBy: admin.firestore.FieldValue.arrayUnion(uid),
  });

  const updatedViewedBy = [...(msg.viewedBy as string[]), uid];
  const participants = [link.userA as string, link.userB as string];
  const allViewed = participants.every((p) => updatedViewedBy.includes(p));

  if (allViewed) {
    await file.delete().catch(() => {});
    await msgRef.update({ deletedFromStorage: true });
  }

  return { viewUrl };
}

export const getPhotoViewUrl = onCall(handler);
(getPhotoViewUrl as any).__handler = handler;
