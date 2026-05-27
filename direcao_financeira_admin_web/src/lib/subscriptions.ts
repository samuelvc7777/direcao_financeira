export interface Plan {
  id: number;
  code: string;
  name: string;
  description: string | null;
  priceCents: number;
  durationDays: number;
  color: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  _count?: {
    users?: number;
  };
}

export interface Subscription {
  id: number;
  status: string;
  startDate: string;
  endDate: string;
  canceledAt: string | null;
  autoRenew: boolean;
  createdAt: string;
  updatedAt: string;
  plan: Plan;
  payments?: unknown[];
}

export interface User {
  id: number;
  name: string;
  email: string;
  phone?: string | null;
  companyPhone?: string | null;
  role: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  activeSubscription: Subscription | null;
  subscriptions: Subscription[];
}

export interface HelpVideo {
  id: number;
  title: string;
  description: string;
  videoUrl: string;
  youtubeVideoId: string;
  category: string;
  durationLabel: string;
  thumbnailUrl: string;
  isFeatured: boolean;
  isActive: boolean;
  sortOrder: number;
  createdAt: string;
  updatedAt: string;
}

export interface RoleOption {
  id: string;
  name: string;
}

export interface UserListItem extends User {
  roleLabel: RoleOption;
  activePlan: Plan | null;
  subscriptionStatus: string | null;
}

export function formatCurrencyFromCents(value: number): string {
  return (value / 100).toLocaleString("pt-BR", {
    style: "currency",
    currency: "BRL",
  });
}

export function convertReaisToCents(value: number | string): number {
  const normalized =
    typeof value === "number"
      ? value
      : Number(String(value).replace(",", ".").trim() || 0);

  return Math.round(normalized * 100);
}

export function convertCentsToReais(value: number): number {
  return value / 100;
}

export function getUserActivePlan(user: Pick<User, "activeSubscription">): Plan | null {
  return user.activeSubscription?.plan ?? null;
}

export function mapUserToListItem(user: User): UserListItem {
  return {
    ...user,
    roleLabel: {
      id: user.role,
      name: user.role,
    },
    activePlan: getUserActivePlan(user),
    subscriptionStatus: user.activeSubscription?.status ?? null,
  };
}
