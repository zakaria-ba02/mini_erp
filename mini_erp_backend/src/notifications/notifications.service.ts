import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { cert, initializeApp, App } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';
import { UsersService } from '../users/users.service';

const PEM_BEGIN = '-----BEGIN PRIVATE KEY-----';
const PEM_END = '-----END PRIVATE KEY-----';

@Injectable()
export class NotificationsService implements OnModuleInit {
  private readonly logger = new Logger(NotificationsService.name);
  private firebaseApp: App | null = null;

  constructor(
    private readonly configService: ConfigService,
    private readonly usersService: UsersService,
  ) {}

  onModuleInit(): void {
    const projectId = this.configService.get<string>('firebase.projectId')?.trim();
    const clientEmail =
      this.configService.get<string>('firebase.clientEmail')?.trim();
    const privateKey = this.configService.get<string>('firebase.privateKey') ?? '';

    if (!projectId || !clientEmail || !privateKey) {
      this.logger.warn(
        'Firebase credentials not configured. Push notifications disabled.',
      );
      return;
    }

    if (!this.isValidPemPrivateKey(privateKey)) {
      this.logger.warn(
        'Firebase private key is invalid (expected PEM with BEGIN/END PRIVATE KEY markers). Push notifications disabled.',
      );
      return;
    }

    try {
      this.firebaseApp = initializeApp({
        credential: cert({
          projectId,
          clientEmail,
          privateKey,
        }),
      });
      this.logger.log('Firebase Admin SDK initialized.');
    } catch (error) {
      this.logger.warn(
        `Firebase initialization failed: ${error instanceof Error ? error.message : String(error)}. Push notifications disabled.`,
      );
    }
  }

  private isValidPemPrivateKey(key: string): boolean {
    return key.includes(PEM_BEGIN) && key.includes(PEM_END);
  }

  async sendToCustomer(
    customerId: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<void> {
    if (!this.firebaseApp) {
      return;
    }

    const user = await this.usersService.findByCustomerId(customerId);
    if (!user?.fcmToken) {
      return;
    }

    try {
      await getMessaging(this.firebaseApp).send({
        token: user.fcmToken,
        notification: { title, body },
        data,
      });
    } catch (error) {
      this.logger.warn(
        `Failed to send FCM to customer ${customerId}: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }
}
