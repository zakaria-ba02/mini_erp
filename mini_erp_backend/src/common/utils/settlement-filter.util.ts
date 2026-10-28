import { HttpStatus } from '@nestjs/common';
import { Types } from 'mongoose';
import { ErrorCode } from '../constants/error-codes';
import { BusinessException } from '../exceptions/business.exception';

export function settlementIdQuery(
  settlementId?: string,
): Types.ObjectId | null {
  return settlementId ? new Types.ObjectId(settlementId) : null;
}

export function assertDocumentUnsettled(
  settlementId: Types.ObjectId | null | undefined,
): void {
  if (settlementId) {
    throw new BusinessException(
      ErrorCode.SETTLED_DOCUMENT_LOCKED,
      'Settled invoices and payments cannot be modified',
      HttpStatus.CONFLICT,
    );
  }
}
