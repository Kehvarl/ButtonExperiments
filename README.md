Simpler Button definitions:
generates:  Map of key:value pairs for the button's output.  eg: {loot:1, other:1}
unlocks_after: What conditions must be met to unlock? eg: {loot:100, ship:1}
costs: what it costs to click the button.
on_click:   Symbol to call when clicking the button.  This must match a function name that we can call using "send"

Auto-click rethinking
Instead of Auto-click being built into the buttons, we could have the main tick iterate through a list of auto-clicks and if the button is clickable, do the clicking.
Auto-click definitions would need to include the button symbol, click frequency, and a current counter.
eg: [:loot, 10, 0] Clicks the :loot button every 10 frames and the last click was 0 frames ago.
There can be multiple auto-clickers for each button
An auto-click must still honor the button's other restrictions.
If an auto-click can't fire because the button is unclickable, it stays ready to fire as soon as the button can be clicked

Destroy-on-0 buttons
A countdown button that can be clicked any time, but is destroyed if it hits 0
  Might be useful for a combat minigame.  Have one for each "cannon" on the ship or each "HP" or something.


