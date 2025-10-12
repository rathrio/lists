import { CoverAspectRatio } from '../../interfaces';
import CoverBox from './CoverBox';

interface Props {
  aspectRatio: CoverAspectRatio;
  numBoxes: number;
}

export default function PlaceholderGrid(props: Props) {
  const placeholders = [...Array(props.numBoxes)].map((_, i) => (
    <CoverBox
      key={`placeholder-${i}`}
      coverUrl={''}
      isCoverMissing={true}
      title={''}
      coverAspectRatio={props.aspectRatio}
      disablePointer={true}
      onClick={() => {}}
      className={`i${i % 9}`}
    >
      <p>&nbsp;</p>
    </CoverBox>
  ));

  return <div className="items-grid placeholder-grid">{placeholders}</div>;
}
