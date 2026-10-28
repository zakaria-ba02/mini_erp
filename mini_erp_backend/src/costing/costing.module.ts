import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Cost, CostSchema } from '../database/schemas/cost.schema';
import { CostingService } from './costing.service';
import { CostingController } from './costing.controller';
import { AuditLogsModule } from '../audit-logs/audit-logs.module';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Cost.name, schema: CostSchema }]),
    AuditLogsModule,
    UsersModule,
  ],
  controllers: [CostingController],
  providers: [CostingService],
  exports: [CostingService, MongooseModule],
})
export class CostingModule {}
