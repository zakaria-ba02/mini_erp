import { Types } from 'mongoose';
import { Currency } from '../constants/currency';

export function unsettledDocumentsFilter(
  customerId: Types.ObjectId,
  currency: Currency,
) {
  const currencyMatch =
    currency === Currency.SYP
      ? {
          $or: [
            { currency: Currency.SYP },
            { currency: { $exists: false } },
            { currency: null },
          ],
        }
      : { currency };

  return {
    customerId,
    settlementId: null,
    ...currencyMatch,
  };
}
