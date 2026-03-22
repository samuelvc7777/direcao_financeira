import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { JwtService } from '@nestjs/jwt';
import { Injectable, Logger } from '@nestjs/common';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
@Injectable()
export class AppGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(AppGateway.name);

  constructor(private readonly jwtService: JwtService) {}

  async handleConnection(client: Socket) {
    try {
      const token =
        this.extractTokenFromHeader(client) || client.handshake.auth.token;

      if (!token) {
        this.logger.warn(`Client disconnected (No token): ${client.id}`);
        client.disconnect();
        return;
      }

      const payload = await this.jwtService.verifyAsync(token, {
        secret: process.env.JWT_SECRET || 'fallback_secret_not_for_prod',
      });

      const userId = payload.sub;

      // Join a specific room for this user
      const room = `user_${userId}`;
      client.join(room);

      this.logger.log(`Client connected: ${client.id} - Joined room: ${room}`);

      // Optionally emit a welcome event
      client.emit('connection_success', { status: 'connected', userId });
    } catch (error) {
      this.logger.error(`Client disconnected (Invalid token): ${client.id}`);
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
  }

  // Example Ping/Pong handler for health check
  @SubscribeMessage('ping')
  handlePing(@ConnectedSocket() client: Socket): void {
    client.emit('pong', { timestamp: new Date().toISOString() });
  }

  // Helper to extract Bearer token
  private extractTokenFromHeader(client: Socket): string | undefined {
    const authHeader = client.handshake.headers.authorization;
    if (!authHeader) return undefined;
    const [type, token] = authHeader.split(' ');
    return type === 'Bearer' ? token : undefined;
  }

  // Method to emit events to a specific user
  emitToUser(userId: number, event: string, payload: any) {
    const room = `user_${userId}`;
    this.server.to(room).emit(event, payload);
  }
}
