export interface SettlementTotalsInput {
  invoices: Array<{ total: number }>;
  payments: Array<{ amount: number }>;
}

export interface SettlementTotals {
  totalInvoices: number;
  totalPayments: number;
  balanceAtSettlement: number;
}

export function computeSettlementTotals(
  input: SettlementTotalsInput,
): SettlementTotals {
  const totalInvoices = input.invoices.reduce(
    (sum, invoice) => sum + invoice.total,
    0,
  );
  const totalPayments = input.payments.reduce(
    (sum, payment) => sum + payment.amount,
    0,
  );

  return {
    totalInvoices,
    totalPayments,
    balanceAtSettlement: totalInvoices - totalPayments,
  };
}

export function balancesMatch(
  computed: number,
  stored: number,
  epsilon = 0.01,
): boolean {
  return Math.abs(computed - stored) <= epsilon;
}
