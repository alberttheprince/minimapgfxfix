# 3751 minimap.gfx and Mansion Map Hider

This is a simple resource that hides the Mansion maps, and removes the health, armor, and stamina bars in 3751. 

You would use this resource if you have a custom HUD that handles health/stamina, to save on constantly hiding it every frame.

Don't want to download the resource to hide the houses?

Put this in any client side script/smallresource package:

```
SetMinimapComponent(20, false, -1)
SetMinimapComponent(21, false, -1)
SetMinimapComponent(22, false, -1)
```

# Dependencies:
(Optional) Ox_lib, so that you can re-enable the maps when inside the house. Set to true in the config

# Important Note on minimap.gfx:

You must update 3751 to the game build you are using. You cannot run multiple versions, they will overwrite each other. Make sure you delete or replace it if it's currently in another resource. Usually, HUD resources will have their own version.
