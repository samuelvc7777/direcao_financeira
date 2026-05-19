import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

type PubSubPushBody = {
  message?: {
    data?: string;
    messageId?: string;
    publishTime?: string;
  };
  subscription?: string;
};

type RealTimeDeveloperNotification = {
  version?: string;
  packageName?: string;
  eventTimeMillis?: string;
  subscriptionNotification?: {
    version?: string;
    notificationType?: number;
    purchaseToken?: string;
    subscriptionId?: string;
  };
};

type PlaySubscriptionState = {
  status: 'ACTIVE' | 'PAST_DUE' | 'CANCELED' | 'EXPIRED' | 'PENDING';
  autoRenew: boolean;
  productId?: string;
  expiresAt?: string;
  orderId?: string;
};

const androidPublisherScope =
  'https://www.googleapis.com/auth/androidpublisher';

Deno.serve(async (request) => {
  if (request.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  const expectedSecret = Deno.env.get('GOOGLE_PLAY_RTDN_SECRET')?.trim();
  if (expectedSecret) {
    const receivedSecret =
      request.headers.get('x-webhook-secret') ??
      new URL(request.url).searchParams.get('secret');
    if (receivedSecret !== expectedSecret) {
      return jsonResponse({ error: 'Unauthorized' }, 401);
    }
  }

  const supabaseUrl = requiredEnv('SUPABASE_URL');
  const serviceRoleKey = requiredEnv('SUPABASE_SERVICE_ROLE_KEY');
  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  const body = (await request.json()) as PubSubPushBody;
  const notification = decodeNotification(body);
  const subscriptionNotification = notification.subscriptionNotification;
  const purchaseToken = subscriptionNotification?.purchaseToken?.trim();

  if (!purchaseToken) {
    return jsonResponse({ error: 'purchaseToken ausente' }, 400);
  }

  const notificationType = subscriptionNotification?.notificationType;
  const eventTime = notification.eventTimeMillis
    ? new Date(Number(notification.eventTimeMillis)).toISOString()
    : body.message?.publishTime ?? new Date().toISOString();

  await supabase.from('GooglePlaySubscriptionEvent').insert({
    purchaseToken,
    productId: subscriptionNotification?.subscriptionId ?? null,
    notificationType: notificationType ?? null,
    eventTime,
    payload: notification,
  });

  const existing = await supabase
    .from('Subscription')
    .select('id,endDate,updatedAt')
    .eq('googlePlayPurchaseToken', purchaseToken)
    .maybeSingle();

  if (existing.error) {
    throw existing.error;
  }

  if (!existing.data) {
    return jsonResponse({
      ok: true,
      processed: false,
      reason:
        'Token ainda nao esta vinculado a um usuario. O app vincula no restore/compra.',
    });
  }

  const canSkipStaleEvent =
    notificationType === 1 ||
    notificationType === 2 ||
    notificationType === 4 ||
    notificationType === 6 ||
    notificationType === 7;
  const staleEvent = canSkipStaleEvent &&
    existing.data.updatedAt &&
    eventTime &&
    new Date(eventTime).getTime() <
      new Date(existing.data.updatedAt).getTime() - 5000;

  if (staleEvent) {
    await markEventsProcessed(supabase, purchaseToken);
    return jsonResponse({
      ok: true,
      processed: true,
      skipped: true,
      reason: 'Evento antigo ignorado para nao sobrescrever estado recente.',
    });
  }

  const playState =
    (await tryFetchPlaySubscriptionState(purchaseToken)) ??
    fallbackStateFromNotification(notificationType, existing.data.endDate);

  const now = new Date().toISOString();
  const updatePayload = {
    status: playState.status,
    autoRenew: playState.autoRenew,
    canceledAt:
      playState.status === 'CANCELED' || playState.status === 'EXPIRED'
        ? now
        : null,
    googlePlayProductId:
      playState.productId ?? subscriptionNotification?.subscriptionId ?? null,
    googlePlayOrderId: playState.orderId ?? null,
    googlePlayExpiresAt: playState.expiresAt ?? null,
    endDate: playState.expiresAt ?? existing.data.endDate,
    updatedAt: now,
  };

  const updated = await supabase
    .from('Subscription')
    .update(updatePayload)
    .eq('id', existing.data.id)
    .select('id,status,autoRenew,endDate')
    .single();

  if (updated.error) {
    throw updated.error;
  }

  await markEventsProcessed(supabase, purchaseToken);

  return jsonResponse({ ok: true, processed: true, subscription: updated.data });
});

function decodeNotification(body: PubSubPushBody): RealTimeDeveloperNotification {
  const encoded = body.message?.data;
  if (!encoded) {
    throw new Error('Pub/Sub message.data ausente.');
  }

  const decoded = atob(encoded);
  return JSON.parse(decoded) as RealTimeDeveloperNotification;
}

async function markEventsProcessed(
  supabase: ReturnType<typeof createClient>,
  purchaseToken: string,
): Promise<void> {
  const now = new Date().toISOString();
  await supabase
    .from('GooglePlaySubscriptionEvent')
    .update({ processedAt: now })
    .eq('purchaseToken', purchaseToken)
    .is('processedAt', null);
}

async function fetchPlaySubscriptionState(
  purchaseToken: string,
): Promise<PlaySubscriptionState | null> {
  const packageName = Deno.env.get('ANDROID_PACKAGE_NAME')?.trim();
  const serviceAccountJson = Deno.env.get('GOOGLE_SERVICE_ACCOUNT_JSON')?.trim();

  if (!packageName || !serviceAccountJson) {
    return null;
  }

  const accessToken = await getGoogleAccessToken(serviceAccountJson);
  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}` +
    `/purchases/subscriptionsv2/tokens/${purchaseToken}`;

  const response = await fetch(url, {
    headers: { authorization: `Bearer ${accessToken}` },
  });

  if (!response.ok) {
    throw new Error(
      `Falha ao consultar Google Play Developer API: ${response.status}`,
    );
  }

  const data = await response.json();
  const lineItem = Array.isArray(data.lineItems) ? data.lineItems[0] : null;
  const autoRenewEnabled =
    lineItem?.autoRenewingPlan?.autoRenewEnabled === true;

  return {
    status: mapPlaySubscriptionState(data.subscriptionState),
    autoRenew: autoRenewEnabled,
    productId: lineItem?.productId,
    expiresAt: lineItem?.expiryTime,
    orderId: lineItem?.latestSuccessfulOrderId ?? data.latestOrderId,
  };
}

async function tryFetchPlaySubscriptionState(
  purchaseToken: string,
): Promise<PlaySubscriptionState | null> {
  try {
    return await fetchPlaySubscriptionState(purchaseToken);
  } catch (error) {
    console.error('Falha ao consultar Play Developer API; usando fallback RTDN.', {
      error: error instanceof Error ? error.message : String(error),
    });
    return null;
  }
}

function fallbackStateFromNotification(
  notificationType?: number,
  currentEndDate?: string | null,
): PlaySubscriptionState {
  const now = new Date();
  const stillEntitled = currentEndDate
    ? new Date(currentEndDate).getTime() > now.getTime()
    : false;

  switch (notificationType) {
    case 1:
    case 2:
    case 4:
    case 6:
    case 7:
      return { status: 'ACTIVE', autoRenew: true };
    case 3:
      return {
        status: stillEntitled ? 'ACTIVE' : 'CANCELED',
        autoRenew: false,
      };
    case 5:
    case 10:
      return { status: 'PAST_DUE', autoRenew: false };
    case 12:
      return {
        status: 'CANCELED',
        autoRenew: false,
        expiresAt: now.toISOString(),
      };
    case 13:
    case 20:
      return {
        status: 'EXPIRED',
        autoRenew: false,
        expiresAt: now.toISOString(),
      };
    default:
      return { status: stillEntitled ? 'ACTIVE' : 'PENDING', autoRenew: false };
  }
}

function mapPlaySubscriptionState(state?: string): PlaySubscriptionState['status'] {
  switch (state) {
    case 'SUBSCRIPTION_STATE_ACTIVE':
    case 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD':
    case 'SUBSCRIPTION_STATE_CANCELED':
      return 'ACTIVE';
    case 'SUBSCRIPTION_STATE_ON_HOLD':
    case 'SUBSCRIPTION_STATE_PAUSED':
      return 'PAST_DUE';
    case 'SUBSCRIPTION_STATE_EXPIRED':
      return 'EXPIRED';
    case 'SUBSCRIPTION_STATE_PENDING_PURCHASE_CANCELED':
      return 'CANCELED';
    case 'SUBSCRIPTION_STATE_PENDING':
    default:
      return 'PENDING';
  }
}

async function getGoogleAccessToken(serviceAccountJson: string): Promise<string> {
  const account = JSON.parse(serviceAccountJson);
  const tokenUri = account.token_uri ?? 'https://oauth2.googleapis.com/token';
  const now = Math.floor(Date.now() / 1000);
  const assertion = await signJwt(
    {
      alg: 'RS256',
      typ: 'JWT',
    },
    {
      iss: account.client_email,
      scope: androidPublisherScope,
      aud: tokenUri,
      iat: now,
      exp: now + 3600,
    },
    account.private_key,
  );

  const response = await fetch(tokenUri, {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });

  if (!response.ok) {
    throw new Error(`Falha ao autenticar service account: ${response.status}`);
  }

  const data = await response.json();
  return data.access_token;
}

async function signJwt(
  header: Record<string, unknown>,
  payload: Record<string, unknown>,
  privateKeyPem: string,
): Promise<string> {
  const unsigned =
    `${base64UrlEncode(JSON.stringify(header))}.${base64UrlEncode(
      JSON.stringify(payload),
    )}`;
  const key = await crypto.subtle.importKey(
    'pkcs8',
    pemToArrayBuffer(privateKeyPem),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(unsigned),
  );
  return `${unsigned}.${base64UrlEncode(signature)}`;
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const base64 = pem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replaceAll(/\s/g, '');
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

function base64UrlEncode(input: string | ArrayBuffer): string {
  const bytes =
    typeof input === 'string'
      ? new TextEncoder().encode(input)
      : new Uint8Array(input);
  let binary = '';
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary).replaceAll('+', '-').replaceAll('/', '_').replaceAll(
    '=',
    '',
  );
}

function requiredEnv(name: string): string {
  const value = Deno.env.get(name)?.trim();
  if (!value) {
    throw new Error(`Variavel de ambiente obrigatoria ausente: ${name}`);
  }
  return value;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json; charset=utf-8' },
  });
}
