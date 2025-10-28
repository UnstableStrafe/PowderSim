# Powder Sim

### A simple powder sim program, featuring four different materials, each with their own behaviors.

## Particle types

- **Sand**: Tries to move down if possible, then tries to move down-left if possible, then tries to move down-right if possible. This causes it to form piles.
- **Stone**: Tries to move down if possible. This causes it to form pillars.
- **Water**: Tries to move to the closest, lowest tile if possible. This causes it to try to fill an area while remaining as level as possible.
- **Bedrock**: Does not move. This allows it to be used to make floating platforms that other particles can land on.

## Keybinds
- **Left Click**: Places the selected particle type at the cursor's position.
- **Right Click**: Hold down to rapidly place the selected particle type at the cursor's position.
- **G**: Press to delete the particle at the cursor's current position.
- **Q**: Press to bring up a radial menu to change particle types. Left click while hovering over a particle type to change to that type. Press **Escape** to close the menu.


### Code by UnstableStrafe, with help from QuantumCucumber.

