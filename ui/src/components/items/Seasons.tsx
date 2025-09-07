import React from 'react';
import { observer } from 'mobx-react';
import { Item } from '../../interfaces';

interface Props {
  item: Item;
}

const Seasons = observer((props: React.PropsWithChildren<Props>) => {
  const item = props.item;
  if (!item.seasons?.length) {
    return null;
  }

  return (
    <table className="table is-narrow is-fullwidth mt-5">
      <thead>
        <tr>
          <th>Season</th>
          <th>Air date</th>
          <th> Episode count</th>
        </tr>
      </thead>
      <tbody>
        {item.seasons?.map((season, index) => (
          <tr key={index}>
            <td>{season.name}</td>
            <td>{season.air_date}</td>
            <td>{season.episode_count}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
});

export default Seasons;
