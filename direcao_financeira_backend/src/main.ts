import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Segurança de Headers HTTP
  app.use(helmet());

  // Habilitar CORS
  app.enableCors();

  app.useGlobalFilters(new HttpExceptionFilter());

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Remove campos que não estão no DTO
      forbidNonWhitelisted: true, // Dá erro se enviarem campos extras
      transform: true, // Converte os tipos automaticamente (ex: string para number)
    }),
  );
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
