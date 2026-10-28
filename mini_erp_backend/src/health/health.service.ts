import { Injectable } from '@nestjs/common';
import { InjectConnection } from '@nestjs/mongoose';
import { Connection } from 'mongoose';

@Injectable()
export class HealthService {
  constructor(@InjectConnection() private readonly connection: Connection) {}

  check() {
    const mongoState = this.connection.readyState;
    const mongoStatus =
      mongoState === 1 ? 'connected' : mongoState === 2 ? 'connecting' : 'disconnected';

    return {
      status: mongoState === 1 ? 'ok' : 'degraded',
      mongo: mongoStatus,
      timestamp: new Date().toISOString(),
    };
  }
}
