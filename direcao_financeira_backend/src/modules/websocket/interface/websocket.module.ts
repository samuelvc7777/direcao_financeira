import { Global, Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AppGateway } from './app.gateway';

@Global()
@Module({
  imports: [
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'fallback_secret_not_for_prod',
    }),
  ],
  providers: [AppGateway],
  exports: [AppGateway],
})
export class WebsocketModule {}
