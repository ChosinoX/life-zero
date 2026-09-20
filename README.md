# LIFE ZERO — From Nothing to Millionaire

An original, server-authoritative Roblox life/economy game. Players complete four physical jobs, build career and job levels, shop a rotating used-car market, repair and flip condition-based fictional vehicles, buy homes, complete quests, and claim a server-timed streak reward. The generated bright city and responsive UI require no external assets.

## Run in Studio

1. Install [Rojo](https://rojo.space/docs/v7/getting-started/installation/) (`aftman add rojo-rbx/rojo` or download its release) and the matching Roblox Studio Rojo plugin.
2. In this directory run `rojo serve default.project.json`.
3. Open a new Baseplate in Studio, open the Rojo plugin, connect to `localhost:34872`, and sync.
4. Press **Play**. The server generates the entire city. Walk to the green Cleaner kiosk, start work, then interact with the trash in Town Square.
5. For multiplayer use **Test → Server & Clients**, select 2–4 clients, and start.

## Persistence and publishing

Publish the experience before testing persistence. In **Game Settings → Security**, enable **Studio Access to API Services** only in a safe test universe. Data uses `LifeZero_Player_v1`, autosaves every 90 seconds, saves on leave/shutdown, retries failures, and has a cross-server session lock. Disable Studio API access when it is not needed. Publish with **File → Publish to Roblox**.

## Required manual configuration

All live-ops values are in `src/shared/Config.lua`.

* Look up `ChosinoXXX`'s numeric UserId from the official Roblox profile and add it to `Config.AdminUserIds`; no ID is guessed here.
* Create passes/products in Creator Dashboard → Monetization. Copy numeric IDs into `Config.GamePasses` / `Config.Products`. Zero IDs are intentionally inactive. Product fulfillment is exclusively through `MarketplaceService.ProcessReceipt` with persisted receipt IDs.
* Audio IDs are zero placeholders. Upload/choose licensed sounds and enter IDs in `Config.Audio` before wiring playback.

## Balance and extension

* Change job pay/unlocks, rarity weights (currently transparent 60/25/10/4/0.9/0.1%), market refresh, houses, vehicles, products, passes, rewards, and events in `Config.lua`.
* Add a car by adding a unique entry to `Config.Vehicles`; the market immediately includes it.
* Add a job in `Config.Jobs`, plus start/target entries in `MapBuilder.lua`; the authoritative completion pipeline handles rewards.
* Add a house to `Config.Houses`; it appears in the Home UI automatically.
* Add language keys to `Localization.lua`, then select them from the player's saved setting.

## Security model

Clients request named actions only. The server looks up canonical prices, offers, ownership, rewards, and rarity; validates types/state; rate-limits requests; and never accepts arbitrary currency or XP. Proximity prompts award only an active matching job. Auctions/events, furniture placement, drivable chassis, house-flip minigames, NPC pathfinding, global ordered leaderboards, and admin UI are expansion-ready data/config fields but are **not claimed as playable in this first version**.

## Static checks

Install Aftman/Rokit tooling if desired, then run `rojo build default.project.json -o build/LifeZero.rbxlx`. Test DataStore and receipts in a separate published test universe before production.
