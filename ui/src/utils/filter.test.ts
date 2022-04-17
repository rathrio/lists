import { buildQuery } from './filter';

test('buildQuery without filters', () => {
  const query = buildQuery('foobar');
  expect(query.filterValues.length).toBe(0);
  expect(query.query).toBe('foobar');
});

test('buildQuery with filters', () => {
  const query = buildQuery('foobar year=2012');
  const expected = [{ filter: 'year', value: '2012' }];
  expect(query.filterValues).toEqual(expected);
  expect(query.query).toBe('foobar');
});
