export const TOKEN_SERVICE = 'TOKEN_SERVICE';

export interface AuthTokenPayload {
  sub: number;
  email: string;
  role: string;
  name: string;
}

export interface TokenService {
  sign(payload: AuthTokenPayload): string;
}
