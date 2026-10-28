export function escapeRegex(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export function buildSearchRegex(search?: string): RegExp | undefined {
  if (!search?.trim()) {
    return undefined;
  }
  return new RegExp(escapeRegex(search.trim()), 'i');
}
