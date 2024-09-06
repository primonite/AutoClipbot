# AutoClipbot
Code for the Auto Clipbot mechanic written in Verse for use in Unreal Editor for Fortnite.

# TUTORIAL
1. Once you have created your Project, open the Verse Explorer tab/window and right click the uppermost directory _(it has the name of your Project)_.
2. Under Project Operations, select **Add new Verse file to Project**
3. Make sure the selected Verse file type is **Verse Device**, name your device, and then select **Create Empty**
4. Paste the code of **AI_manager_device.verse** into your newly created Verse Device.
5. In the top right of Visual Studio Code, click the Build button (Verse logo with checkmark).
6. In the Content Browser inside UEFN, locate the Verse Device in the root directory of your Project's content.
7. Drag the Verse Class into the viewport to add it to the world.
8. Add the other necessary Fortnite Devices to your world and configure their settings (see Details panel of the Verse device to know which Fortnite devices you'll need).
9. For the NPC, add a new folder to your Project's content folder to store some Character Definitions. Inside of the folder, right click and add an NPC Character Definition (under Artificial Intelligence). Double click the Character Definition to change its properties, but the only important modifiers are the Cosmetic and Health modifiers. The NPC Character Type can be left as Custom and the Behaviour can be Empty Behaviour. Add an NPC Spawner device into the world and assign the Character Definition to it.
10. Push changes within UEFN (top middle).

# FAQ
## What is a "Clipbot"?
> A clipbot is used by Fortnite players to end a clip, usually a series of builds, with an elimination.

## What is Auto Clipbot?
> Auto Clipbot is made for use in Fortnite maps created in UEFN. This Verse code is used to teleport an NPC to any location that the Player specifies using a Signal Remote. The NPC becomes the clipbot and can be used to hit clips without the aid of another player or alt account/secondary device.

## How does Auto Clipbot work?
> This Verse code listens for when the Player uses the Signal Remote, and moves a Teleporter device to their location. The Player's location is then reset.
> When the Player moves within a specified range of the Teleporter device, an NPC is teleported to the location of the Teleporter and the Player can eliminate the NPC.

## How do I add support for more NPCs?
> Add a new NPC Character Definition for each NPC, add a new Trigger for each NPC, subscribe to all TriggeredEvent and in each OnSpawner#Enable function, disable the other spawners. Then enable the corresponding spawner and tell it to Spawn(). It is extremely important to make sure that the setting "Despawn AIs When Disabled" is enabled in UEFN (off by default) inside each NPC Spawner. Also add each NPC Spawner Device to the SpawnAllNPCs() function.

## How do I make a UEFN map? How do I do XYZ inside of UEFN?
> I cannot make a complete guide on how to setup a UEFN map at this time.
> Please consider consulting [these official Epic Games tutorials](https://dev.epicgames.com/community/fortnite/getting-started/uefn) to learn more.

## Why release this?
> Enough time has passed since the release of my Auto Clipbot map to the point where I feel comfortable releasing its code publicly.

> With absolutely 0 programming experience, creating this from basically scratch was very challenging.

> Hopefully, releasing this code allows someone else to learn from the techniques that I used to make this mechanic work as seamlessly as possible.

> I am also afraid that I may one day stop working on Auto Clipbot but someone may want to improve it in some way. So this is here to help someone pick up roughly where I left off.

> Also, who doesn't love free Verse code?

# SHOWCASE / USAGE TUTORIAL
https://github.com/user-attachments/assets/fd9b1ffd-2a7e-4b75-bacf-ddc5daa816c9

