# Roblox Portuguese-Speaking AI Player Script

Companheiro Lusófono is a Roblox server script that creates an AI NPC player named JogadorIA, speaks Brazilian Portuguese, responds to nearby player chat, offers a proximity conversation prompt, and patrols the area with Roblox pathfinding.

## Install

1. Open your Roblox experience in Roblox Studio.
2. In Explorer, open `ServerScriptService`.
3. Insert a server `Script`.
4. Rename the script to `PortugueseAIPlayer`.
5. Copy the contents of `PortugueseAIPlayer.server.lua` into the script.
6. Press Play to test the experience.

The script creates the NPC model, body parts, humanoid, name tag, interaction prompt, dialogue behavior, and patrol system automatically. No manually created NPC model is required.

## Use

1. Start the game and locate the NPC near the configured spawn position.
2. Walk within 12 studs of JogadorIA.
3. Press `E` when the “Conversar” prompt appears.
4. To receive a response to chat, remain within 20 studs of the NPC and send a message.
5. Use Portuguese messages containing supported topics such as greetings, help, the NPC’s name, thanks, or farewells.
6. The NPC responds with predefined Brazilian Portuguese messages and patrols within its configured area.

Unknown messages receive a general Portuguese response. Responses to each player are limited by the cooldown to prevent excessive chat output.

## Configuration

Edit the values near the top of `PortugueseAIPlayer.server.lua`:

- `NPC_NAME`: The NPC model name.
- `SPAWN_POSITION`: The NPC’s starting position.
- `PATROL_RADIUS`: The maximum patrol area around the starting position.
- `PATROL_INTERVAL`: The delay between patrol destinations.
- `RESPONSE_COOLDOWN`: The minimum delay between responses to the same player.

Dialogue keywords and responses can be changed in the `dialogue` table. The script also normalizes common Portuguese accents when matching messages.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/95188914-04d3-4889-81a0-86e0e8f06240?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=95188914-04d3-4889-81a0-86e0e8f06240
