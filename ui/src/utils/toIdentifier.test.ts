import { toIdentifier } from './toIdentifier';

test('toIdentifier', () => {
  const expected = 'action-adventure';
  const actual = toIdentifier('Action & Adventure');
  expect(actual).toBe(expected);
});
