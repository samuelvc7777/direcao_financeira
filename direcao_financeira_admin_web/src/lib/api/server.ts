import { createClient } from "@supabase/supabase-js";

import type { HelpVideo, Plan, Subscription, User } from "@/lib/subscriptions";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

type DashboardData = {
  metrics: {
    totalUsers: number;
    activeUsers: number;
    newUsers24h: number;
    estimatedRevenue: number;
  };
  plans: Array<{
    name: string;
    count: number;
    revenue: number;
  }>;
  recentActivity: Array<{
    id: string;
    action: string;
    details: string;
    userName: string;
    createdAt: string;
  }>;
};

type UserRow = Omit<User, "activeSubscription" | "subscriptions">;
type SubscriptionRow = Omit<Subscription, "plan" | "payments"> & {
  userId: number;
  planId: number;
};
type HelpVideoRow = {
  id: number;
  title: string;
  description: string | null;
  video_url: string;
  youtube_video_id: string;
  category: string | null;
  duration_label: string | null;
  thumbnail_url: string | null;
  is_featured: boolean;
  is_active: boolean;
  sort_order: number;
  created_at: string;
  updated_at: string;
};

const TABLES = {
  users: "User",
  plans: "Plan",
  subscriptions: "Subscription",
  helpVideos: "videos",
  company: "Company",
} as const;

function createServerSupabase() {
  if (!supabaseUrl || !supabaseServiceRoleKey) {
    throw new Error("Supabase server nao configurado. Defina NEXT_PUBLIC_SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY.");
  }

  return createClient(supabaseUrl, supabaseServiceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

function assertNoError(error: { message: string } | null) {
  if (error) {
    throw new Error(error.message);
  }
}

function isMissingGoogleApiKeyColumn(error: { message: string } | null) {
  return Boolean(error?.message.includes("Company.googleApiKey"));
}

function isAdminRole(role: string) {
  return role === "ADMIN" || role === "ATTENDANT";
}

function selectActiveSubscription(subscriptions: Subscription[]): Subscription | null {
  const active = subscriptions.find((subscription) =>
    ["ACTIVE", "TRIAL"].includes(subscription.status.toUpperCase()),
  );

  return active ?? subscriptions[0] ?? null;
}

async function getPlansById(planIds: number[]) {
  const uniqueIds = Array.from(new Set(planIds)).filter(Boolean);

  if (uniqueIds.length === 0) {
    return new Map<number, Plan>();
  }

  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.plans)
    .select("*")
    .in("id", uniqueIds);

  assertNoError(error);

  return new Map((data as Plan[]).map((plan) => [plan.id, plan]));
}

async function hydrateUsers(users: UserRow[]): Promise<User[]> {
  if (users.length === 0) {
    return [];
  }

  const supabase = createServerSupabase();
  const userIds = users.map((user) => user.id);
  const { data: subscriptionRows, error } = await supabase
    .from(TABLES.subscriptions)
    .select("*")
    .in("userId", userIds)
    .order("createdAt", { ascending: false });

  assertNoError(error);

  const subscriptions = (subscriptionRows ?? []) as SubscriptionRow[];
  const plansById = await getPlansById(subscriptions.map((subscription) => subscription.planId));
  const subscriptionsByUserId = new Map<number, Subscription[]>();

  for (const subscription of subscriptions) {
    const plan = plansById.get(subscription.planId);
    if (!plan) {
      continue;
    }

    const hydratedSubscription: Subscription = {
      ...subscription,
      plan,
      payments: [],
    };

    const current = subscriptionsByUserId.get(subscription.userId) ?? [];
    current.push(hydratedSubscription);
    subscriptionsByUserId.set(subscription.userId, current);
  }

  return users.map((user) => {
    const userSubscriptions = subscriptionsByUserId.get(user.id) ?? [];

    return {
      ...user,
      subscriptions: userSubscriptions,
      activeSubscription: selectActiveSubscription(userSubscriptions),
    };
  });
}

export async function requireAdminFromToken(token: string) {
  if (!token) {
    throw new Error("Token ausente.");
  }

  const supabase = createServerSupabase();
  const { data: authData, error: authError } = await supabase.auth.getUser(token);

  assertNoError(authError);

  const email = authData.user?.email;
  if (!email) {
    throw new Error("Sessao do Supabase nao encontrada.");
  }

  const { data, error } = await supabase
    .from(TABLES.users)
    .select("*")
    .eq("email", email)
    .maybeSingle();

  assertNoError(error);

  if (!data) {
    throw new Error("Usuario autenticado no Supabase, mas sem perfil cadastrado na tabela User.");
  }

  const [user] = await hydrateUsers([data as UserRow]);

  if (!isAdminRole(user.role)) {
    throw new Error("Acesso negado: Este portal e restrito a administradores e atendentes.");
  }

  return user;
}

export async function listUsers() {
  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.users)
    .select("*")
    .order("createdAt", { ascending: false });

  assertNoError(error);

  return hydrateUsers((data ?? []) as UserRow[]);
}

