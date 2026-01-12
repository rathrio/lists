import { observer } from 'mobx-react';
import { useVirtualizer } from '@tanstack/react-virtual';
import { useRef, useState, useLayoutEffect } from 'react';

import { Item, ItemStatus } from '../../interfaces';
import { statusTagClassName } from './ItemDetails';
import RootStore from '../../stores/RootStore';
import CoverBox from './CoverBox';
import { publicAssetsUrl } from '../../utils/api';
import PlaceholderGrid from './PlaceholderGrid';

interface Props {
  store: RootStore;
}

interface ItemGroup {
  label: string;
  items: Item[];
}

function groupItemsByMonth(items: Item[]): ItemGroup[] {
  const groups = new Map<string, Item[]>();

  items.forEach((item) => {
    if (!item.first_done_at) return;

    const date = new Date(item.first_done_at);
    const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;

    if (!groups.has(key)) {
      groups.set(key, []);
    }
    groups.get(key)!.push(item);
  });

  return Array.from(groups.entries())
    .sort((a, b) => b[0].localeCompare(a[0]))
    .map(([_, items]) => ({
      label: new Date(items[0].first_done_at!).toLocaleString('default', {
        month: 'long',
        year: 'numeric',
      }),
      items,
    }));
}

function GroupHeader(props: { label: string }) {
  return (
    <div
      style={{
        padding: '1rem 0 0.5rem 0',
        fontSize: '1.5rem',
        fontWeight: 'bold',
        borderBottom: '1px solid #dbdbdb',
        marginBottom: '1rem',
      }}
    >
      {props.label}
    </div>
  );
}

function renderStar(currentRating: number, n: number) {
  const starIcon = n <= currentRating ? 'fas fa-star' : 'far fa-star';
  const className = `${starIcon} fa-sm item-rating-star`;

  return (
    <span key={n}>
      <i className={className} />
    </span>
  );
}

const DEFAULT_RATINGS = [1, 2, 3, 4, 5];

function ItemRating(props: { item: Item }) {
  const { item } = props;
  if (!item.rating) {
    return null;
  }

  const stars = DEFAULT_RATINGS.map((r) => renderStar(item.rating!, r));
  return <div className="item-rating">{stars}</div>;
}

const ItemBox = observer((props: { item: Item; store: RootStore }) => {
  const { item, store } = props;
  const itemStore = store.itemStore;

  function onItemClick(item: Item) {
    itemStore.focusItem(item);
    itemStore.showItemDetails(item);
  }

  const thumbUrl = item.image?.url ?? '';
  const coverAspectRatio = store.listStore.activeList!.cover_aspect_ratio;

  return (
    <CoverBox
      coverUrl={publicAssetsUrl(thumbUrl)}
      isCoverMissing={!thumbUrl}
      title={item.name}
      coverAspectRatio={coverAspectRatio}
      isFocused={itemStore.isFocused(item)}
      onClick={() => onItemClick(item)}
      tag={item.status !== ItemStatus.Todo ? item.human_status : undefined}
      tagClass={statusTagClassName(item.status)}
    >
      <p>{item.year}</p>
      <ItemRating item={item} />
    </CoverBox>
  );
});

// Calculate columns based on viewport width (matching CSS media queries).
// Should be kept in sync with .items-grid config in css. The css version is
// used for the scraper results and this for the virtualized grid. I should
// probably consolidate this at some point.
function getColumnCount(width: number): number {
  if (width >= 1250) return 9;
  if (width >= 1050) return 8;
  if (width >= 950) return 7;
  if (width >= 750) return 6;
  if (width >= 650) return 5;
  if (width >= 450) return 4;
  return 3;
}

function ItemGrid(props: Props) {
  const { store } = props;
  const parentRef = useRef<HTMLDivElement>(null);

  const [columnCount, setColumnCount] = useState(() =>
    getColumnCount(window.innerWidth)
  );

  const items = store.itemStore.filteredItems;
  const isJournal = store.listStore.activeList?.name === 'Journal';
  const itemGroups = isJournal ? groupItemsByMonth(items) : null;

  // Update column count on resize
  useLayoutEffect(() => {
    const element = parentRef.current;
    if (!element) {
      return;
    }

    const updateColumnCount = () => {
      if (parentRef.current) {
        const width = parentRef.current.offsetWidth;
        const newColumnCount = getColumnCount(width);
        setColumnCount(newColumnCount);
      }
    };

    // Initial calculation
    updateColumnCount();

    // Listen for resize
    const resizeObserver = new ResizeObserver(updateColumnCount);
    resizeObserver.observe(element);

    return () => {
      resizeObserver.disconnect();
    };
  }, [store.itemStore.isLoading]);

  // Calculate rows needed for virtual grid
  const rowCount = Math.ceil(items.length / columnCount);

  const rowVirtualizer = useVirtualizer({
    count: rowCount,
    getScrollElement: () =>
      typeof window !== 'undefined' ? window.document.body : null,
    estimateSize: () => 240, // Row height (cover + info + gap)
    overscan: 8,
    measureElement: (element) => element.getBoundingClientRect().height,
  });

  if (store.itemStore.isLoading) {
    const coverAspectRatio =
      store.listStore.activeList?.cover_aspect_ratio || '2by3';
    const placeholderCount = 36;

    return (
      <PlaceholderGrid
        aspectRatio={coverAspectRatio}
        numBoxes={placeholderCount}
      />
    );
  }

  // Render grouped view for Journal
  if (isJournal && itemGroups) {
    return (
      <div ref={parentRef}>
        {itemGroups.map((group) => (
          <div key={group.label} style={{ marginBottom: '2rem' }}>
            <GroupHeader label={group.label} />
            <div
              className="items-grid"
              style={{
                gridTemplateColumns: `repeat(${columnCount}, 1fr)`,
              }}
            >
              {group.items.map((item) => (
                <ItemBox item={item} store={store} key={item.id} />
              ))}
            </div>
          </div>
        ))}
      </div>
    );
  }

  return (
    <div ref={parentRef}>
      <div
        style={{
          height: `${rowVirtualizer.getTotalSize()}px`,
          width: '100%',
          position: 'relative',
        }}
      >
        {rowVirtualizer.getVirtualItems().map((virtualRow) => {
          const startIndex = virtualRow.index * columnCount;
          const rowItems = items.slice(startIndex, startIndex + columnCount);

          return (
            <div
              key={virtualRow.key}
              data-index={virtualRow.index}
              ref={rowVirtualizer.measureElement}
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: '100%',
                transform: `translateY(${virtualRow.start}px)`,
                paddingBottom: '0.8rem', // Gap between rows
              }}
            >
              <div
                className="items-grid"
                style={{
                  gridTemplateColumns: `repeat(${columnCount}, 1fr)`,
                }}
              >
                {rowItems.map((item, idx) => (
                  <ItemBox
                    item={item}
                    store={store}
                    key={`${virtualRow.index}-${idx}`}
                  />
                ))}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

export default observer(ItemGrid);
