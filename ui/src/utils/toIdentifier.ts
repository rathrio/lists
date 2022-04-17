/**
 * "Action & Adventure" -> "action-adventure"
 */
export const toIdentifier = (value: string): string => {
  return value
    .trim()
    .replace(/[\W_]+/g, '-')
    .toLowerCase();
};
