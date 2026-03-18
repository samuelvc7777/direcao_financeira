export const PASSWORD_HASHER = 'PASSWORD_HASHER';

export interface PasswordHasher {
  hash(value: string): Promise<string>;
  compare(value: string, hashedValue: string): Promise<boolean>;
}
