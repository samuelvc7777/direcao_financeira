import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

interface HttpExceptionResponseBody {
  error?: string;
  message?: string | string[];
}

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const message =
      exception instanceof HttpException
        ? exception.getResponse()
        : (exception as Error).message || 'Internal server error';
    const normalizedMessage =
      typeof message === 'string'
        ? message
        : (message as HttpExceptionResponseBody);

    const errorResponse = {
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      method: request.method,
      error:
        typeof normalizedMessage === 'string'
          ? normalizedMessage
          : normalizedMessage.error || 'Error',
      message:
        typeof normalizedMessage === 'string'
          ? normalizedMessage
          : normalizedMessage.message || normalizedMessage,
    };

    // Log detalhado no terminal para o desenvolvedor
    if (status === HttpStatus.INTERNAL_SERVER_ERROR) {
      this.logger.error(
        `${request.method} ${request.url}`,
        (exception as Error).stack,
      );
    } else {
      this.logger.warn(
        `${request.method} ${request.url} - Status: ${status} - Message: ${JSON.stringify(message)}`,
      );
    }

    response.status(status).json(errorResponse);
  }
}
