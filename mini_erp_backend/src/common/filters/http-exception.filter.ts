import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Response } from 'express';
import { ErrorCode } from '../constants/error-codes';

interface ErrorResponseBody {
  statusCode: number;
  errorCode: string;
  message: string;
}

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const context = host.switchToHttp();
    const response = context.getResponse<Response>();
    const statusCode = this.resolveStatusCode(exception);
    const { errorCode, message } = this.resolveErrorDetails(
      exception,
      statusCode,
    );

    if (statusCode >= 500) {
      this.logger.error(
        exception instanceof Error ? exception.stack : String(exception),
      );
    }

    const responseBody: ErrorResponseBody = {
      statusCode,
      errorCode,
      message,
    };

    response.status(statusCode).json(responseBody);
  }

  private resolveStatusCode(exception: unknown): number {
    if (exception instanceof HttpException) {
      return exception.getStatus();
    }
    return HttpStatus.INTERNAL_SERVER_ERROR;
  }

  private resolveErrorDetails(
    exception: unknown,
    statusCode: number,
  ): { errorCode: string; message: string } {
    if (!(exception instanceof HttpException)) {
      return {
        errorCode: ErrorCode.INTERNAL_SERVER_ERROR,
        message: 'Internal server error',
      };
    }

    const exceptionResponse = exception.getResponse();

    if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
      const body = exceptionResponse as Record<string, unknown>;

      if (typeof body.errorCode === 'string') {
        return {
          errorCode: body.errorCode,
          message:
            typeof body.message === 'string'
              ? body.message
              : this.extractValidationMessage(body.message) ??
                exception.message,
        };
      }

      if (typeof body.code === 'string') {
        return {
          errorCode: body.code,
          message:
            typeof body.message === 'string'
              ? body.message
              : exception.message,
        };
      }

      if (Array.isArray(body.message)) {
        return {
          errorCode: ErrorCode.VALIDATION_ERROR,
          message: this.extractValidationMessage(body.message) ?? 'Validation failed',
        };
      }

      if (typeof body.message === 'string') {
        return {
          errorCode: this.mapStatusToErrorCode(statusCode),
          message: body.message,
        };
      }
    }

    if (typeof exceptionResponse === 'string') {
      return {
        errorCode: this.mapStatusToErrorCode(statusCode),
        message: exceptionResponse,
      };
    }

    return {
      errorCode: this.mapStatusToErrorCode(statusCode),
      message: exception.message,
    };
  }

  private extractValidationMessage(message: unknown): string | undefined {
    if (typeof message === 'string') {
      return message;
    }
    if (Array.isArray(message)) {
      return message.map(String).join('; ');
    }
    return undefined;
  }

  private mapStatusToErrorCode(statusCode: number): ErrorCode {
    switch (statusCode) {
      case HttpStatus.UNAUTHORIZED:
        return ErrorCode.UNAUTHORIZED;
      case HttpStatus.FORBIDDEN:
        return ErrorCode.FORBIDDEN;
      case HttpStatus.BAD_REQUEST:
        return ErrorCode.VALIDATION_ERROR;
      default:
        return ErrorCode.INTERNAL_SERVER_ERROR;
    }
  }
}