export async function getUserById(id: number) {
  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.users)
    .select("*")
    .eq("id", id)
    .maybeSingle();

  assertNoError(error);

  if (!data) {
    throw new Error("Usuario nao encontrado.");
  }

  const [user] = await hydrateUsers([data as UserRow]);
  return user;
}

export async function updateUser(id: number, payload: Partial<UserRow>) {
  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.users)
    .update({
      name: payload.name,
      email: payload.email,
      phone: payload.phone,
      companyPhone: payload.companyPhone,
      role: payload.role,
      isActive: payload.isActive,
      updatedAt: new Date().toISOString(),
    })
    .eq("id", id)
    .select()
    .single();

  assertNoError(error);

  const [user] = await hydrateUsers([data as UserRow]);
  return user;
}

export async function deleteUser(id: number) {
  const supabase = createServerSupabase();
  const { error } = await supabase.from(TABLES.users).delete().eq("id", id);
  assertNoError(error);

  return { ok: true };
}

export async function listPlans() {
  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.plans)
    .select("*")
    .order("priceCents", { ascending: true });

  assertNoError(error);

  return (data ?? []) as Plan[];
}

export async function createPlan(payload: Partial<Plan>) {
  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.plans)
    .insert({
      code: normalizePlanCode(payload.code),
      name: payload.name,
      description: payload.description,
      priceCents: payload.priceCents,
      durationDays: payload.durationDays,
      color: payload.color,
      isActive: payload.isActive,
      updatedAt: new Date().toISOString(),
    })
    .select()
    .single();

  assertNoError(error);

  return data as Plan;
}

export async function updatePlan(id: number, payload: Partial<Plan>) {
  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.plans)
    .update({
      code: normalizePlanCode(payload.code),
      name: payload.name,
      description: payload.description,
      priceCents: payload.priceCents,
      durationDays: payload.durationDays,
      color: payload.color,
      isActive: payload.isActive,
      updatedAt: new Date().toISOString(),
    })
    .eq("id", id)
    .select()
    .single();

  assertNoError(error);

  return data as Plan;
}

function normalizePlanCode(code: string | undefined) {
  return code?.trim().toLowerCase() ?? '';
}

