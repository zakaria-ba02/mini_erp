import { computeSettlementTotals, balancesMatch } from './settlement-totals.util';

describe('computeSettlementTotals', () => {
  it('sums unsettled invoices and payments into the closing balance', () => {
    const result = computeSettlementTotals({
      invoices: [{ total: 1000 }, { total: 250 }],
      payments: [{ amount: 400 }, { amount: 50 }],
    });

    expect(result.totalInvoices).toBe(1250);
    expect(result.totalPayments).toBe(450);
    expect(result.balanceAtSettlement).toBe(800);
  });

  it('allows a non-zero closing balance', () => {
    const result = computeSettlementTotals({
      invoices: [{ total: 500 }],
      payments: [],
    });

    expect(result.balanceAtSettlement).toBe(500);
    expect(balancesMatch(result.balanceAtSettlement, 500)).toBe(true);
  });
});
