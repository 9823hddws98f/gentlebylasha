"use client";

import {
  type Announcements,
  closestCenter,
  DndContext,
  type DragEndEvent,
  KeyboardSensor,
  type Modifier,
  PointerSensor,
  type UniqueIdentifier,
  useSensor,
  useSensors,
} from "@dnd-kit/core";
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  useSortable,
  verticalListSortingStrategy,
} from "@dnd-kit/sortable";
import { GripVertical } from "lucide-react";
import {
  createContext,
  type CSSProperties,
  type ReactNode,
  useContext,
  useEffect,
  useId,
  useMemo,
  useRef,
  useState,
  useSyncExternalStore,
} from "react";

// Drag-and-drop reordering for the admin's ordered lists. Rows move by their
// grip with mouse or touch; the grip also works from the keyboard (space to
// pick up, arrows to move, space to drop, Escape to cancel), with every step
// announced to screen readers in Dutch.

const REDUCED_MOTION = "(prefers-reduced-motion: reduce)";

function useReducedMotion() {
  return useSyncExternalStore(
    (onChange) => {
      const media = matchMedia(REDUCED_MOTION);
      media.addEventListener("change", onChange);
      return () => media.removeEventListener("change", onChange);
    },
    () => matchMedia(REDUCED_MOTION).matches,
    () => false,
  );
}

/** Keeps the dragged row on the list's vertical axis and inside the list. */
const alongList: Modifier = ({ transform, draggingNodeRect: row, containerNodeRect: list }) => {
  if (!row || !list) return { ...transform, x: 0 };
  const y = Math.min(Math.max(transform.y, list.top - row.top), list.bottom - row.bottom);
  return { ...transform, x: 0, y };
};

const instructions = {
  draggable:
    "Druk op spatie of Enter om dit item op te pakken. Verplaats het met de pijltjestoetsen. " +
    "Druk nogmaals op spatie of Enter om het neer te zetten, of op Escape om te annuleren.",
};

interface ListState {
  label: (id: string) => string;
  /** False: the list shows no grips at all. */
  enabled: boolean;
  /** False while there is nothing to reorder (fewer than two rows). */
  canMove: boolean;
  reduceMotion: boolean;
}

const ListContext = createContext<ListState>({ label: String, enabled: false, canMove: false, reduceMotion: false });

/**
 * A list whose rows can be dragged into a new order. Render `SortableItem`s
 * as its children, in the order of `ids`. `onReorder` gets the new order.
 */
export function SortableList({
  ids,
  label,
  onReorder,
  as: List = "ol",
  className,
  disabled = false,
  children,
}: {
  ids: string[];
  /** Name of a row, for its grip and the screen reader announcements. */
  label: (id: string) => string;
  onReorder: (ids: string[]) => void;
  as?: "ol" | "ul";
  className?: string;
  disabled?: boolean;
  children: ReactNode;
}) {
  const contextId = useId(); // stable ids for the hidden instructions, so SSR and hydration agree
  const reduceMotion = useReducedMotion();
  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 4 } }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
      scrollBehavior: reduceMotion ? "auto" : "smooth",
    }),
  );
  const lastPosition = useRef(0);

  // While a row is held, the grabbing cursor stays on wherever the pointer goes.
  const setSorting = (on: boolean) => {
    if (on) document.documentElement.dataset.sorting = "";
    else delete document.documentElement.dataset.sorting;
  };
  useEffect(() => () => setSorting(false), []);

  const position = (id: UniqueIdentifier) => ids.indexOf(String(id)) + 1;
  const name = (id: UniqueIdentifier) => `“${label(String(id))}”`;
  const announcements: Announcements = {
    onDragStart({ active }) {
      lastPosition.current = position(active.id);
      return `${name(active.id)} opgepakt, positie ${lastPosition.current} van ${ids.length}.`;
    },
    onDragOver({ active, over }) {
      // Only speak when the position actually changes; dnd-kit also reports the start position.
      const at = over ? position(over.id) : 0;
      if (at === lastPosition.current) return undefined;
      lastPosition.current = at;
      return over ? `${name(active.id)} naar positie ${at} van ${ids.length}.` : `${name(active.id)} is buiten de lijst.`;
    },
    onDragEnd({ active, over }) {
      return over
        ? `${name(active.id)} neergezet op positie ${position(over.id)} van ${ids.length}.`
        : `${name(active.id)} blijft op positie ${position(active.id)}.`;
    },
    onDragCancel({ active }) {
      return `Verplaatsen geannuleerd. ${name(active.id)} staat weer op positie ${position(active.id)}.`;
    },
  };

  function onDragEnd({ active, over }: DragEndEvent) {
    setSorting(false);
    if (!over || active.id === over.id) return;
    const from = ids.indexOf(String(active.id));
    const to = ids.indexOf(String(over.id));
    if (from < 0 || to < 0) return;
    onReorder(arrayMove(ids, from, to));
  }

  const state = useMemo(
    () => ({ label, enabled: !disabled, canMove: !disabled && ids.length > 1, reduceMotion }),
    [label, disabled, ids.length, reduceMotion],
  );

  return (
    <DndContext
      id={contextId}
      sensors={sensors}
      collisionDetection={closestCenter}
      modifiers={[alongList]}
      accessibility={{ announcements, screenReaderInstructions: instructions }}
      onDragStart={({ activatorEvent }) => setSorting(!(activatorEvent instanceof KeyboardEvent))}
      onDragEnd={onDragEnd}
      onDragCancel={() => setSorting(false)}
    >
      <SortableContext items={ids} strategy={verticalListSortingStrategy}>
        <ListContext.Provider value={state}>
          <List className={className}>{children}</List>
        </ListContext.Provider>
      </SortableContext>
    </DndContext>
  );
}

