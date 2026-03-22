import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import type { JwtSignOptions } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UserModule } from '../../user/interface/user.module';
import { JwtStrategy } from './strategies/jwt.strategy';
import {
  GetAuthenticatedProfileUseCase,
  LoginUseCase,
  RegisterUseCase,
} from '../application/use-cases/auth.use-cases';
import { PASSWORD_HASHER } from '../domain/services/password-hasher';
import { TOKEN_SERVICE } from '../domain/services/token-service';
import { BcryptPasswordHasherService } from '../infrastructure/services/bcrypt-password-hasher.service';
import { NestJwtTokenService } from '../infrastructure/services/nest-jwt-token.service';

@Module({
  imports: [
    UserModule,
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'fallback_secret_not_for_prod',
      signOptions: {
        expiresIn: (process.env.JWT_EXPIRES_IN ||
          '1d') as JwtSignOptions['expiresIn'],
      },
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtStrategy,
    RegisterUseCase,
    LoginUseCase,
    GetAuthenticatedProfileUseCase,
    BcryptPasswordHasherService,
    NestJwtTokenService,
    {
      provide: PASSWORD_HASHER,
      useExisting: BcryptPasswordHasherService,
    },
    {
      provide: TOKEN_SERVICE,
      useExisting: NestJwtTokenService,
    },
  ],
  exports: [AuthService],
})
export class AuthModule {}
