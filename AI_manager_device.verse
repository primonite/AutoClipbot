
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Fortnite.com/AI }
using { /Fortnite.com/Playspaces }

AI_manager_device := class(creative_device):
    
    @editable       NPCSpawnerDevice : npc_spawner_device = npc_spawner_device{}
    @editable       TriggerNPCSpawner : trigger_device = trigger_device{}
    # Can be placed anywhere
    @editable       Teleporter : teleporter_device = teleporter_device{}
    # To be placed at the starting position
    @editable       TeleporterReturn : teleporter_device = teleporter_device{}
    @editable       PlayerSpawner1 : player_spawner_device = player_spawner_device{}
    @editable       SignalRemoteManager : signal_remote_manager_device = signal_remote_manager_device{}
    
    # Map that the real player is placed into
    var RealMap : [agent]agent = map{}
    # Map where the NPC is stored. Eliminated NPCs are removed from the map
    var NPCMap : [agent]agent = map{}

    # Placeholder value for the distance to the teleporter required for the NPC to spawn
    DEFAULT_DISTANCE_TO_SPAWNER : float = 500.0
    # Variable version of the required distance for the NPC to spawn
    var TeleportRange : float = 500.0

    # Time before the NPC gets teleported to the teleporter again
    var AutoRetryTime : float = 5.0

    # Manually determines if NPC is alive, used to make sure the NPC is alive before being teleported
    var isNPCAlive : logic = false
    # Manually determines if the NPC is still within range of the teleporter, disables the teleporter if true
    var NPCInArea : logic = false
    # Manually determines if the Teleporter is disabled
    var isTeleDisabled : logic = false
    # Used to break the SpawnerCheck loop to improve performance
    var SpawnerCheckCount : int = 0

    OnBegin<override>()<suspends>:void=
        
        PlayerSpawner1.SpawnedEvent.Subscribe(OnPlayerSpawned)

        SignalRemoteManager.PrimarySignalEvent.Subscribe(OnRemoteClicked)
        SignalRemoteManager.SecondarySignalEvent.Subscribe(OnRemoteSecondaryClicked)

        TriggerNPCSpawner.TriggeredEvent.Subscribe(OnSpawner1Enable)
        NPCSpawnerDevice.SpawnedEvent.Subscribe(OnNPCSpawned)
        NPCSpawnerDevice.EliminatedEvent.Subscribe(OnNPCEliminated)

        # Spawns NPC at game start
        NPCSpawnerDevice.Enable()
        NPCSpawnerDevice.Spawn()

    OnPlayerSpawned(Agent : agent):void=
        InitPlayer(Agent)

    OnNPCSpawned(Agent : agent):void=
        if(AgentNPC := agent[Agent]):
            InitNPC(Agent)
        
    SpawnAllNPCs():void=
        NPCSpawnerDevice.Spawn()

    # Not really necessary with only 1 spawner. Meant to be used to disable the other NPC spawners
    # when more than 1 NPC spawner exists
    OnSpawner1Enable(Agent : ?agent):void=
        if(Player := player[Agent?]):
            NPCSpawnerDevice.Enable()
            NPCSpawnerDevice.Spawn()

    # Removes eliminated NPCs from the NPCMap
    OnNPCRemoved():void=
        for(AllNPC : NPCMap):
            var TempNPCMap : [agent]agent = map{}
            for (Key -> Value : NPCMap, Key <> AllNPC):
                set TempNPCMap = ConcatenateMaps(TempNPCMap, map{Key => Value})
            set NPCMap = TempNPCMap
            Print("NPC removed from NPC Map")

    # Adds the real Player to the RealMap
    InitPlayer(Agent : agent):void=
        if(FC := Agent.GetFortCharacter[])
        then:
            if(ExistingReal := RealMap[Agent]):
                Print("Player is already in Real Map")
            else:
                RealSetup : agent = Agent
                Print("Added Player to Real Map")
                if(set RealMap[Agent] = RealSetup) {}

    # Adds the NPC to the NPCMap
    InitNPC(Agent : agent):void=
        if(FC := Agent.GetFortCharacter[])
        then:
            if(ExistingNPC := NPCMap[Agent]):
                Print("NPC is already in NPC Map")
            else:
                NPCSetup : agent = Agent
                Print("Added NPC to NPC Map")
                if(set NPCMap[Agent] = NPCSetup) {}

    OnRemoteClicked(Agent : agent):void=
        Print("Remote primary clicked")
        # Move the teleporter to the Player
        MoveTeleporter(Agent)
        # Start the SpawnerCheck loop only if it hasn't already been started
        if(SpawnerCheckCount = 0):
            spawn { SpawnerCheck(Agent) }
        # Teleports the Player back to the starting position
        TeleporterReturn.Teleport(Agent)

    # Can be set up to reset the builds using an Explosive Device
    # Does nothing as-is
    OnRemoteSecondaryClicked(Agent : agent):void=
        Print("Remote secondary clicked")
        
    MoveTeleporter(Agent : agent):void=
        if(FC := Agent.GetFortCharacter[]):
            PlayerPos : vector3 = FC.GetTransform().Translation
            PlayerRot : rotation = rotation{}

            # Placeholder Teleporter position value
            var TelePos : vector3 = vector3 {X:=0.0, Y:=0.0, Z:=0.0}
            TelePosition : vector3 = Teleporter.GetTransform().Translation

            # Move the Teleporter to the Player
            if(Teleporter.TeleportTo [PlayerPos, PlayerRot]):
                # Update the placeholder Teleporter position value
                # Necessary to check the Distance later
                set TelePos = PlayerPos
                Print("TelePos is {TelePos}")
            else:
                Print("Failed to move Teleporter")

    # Checks if the Player is within range of the Teleporter to teleport the NPC
    SpawnerCheck(Agent : agent)<suspends>:void=
        
        set SpawnerCheckCount += 1
        for(Reals : RealMap):
            if(AgentReal : fort_character = Agent.GetFortCharacter[]):
                loop:
                    # Checks if SpawnerCheck loop is already running
                    if(SpawnerCheckCount > 1):
                        # Reset the counter and end the loop
                        set SpawnerCheckCount = 0
                        break
                    else:
                        AgentPos : vector3 = AgentReal.GetTransform().Translation
                        TelePos : vector3 = Teleporter.GetTransform().Translation
                        # Gets distance between the Player and the Teleporter every 0.1s
                        TotalDistance : float = Distance(AgentPos, TelePos)
                        if(isTeleDisabled = false):
                            # Determines if the Player is in range of the Teleporter
                            if(TotalDistance < TeleportRange):
                                if(isNPCAlive = false):
                                    # If the NPC is somehow dead, respawn it
                                    SpawnAllNPCs()
                                    for(AgentNPC : NPCMap):
                                        # Teleport the NPC to the Teleporter
                                        # Technically teleports all NPCs
                                        # but only one should be alive at a time
                                        TeleportNPC(AgentNPC)
                                else:
                                    for(AgentNPC : NPCMap):
                                        TeleportNPC(AgentNPC)
                        else:
                            # If the Teleporter is disabled because the Player
                            # is within range, wait for the AutoRetry time
                            # and then re-enable the Teleporter
                            Sleep(AutoRetryTime)
                            Teleporter.Enable()
                            set isTeleDisabled = false
                        Sleep(0.1)

    TeleportNPC(Agent : agent):void=
        # If the NPC is not within range of the Teleporter
        # Teleport the NPC
        if(NPCInArea = false):
            Teleporter.Teleport(Agent)
            set NPCInArea = true
        else:
            # Double check if the NPC is in range or not
            if(cNPC : fort_character = Agent.GetFortCharacter[]):
                NPCPos : vector3 = cNPC.GetTransform().Translation
                TelePos : vector3 = Teleporter.GetTransform().Translation
                TotalDistance2 : float = Distance(NPCPos, TelePos)
                    # If the NPC is still out of range of the Teleporter
                    # Teleport the NPC
                    if(TotalDistance2 > TeleportRange):
                        set NPCInArea = false
                        Teleporter.Teleport(Agent)
                    # If not, then manually specify that the NPC is in range
                    else:
                        set NPCInArea = true

    OnNPCEliminated(AIInteractionResult : device_ai_interaction_result):void=
        # If the Player eliminates the NPC:
        if(AIInteractionResult.Source?):
            # Manually specify that the NPC is dead
            set isNPCAlive = false
            # Remove the NPC from the NPCMap
            OnNPCRemoved()
            # Disable the Teleporter so that a new NPC
            # does not get teleported
            Teleporter.Disable()
            # Manually specify that the Teleporter is disabled
            set isTeleDisabled = true
            # Respawn all of the NPCs so they are ready for use again
            SpawnAllNPCs()
            # Manually specify that the NPCs are alive again
            set isNPCAlive = true
        # If the NPC dies but the player did not kill it:
        else:
            # Manually specify that the NPC is dead
            set isNPCAlive = false
            # Remove the NPC from the NPCMap
            OnNPCRemoved()
