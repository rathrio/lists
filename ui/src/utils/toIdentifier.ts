/**
 * "Action & Adventure" -> "action-adventure"
 *
 * "Joland Rohner" -> "joland-rohner"
 */
export const toIdentifier = (value: string): string => {
  return value
    .trim()
    .replace(/[\W_]+/g, '-')
    .toLowerCase();
};
