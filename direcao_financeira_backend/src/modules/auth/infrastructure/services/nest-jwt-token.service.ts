import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import {
  AuthTokenPayload,
  TokenService,
} from '../../domain/services/token-service';

@Injectable()
export class NestJwtTokenService implements TokenService {
  constructor(private readonly jwtService: JwtService) {}

  sign(payload: AuthTokenPayload) {
    return this.jwtService.sign(payload);
  }
}
