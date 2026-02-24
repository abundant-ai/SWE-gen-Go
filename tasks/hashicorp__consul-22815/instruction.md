In the Consul UI on the Tokens and Policies listing pages, the per-row “more actions” (three-dots/ellipsis) dropdown stops opening for some rows after you delete an item near the top of the list. The issue is reproducible when repeatedly deleting multiple items in the list: after the first deletion, the next item directly beneath the deleted row often becomes non-interactive (its dropdown won’t open), while items further down the list may still work. After additional deletes, multiple top rows can become “stuck” with an unopenable dropdown. Refreshing the browser restores full functionality.

This needs to be fixed so that after deleting any row (including repeated deletes), every remaining row’s actions dropdown continues to open and function normally, and the available actions (including “Delete” when applicable) remain correct for newly created/duplicated items as the list re-renders.

The behavior appears tied to the list component that renders rows and manages per-row state during interactions (including checked state and stacking order via z-index). When the underlying items array changes (e.g., an item is removed), the list should not leave stale DOM state or event handling that prevents subsequent rows from receiving pointer events or opening their action menu.

Concretely, ensure that the list rendering component correctly updates row state when items are removed, and that any z-index / collision handling / row “checked” state management does not block the action trigger for rows that shift position after deletion. A basic scenario that must work:

- Render a list of items with per-row actions.
- Delete the first item.
- Immediately open the actions dropdown for what is now the first item; it should open reliably.
- Repeat deletions several times; action menus for all remaining rows should still open.

Also ensure the row state updates correctly when toggling selection/checked state: when a row is checked and a change event occurs, its z-index should be set (e.g., to "1") to handle collisions with fixed elements like a footer; when unchecked, the z-index should be cleared back to the default (empty string).