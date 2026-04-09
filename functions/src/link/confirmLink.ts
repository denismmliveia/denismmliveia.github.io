// functions/src/link/confirmLink.ts
import * as admin from 'firebase-admin';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { setGlobalOptions } from 'firebase-functions/v2';

setGlobalOptions({ region: 'europe-west1' });

const VALID_DURATIONS_HOURS = [4, 12, 24, 72];

interface ConfirmLinkData {
  linkId: string;
  duration: number; // hours: 4, 12, 24, or 72
}

interface ConfirmLinkResult {
  expiresAt: string; // ISO string
}

export const confirmLinkHandler = async (
  request: CallableRequest<ConfirmLinkData>
): Promise<ConfirmLinkResult> => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Must be authenticated');
  }

  const callerUid = request.auth.uid;
  const { linkId, duration } = request.data;

  // Validate duration
  if (!VALID_DURATIONS_HOURS.includes(duration)) {
    throw new HttpsError(
      'invalid-argument',
      `Duration must be one of: ${VALID_DURATIONS_HOURS.join(', ')} hours`
    );
  }

  const db = admin.firestore();
  const linkRef = db.collection('links').doc(linkId);
  const linkDoc = await linkRef.get();

  if (!linkDoc.exists) {
    throw new HttpsError('not-found', 'Link not found');
  }

  const data = linkDoc.data()!;

  // Must be PENDING
  if (data.status !== 'pending') {
    throw new HttpsError('failed-precondition', 'Link is not in pending status');
  }

  // Only the NON-initiator can confirm
  if (data.initiatedBy === callerUid) {
    throw new HttpsError('permission-denied', 'The initiator cannot confirm their own link');
  }

  // Caller must be a participant
  if (data.userA !== callerUid && data.userB !== callerUid) {
    throw new HttpsError('permission-denied', 'Not a participant in this link');
  }

  // Pending window must still be open
  const pendingExpiresAt: Date = data.pendingExpiresAt.toDate();
  if (pendingExpiresAt < new Date()) {
    throw new HttpsError('deadline-exceeded', 'Pending window has expired');
  }

  const now = new Date();
  const expiresAt = new Date(now.getTime() + duration * 60 * 60 * 1000);

  await linkRef.update({
    status: 'linked',
    linkedAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
    duration,
  });

  return { expiresAt: expiresAt.toISOString() };
};

export const confirmLink = onCall(confirmLinkHandler);
