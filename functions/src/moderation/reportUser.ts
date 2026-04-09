import * as admin from 'firebase-admin';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { setGlobalOptions } from 'firebase-functions/v2';
import { blockUserHandler } from './blockUser';

setGlobalOptions({ region: 'europe-west1' });

interface ReportUserData {
  targetUid: string;
  reason: string;
  linkId?: string;
}

export const reportUserHandler = async (
  request: CallableRequest<ReportUserData>
): Promise<{ ok: boolean }> => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Must be authenticated');
  }

  const callerUid = request.auth.uid;
  const { targetUid, reason, linkId } = request.data;

  if (!targetUid || typeof targetUid !== 'string') {
    throw new HttpsError('invalid-argument', 'targetUid is required');
  }
  if (!reason || typeof reason !== 'string' || reason.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'reason is required');
  }

  if (targetUid === callerUid) {
    throw new HttpsError('invalid-argument', 'Cannot report yourself');
  }

  const db = admin.firestore();

  // Rate limit: max 5 reports per user per hour
  const oneHourAgo = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 60 * 60 * 1000)
  );
  const recentReports = await db.collection('reports')
    .where('reporterUid', '==', callerUid)
    .where('createdAt', '>=', oneHourAgo)
    .get();
  if (recentReports.docs.length >= 5) {
    throw new HttpsError('resource-exhausted', 'Too many reports. Try again later.');
  }

  // Create report document
  await db.collection('reports').add({
    reporterUid: callerUid,
    targetUid,
    reason: reason.trim(),
    linkId: linkId ?? null,
    status: 'pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Also block the reported user (and optionally revoke link)
  await blockUserHandler(request);

  return { ok: true };
};

export const reportUser = onCall(reportUserHandler);
