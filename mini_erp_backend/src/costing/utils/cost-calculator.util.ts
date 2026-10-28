import { AdditionalCostDto } from '../dto/create-cost.dto';

export interface CostCalculationInput {
  runtime: number;
  hourlyRate: number;
  boardPrice: number;
  quantity: number;
  wastePercentage: number;
  profitPercentage: number;
  additionalCosts?: AdditionalCostDto[];
}

export interface CostCalculationResult {
  woodCostPerUnit: number;
  laserCostPerUnit: number;
  additionalCostsTotal: number;
  baseCostPerUnit: number;
  wasteCostPerUnit: number;
  costPerUnit: number;
  profitPerUnit: number;
  sellingPricePerUnit: number;
  operatingCost: number;
  wasteCost: number;
  totalCost: number;
  profit: number;
  sellingPrice: number;
}

/**
 * Unit-first costing:
 * woodCostPerUnit = boardPrice / quantity
 * laserCostPerUnit = runtime * hourlyRate  (per piece, not divided)
 * additionalCostsTotal = sum of additionalCosts prices (per piece, not divided)
 * costPerUnit is the primary result; batch totals are derived by multiplying by quantity.
 */
export function calculateCostFields(
  input: CostCalculationInput,
): CostCalculationResult {
  const additionalCosts = input.additionalCosts ?? [];
  const additionalCostsTotal = additionalCosts.reduce(
    (sum, item) => sum + item.price,
    0,
  );

  const woodCostPerUnit = input.boardPrice / input.quantity;
  const laserCostPerUnit = input.runtime * input.hourlyRate;
  const baseCostPerUnit =
    woodCostPerUnit + laserCostPerUnit + additionalCostsTotal;
  const wasteCostPerUnit = (baseCostPerUnit * input.wastePercentage) / 100;
  const costPerUnit = baseCostPerUnit + wasteCostPerUnit;
  const profitPerUnit = (costPerUnit * input.profitPercentage) / 100;
  const sellingPricePerUnit = costPerUnit + profitPerUnit;

  return {
    woodCostPerUnit,
    laserCostPerUnit,
    additionalCostsTotal,
    baseCostPerUnit,
    wasteCostPerUnit,
    costPerUnit,
    profitPerUnit,
    sellingPricePerUnit,
    operatingCost: laserCostPerUnit * input.quantity,
    wasteCost: wasteCostPerUnit * input.quantity,
    totalCost: costPerUnit * input.quantity,
    profit: profitPerUnit * input.quantity,
    sellingPrice: sellingPricePerUnit * input.quantity,
  };
}