/** Rows settle with the admin's ease-out curve; quick, so a reorder never waits on motion. */
const settle = { duration: 200, easing: "cubic-bezier(0.16, 1, 0.3, 1)" };

const lifted =
  "data-dragging:z-10 data-dragging:shadow-[0_12px_28px_-10px_rgb(20_26_46/0.28),0_2px_6px_-2px_rgb(20_26_46/0.12)]";

/** One row of a `SortableList`; its grip comes first, then `children`. */
export function SortableItem({
  id,
  className = "",
  handleClassName = "p-1",
  children,
}: {
  id: string;
  /** Use `data-dragging:` variants for how the row looks while it is held. */
  className?: string;
  handleClassName?: string;
  children: ReactNode;
}) {
  const list = useContext(ListContext);
  const { attributes, listeners, setNodeRef, setActivatorNodeRef, transform, transition, isDragging } = useSortable({
    id,
    disabled: !list.canMove,
    transition: list.reduceMotion ? null : settle,
    attributes: { roleDescription: "versleepbaar" },
  });

  const style: CSSProperties = {
    transform: transform ? `translate3d(0, ${transform.y}px, 0)` : undefined,
    transition: [transition, !list.reduceMotion && "box-shadow 150ms ease-out"].filter(Boolean).join(", ") || undefined,
  };

  return (
    <li ref={setNodeRef} style={style} data-dragging={isDragging || undefined} className={`group relative ${lifted} ${className}`}>
      {list.enabled && (
        <button
          type="button"
          ref={setActivatorNodeRef}
          {...attributes}
          {...listeners}
          disabled={!list.canMove}
          aria-label={`${list.label(id)} verplaatsen`}
          title={list.canMove ? "Sleep om te verplaatsen" : undefined}
          className={`shrink-0 touch-none rounded text-ink-faint transition-colors duration-150 enabled:cursor-grab enabled:hover:bg-paper enabled:hover:text-ink-soft disabled:opacity-30 group-data-dragging:text-ink-soft ${handleClassName}`}
        >
          <GripVertical className="size-4" aria-hidden />
        </button>
      )}
      {children}
    </li>
  );
}

/**
 * Shows a new order straight away while it is being saved. If saving fails,
 * the list falls back to the stored order and `onError` is called.
 */
export function useOptimisticOrder<L extends readonly { id: string }[] | null>(
  items: L,
  save: (ids: string[]) => Promise<unknown>,
  onError: (e: unknown) => void,
): readonly [L, (ids: string[]) => void] {
  const [pending, setPending] = useState<{ ids: string[]; token: number } | null>(null);
  const lastToken = useRef(0);

  const ordered = useMemo(() => {
    if (!items || !pending) return items;
    // Rows that arrived since the drag (another admin's edit) keep their place at the end.
    const rank = new Map(pending.ids.map((id, i) => [id, i]));
    return items
      .map((item, i) => ({ item, at: rank.get(item.id) ?? pending.ids.length + i }))
      .sort((a, b) => a.at - b.at)
      .map((x) => x.item) as unknown as L;
  }, [items, pending]);

  function reorder(ids: string[]) {
    const token = ++lastToken.current;
    const settled = () => setPending((p) => (p?.token === token ? null : p));
    setPending({ ids, token });
    save(ids).then(settled, (e) => {
      settled();
      onError(e);
    });
  }

  return [ordered, reorder];
}
