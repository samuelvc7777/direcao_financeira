import { SubscriptionStatus } from '@prisma/client';
import { CreateUserDto } from '../../interface/dto/create-user.dto';
import { UpdateUserDto } from '../../interface/dto/update-user.dto';

export const USER_REPOSITORY = 'USER_REPOSITORY';

export interface UserSubscriptionSnapshot {
  id: number;
  userId: number;
  planId: number;
  status: SubscriptionStatus;
  startDate: Date;
  endDate: Date | null;
  canceledAt: Date | null;
  autoRenew: boolean;
  createdAt: Date;
  updatedAt: Date;
  plan: {
    id: number;
    code: string;
    name: string;
    description: string;
    priceCents: number;
    durationDays: number;
    color: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  };
}

export interface UserWithSubscriptions {
  id: number;
  name: string;
  email: string;
  password?: string;
  role: 'USER' | 'ADMIN' | 'ATTENDANT';
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  subscriptions: UserSubscriptionSnapshot[];
}

export interface UserRepository {
  create(data: CreateUserDto & { password: string }): Promise<UserWithSubscriptions>;
  findAll(): Promise<UserWithSubscriptions[]>;
  findById(id: number): Promise<UserWithSubscriptions | null>;
  findByEmail(email: string): Promise<UserWithSubscriptions | null>;
  update(id: number, data: Omit<UpdateUserDto, 'planId'>): Promise<UserWithSubscriptions>;
  remove(id: number): Promise<void>;
  findDefaultActivePlanId(): Promise<number | null>;
}
