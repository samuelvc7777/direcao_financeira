import { createClient } from "@supabase/supabase-js";

import type { Plan, Subscription, User } from "@/lib/subscriptions";

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

const TABLES = {
  users: "User",
  plans: "Plan",
  subscriptions: "Subscription",
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
      code: payload.code,
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
      code: payload.code,
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