function mapHelpVideo(row: HelpVideoRow): HelpVideo {
  return {
    id: row.id,
    title: row.title,
    description: row.description ?? "",
    videoUrl: row.video_url,
    youtubeVideoId: row.youtube_video_id,
    category: row.category ?? "",
    durationLabel: row.duration_label ?? "",
    thumbnailUrl: row.thumbnail_url ?? "",
    isFeatured: row.is_featured,
    isActive: row.is_active,
    sortOrder: row.sort_order,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function normalizeYouTubeVideoId(value: unknown) {
  const raw = String(value ?? "").trim();
  if (!raw) {
    return "";
  }

  try {
    const url = new URL(raw);
    if (url.hostname.includes("youtu.be")) {
      return url.pathname.replace("/", "").trim();
    }

    const watchId = url.searchParams.get("v");
    if (watchId) {
      return watchId.trim();
    }

    const segments = url.pathname.split("/").filter(Boolean);
    const embedIndex = segments.indexOf("embed");
    if (embedIndex >= 0 && segments[embedIndex + 1]) {
      return segments[embedIndex + 1].trim();
    }
  } catch {
    return raw;
  }

  return raw;
}

function buildHelpVideoPayload(payload: Partial<HelpVideo>) {
  const title = String(payload.title ?? "").trim();
  const description = String(payload.description ?? "").trim();
  const youtubeVideoId = normalizeYouTubeVideoId(payload.youtubeVideoId);
  const videoUrl =
    String(payload.videoUrl ?? "").trim() ||
    `https://www.youtube.com/watch?v=${youtubeVideoId}`;

  if (!title) {
    throw new Error("Informe o titulo do video.");
  }

  if (!description) {
    throw new Error("Informe a descricao do video.");
  }

  if (!youtubeVideoId) {
    throw new Error("Informe o ID ou link do YouTube.");
  }

  return {
    title,
    description,
    video_url: videoUrl,
    youtube_video_id: youtubeVideoId,
    category: String(payload.category ?? "").trim(),
    duration_label: String(payload.durationLabel ?? "").trim(),
    thumbnail_url: String(payload.thumbnailUrl ?? "").trim(),
    is_featured: Boolean(payload.isFeatured),
    is_active: payload.isActive ?? true,
    sort_order: Number(payload.sortOrder ?? 0),
    updated_at: new Date().toISOString(),
  };
}

export async function listHelpVideos() {
  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.helpVideos)
    .select("*")
    .order("sort_order", { ascending: true })
    .order("id", { ascending: true });

  assertNoError(error);

  return ((data ?? []) as HelpVideoRow[]).map(mapHelpVideo);
}

export async function createHelpVideo(payload: Partial<HelpVideo>) {
  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.helpVideos)
    .insert(buildHelpVideoPayload(payload))
    .select()
    .single();

  assertNoError(error);

  return mapHelpVideo(data as HelpVideoRow);
}

export async function updateHelpVideo(id: number, payload: Partial<HelpVideo>) {
  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.helpVideos)
    .update(buildHelpVideoPayload(payload))
    .eq("id", id)
    .select()
    .single();

  assertNoError(error);

  return mapHelpVideo(data as HelpVideoRow);
}

export async function deleteHelpVideo(id: number) {
  const supabase = createServerSupabase();
  const { error } = await supabase.from(TABLES.helpVideos).delete().eq("id", id);
  assertNoError(error);

  return { ok: true };
}

export async function deletePlan(id: number) {
  const supabase = createServerSupabase();
  const { error } = await supabase.from(TABLES.plans).delete().eq("id", id);
  assertNoError(error);

  return { ok: true };
}

export async function changePlan(userId: number, planId: number) {
  const now = new Date();
  const plansById = await getPlansById([planId]);
  const plan = plansById.get(planId);

  if (!plan) {
    throw new Error("Plano nao encontrado.");
  }

  const supabase = createServerSupabase();
  const cancelCurrent = await supabase
    .from(TABLES.subscriptions)
    .update({
      status: "CANCELED",
      canceledAt: now.toISOString(),
      updatedAt: now.toISOString(),
    })
    .eq("userId", userId)
    .in("status", ["ACTIVE", "TRIAL"]);

  assertNoError(cancelCurrent.error);

  const endDate = new Date(now);
  endDate.setDate(endDate.getDate() + plan.durationDays);

  const { data, error } = await supabase
    .from(TABLES.subscriptions)
    .insert({
      userId,
      planId,
      status: "ACTIVE",
      startDate: now.toISOString(),
      endDate: endDate.toISOString(),
      autoRenew: true,
      updatedAt: now.toISOString(),
    })
    .select()
    .single();

  assertNoError(error);

  return data;
}

export async function cancelSubscription(userId: number) {
  const now = new Date().toISOString();
  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.subscriptions)
    .update({
      status: "CANCELED",
      canceledAt: now,
      updatedAt: now,
    })
    .eq("userId", userId)
    .in("status", ["ACTIVE", "TRIAL"])
    .select();

  assertNoError(error);

  return data;
}

