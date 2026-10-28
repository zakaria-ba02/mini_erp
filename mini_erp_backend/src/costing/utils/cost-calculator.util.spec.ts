import { calculateCostFields } from './cost-calculator.util';

describe('calculateCostFields', () => {
  it('calculates per-unit first, then batch totals (owner example)', () => {
    const result = calculateCostFields({
      runtime: 36,
      hourlyRate: 360,
      boardPrice: 50000,
      quantity: 10,
      wastePercentage: 0,
      profitPercentage: 0,
      additionalCosts: [{ name: 'اكسسورات', price: 5000 }],
    });

    expect(result.woodCostPerUnit).toBe(5000);
    expect(result.laserCostPerUnit).toBe(12960);
    expect(result.additionalCostsTotal).toBe(5000);
    expect(result.baseCostPerUnit).toBe(22960);
    expect(result.wasteCostPerUnit).toBe(0);
    expect(result.costPerUnit).toBe(22960);
    expect(result.profitPerUnit).toBe(0);
    expect(result.sellingPricePerUnit).toBe(22960);
    expect(result.operatingCost).toBe(129600);
    expect(result.wasteCost).toBe(0);
    expect(result.totalCost).toBe(229600);
    expect(result.profit).toBe(0);
    expect(result.sellingPrice).toBe(229600);
  });

  it('applies waste and profit on the per-unit base, then scales the batch', () => {
    const result = calculateCostFields({
      runtime: 2,
      hourlyRate: 50,
      boardPrice: 100,
      quantity: 10,
      wastePercentage: 10,
      profitPercentage: 20,
      additionalCosts: [{ name: 'Glue', price: 30 }],
    });

    expect(result.woodCostPerUnit).toBe(10);
    expect(result.laserCostPerUnit).toBe(100);
    expect(result.additionalCostsTotal).toBe(30);
    expect(result.baseCostPerUnit).toBe(140);
    expect(result.wasteCostPerUnit).toBe(14);
    expect(result.costPerUnit).toBe(154);
    expect(result.profitPerUnit).toBeCloseTo(30.8, 5);
    expect(result.sellingPricePerUnit).toBeCloseTo(184.8, 5);
    expect(result.operatingCost).toBe(1000);
    expect(result.wasteCost).toBe(140);
    expect(result.totalCost).toBe(1540);
    expect(result.profit).toBeCloseTo(308, 5);
    expect(result.sellingPrice).toBeCloseTo(1848, 5);
  });
});
