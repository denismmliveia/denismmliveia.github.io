// functions/src/link/initiateLink.ts
import * as admin from 'firebase-admin';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { setGlobalOptions } from 'firebase-functions/v2';
import * as jwt from 'jsonwebtoken';

setGlobalOptions({ region: 'europe-west1' });

const PENDING_WINDOW_SECONDS = 60;

function getSecret(): string {
  const secret = process.env.QR_SECRET;
  if (!secret) throw new HttpsError('internal', 'QR secret not configured');
  return secret;
}

interface InitiateLinkData {
  token: string;
}

interface InitiateLinkResult {
  status: 'pending' | 'linked';
  linkId: string;
  isMutual: boolean;
}

export const initiateLinkHandler = async (
  request: CallableRequest<InitiateLinkData>
): Promise<InitiateLinkResult> => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Must be authenticated');
  }

  const scannerUid = request.auth.uid;

  // 1. Verify the scanned JWT
  let targetUid: string;
  try {
    const payload = jwt.verify(request.data.token, getSecret()) as { uid?: string };
    if (typeof payload.uid !== 'string' || payload.uid.length === 0) {
      throw new HttpsError('invalid-argument', 'Invalid or expired QR token');
    }
    targetUid = payload.uid;
  } catch (err) {
    if (err instanceof HttpsError) throw err;
    throw new HttpsError('invalid-argument', 'Invalid or expired QR token');
  }

  // 2. Prevent self-scan
  if (targetUid === scannerUid) {
    throw new HttpsError('invalid-argument', 'Cannot scan your own QR');
  }

  // 3. Check if target has blocked scanner (silent rejection)
  const blockDoc = await admin
    .firestore()
    .collection('blocks')
    .doc(targetUid)
    .collection('blocked')
    .doc(scannerUid)
    .get();

  if (blockDoc.exists) {
    throw new HttpsError('not-found', 'User not found');
  }

  // 4. Look for an active PENDING link between these two users (either direction)
  const db = admin.firestore();
  const now = new Date();

  const [snapAB, snapBA] = await Promise.all([
    db.collection('links')
      .where('userA', '==', scannerUid)
      .where('userB', '==', targetUid)
      .where('status', '==', 'pending')
      .get(),
    db.collection('links')
      .where('userA', '==', targetUid)
      .where('userB', '==', scannerUid)
      .where('status', '==', 'pending')
      .get(),
  ]);

  const allPending = [...snapAB.docs, ...snapBA.docs];

  for (const doc of allPending) {
    const data = doc.data();
    const pendingExpiresAt: Date = data.pendingExpiresAt.toDate();

    if (pendingExpiresAt > now) {
      // Within window
      if (data.initiatedBy === targetUid) {
        // TARGET initiated first → this scan completes the mutual exchange
        // Persist the 'linked' status to Firestore (C1 fix — without this the doc stays 'pending' forever)
        await doc.ref.update({
          status: 'linked',
          linkedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // NOTE (C2): No transaction here — concurrent duplicate scans are a known V1 limitation.
        // TODO: wrap in transaction to prevent race on concurrent scans in a future iteration.
        return { status: 'linked', linkId: doc.id, isMutual: true };
      } else {
        // SCANNER already initiated → re-scan within window, no-op
        return { status: 'pending', linkId: doc.id, isMutual: false };
      }
    } else {
      // Expired PENDING → mark as expired so it no longer pollutes the list (fire-and-forget — I4 fix)
      doc.ref.update({ status: 'expired' }).catch(() => {});
    }
  }

  // 5. No valid PENDING found → create a new one
  const pendingExpiresAt = new Date(now.getTime() + PENDING_WINDOW_SECONDS * 1000);
  const newLink = await db.collection('links').add({
    userA: scannerUid,
    userB: targetUid,
    status: 'pending',
    initiatedBy: scannerUid,
    pendingExpiresAt: admin.firestore.Timestamp.fromDate(pendingExpiresAt),
    linkedAt: null,
    expiresAt: null,
    duration: null,
    revokedBy: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { status: 'pending', linkId: newLink.id, isMutual: false };
};

export const initiateLink = onCall(initiateLinkHandler);
