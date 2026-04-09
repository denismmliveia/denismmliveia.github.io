// functions/src/qr/generateQrToken.ts
import * as admin from 'firebase-admin';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { setGlobalOptions } from 'firebase-functions/v2';
import * as jwt from 'jsonwebtoken';

setGlobalOptions({ region: 'europe-west1' });

const QR_TTL_SECONDS = 300; // 5 minutos

function getSecret(): string {
  const secret = process.env.QR_SECRET;
  if (!secret) {
    throw new HttpsError('internal', 'QR secret not configured');
  }
  return secret;
}

export const generateQrTokenHandler = async (
  request: CallableRequest<unknown>
): Promise<{ token: string; expiresAt: string }> => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Must be authenticated');
  }

  const uid = request.auth.uid;
  const issuedAt = Math.floor(Date.now() / 1000);
  const secret = getSecret();

  const token = jwt.sign({ uid, issuedAt }, secret, { expiresIn: QR_TTL_SECONDS });

  const expiresAt = new Date((issuedAt + QR_TTL_SECONDS) * 1000);

  await admin.firestore().collection('users').doc(uid).update({
    activeQrToken: token,
    qrTokenExpiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
  });

  return { token, expiresAt: expiresAt.toISOString() };
};

export const validateQrTokenHandler = async (
  request: CallableRequest<{ token: string }>
): Promise<{ valid: boolean; uid?: string }> => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Must be authenticated');
  }

  try {
    const secret = getSecret();
    const decoded = jwt.verify(request.data.token, secret) as { uid: string; issuedAt: number };

    // Verificar que el escaneador no es el mismo usuario
    if (decoded.uid === request.auth.uid) {
      return { valid: false };
    }

    // Verificar que el escaneado no ha bloqueado al escaneador
    const blockDoc = await admin
      .firestore()
      .collection('blocks')
      .doc(decoded.uid)
      .collection('blocked')
      .doc(request.auth.uid)
      .get();

    if (blockDoc.exists) {
      // Respuesta neutra — el bloqueador no sabe que está bloqueado
      return { valid: false };
    }

    return { valid: true, uid: decoded.uid };
  } catch {
    return { valid: false };
  }
};

// Exports como Cloud Functions
export const generateQrToken = onCall({ secrets: ['QR_SECRET'] }, generateQrTokenHandler);
export const validateQrToken = onCall({ secrets: ['QR_SECRET'] }, validateQrTokenHandler);