export async function renewSubscription(userId: number, autoRenew?: boolean) {
  const user = await getUserById(userId);
  const subscription = user.activeSubscription;

  if (!subscription) {
    throw new Error("Usuario sem assinatura ativa para renovar.");
  }

  const now = new Date();
  const endDate = new Date(now);
  endDate.setDate(endDate.getDate() + subscription.plan.durationDays);

  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.subscriptions)
    .update({
      status: "ACTIVE",
      startDate: now.toISOString(),
      endDate: endDate.toISOString(),
      autoRenew: autoRenew ?? subscription.autoRenew,
      updatedAt: now.toISOString(),
    })
    .eq("id", subscription.id)
    .select()
    .single();

  assertNoError(error);

  return data;
}

export async function getDashboard(): Promise<DashboardData> {
  const users = await listUsers();
  const dayAgo = new Date();
  dayAgo.setDate(dayAgo.getDate() - 1);

  const activeSubscribers = users.filter(
    (user) => user.isActive && user.activeSubscription?.status === "ACTIVE" && user.activeSubscription.plan,
  );

  const estimatedRevenue = activeSubscribers.reduce(
    (total, user) => total + (user.activeSubscription?.plan.priceCents ?? 0) / 100,
    0,
  );

  const plans = Object.values(
    activeSubscribers.reduce<Record<string, { name: string; count: number; revenue: number }>>((acc, user) => {
      const plan = user.activeSubscription?.plan;

      if (!plan) {
        return acc;
      }

      const current = acc[plan.code] ?? { name: plan.name, count: 0, revenue: 0 };
      current.count += 1;
      current.revenue += plan.priceCents / 100;
      acc[plan.code] = current;

      return acc;
    }, {}),
  );

  return {
    metrics: {
      totalUsers: users.length,
      activeUsers: users.filter((user) => user.isActive).length,
      newUsers24h: users.filter((user) => new Date(user.createdAt) >= dayAgo).length,
      estimatedRevenue,
    },
    plans,
    recentActivity: users.slice(0, 5).map((user) => ({
      id: `user-${user.id}`,
      action: "Cadastro de usuario",
      details: user.activeSubscription ? `Plano ${user.activeSubscription.plan.name}` : "Sem plano ativo",
      userName: user.name,
      createdAt: user.createdAt,
    })),
  };
}

export type CompanySettings = {
  id: number;
  supportPhone: string | null;
  googleApiKey: string | null;
  updatedAt?: string;
};

export async function getCompanySettings() {
  const supabase = createServerSupabase();

  const baseResult = await supabase
    .from(TABLES.company)
    .select("id,supportPhone,updatedAt")
    .eq("id", 1)
    .maybeSingle();

  assertNoError(baseResult.error);

  if (!baseResult.data) {
    return {
      id: 1,
      supportPhone: null,
      googleApiKey: null,
    } satisfies CompanySettings;
  }

  const googleApiResult = await supabase
    .from(TABLES.company)
    .select("googleApiKey")
    .eq("id", 1)
    .maybeSingle();

  if (isMissingGoogleApiKeyColumn(googleApiResult.error)) {
    return {
      ...(baseResult.data as Omit<CompanySettings, "googleApiKey">),
      googleApiKey: null,
    };
  }

  assertNoError(googleApiResult.error);

  return {
    ...(baseResult.data as Omit<CompanySettings, "googleApiKey">),
    googleApiKey: (googleApiResult.data as Pick<CompanySettings, "googleApiKey"> | null)?.googleApiKey ?? null,
  };
}

export async function updateCompanySettings(payload: Partial<CompanySettings>) {
  const supabase = createServerSupabase();
  const { data, error } = await supabase
    .from(TABLES.company)
    .upsert(
      {
        id: 1,
        googleApiKey: payload.googleApiKey,
        updatedAt: new Date().toISOString(),
      },
      { onConflict: "id" },
    )
    .select("id,supportPhone,googleApiKey,updatedAt")
    .single();

  if (isMissingGoogleApiKeyColumn(error)) {
    throw new Error("A coluna Company.googleApiKey ainda nao existe no Supabase. Aplique a migration em supabase/migrations/20260527172000_add_google_api_key_to_company.sql.");
  }

  assertNoError(error);
  return data as CompanySettings;
}
