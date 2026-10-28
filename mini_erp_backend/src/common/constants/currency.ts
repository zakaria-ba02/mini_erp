export enum Currency {
  SYP = 'SYP',
  USD = 'USD',
}

export function resolveCurrency(value: unknown): Currency {
  return value === Currency.USD ? Currency.USD : Currency.SYP;
}
