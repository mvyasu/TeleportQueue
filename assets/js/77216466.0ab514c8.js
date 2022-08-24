"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[200],{10214:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"Constructs a TeleportQueue object\\n\\n:::caution\\nYou don\'t need to give any QueueOptions when creating a new TeleportQueue, but\\nyou should be wary of the fact that not setting an Id or PlaceId can cause unwanted results!","params":[{"name":"startOptions","desc":"","lua_type":"QueueOptions?"}],"returns":[{"desc":"","lua_type":"TeleportQueue"}],"function_type":"static","source":{"line":189,"path":"src/init.lua"}},{"name":"Observe","desc":"Observes the TeleportQueue and calls the provided observer function when a player is removed or added and when\\nthe TeleportOptions change.","params":[{"name":"observerFn","desc":"","lua_type":"(updateKind: UpdateKind, ...any) -> nil"}],"returns":[{"desc":"","lua_type":"RBXScriptConnection\\n"}],"function_type":"method","source":{"line":220,"path":"src/init.lua"}},{"name":"GetPlayers","desc":"Returns an array of players that are in the queue","params":[],"returns":[{"desc":"","lua_type":"{Player}\\n"}],"function_type":"method","source":{"line":229,"path":"src/init.lua"}},{"name":"SetOption","desc":"Sets an option to a new value. If there\'s a function in OnOptionUpdated\\nfor the option that is changing, it will run that function as well.","params":[{"name":"optionName","desc":"","lua_type":"string"},{"name":"newValue","desc":"","lua_type":"any"},{"name":"_shouldFireChange","desc":"","lua_type":"boolean"}],"returns":[{"desc":"whether it successfully set the option","lua_type":"boolean"}],"function_type":"method","source":{"line":240,"path":"src/init.lua"}},{"name":"GetOption","desc":"","params":[{"name":"optionName","desc":"","lua_type":"string"}],"returns":[{"desc":"The value of the option","lua_type":"any?"}],"function_type":"method","source":{"line":264,"path":"src/init.lua"}},{"name":"SetOptions","desc":"This can be used to set multiple options at once instead of only one at a time with `:SetOption()`.\\nYou shouldn\'t ever need to use the shouldReconcile parameter since it\'s only used when the TeleportQueue is constructed.","params":[{"name":"newTeleportQueueOptions","desc":"","lua_type":"QueueOptions"},{"name":"shouldReconcile","desc":"decides if reconciled with the defaults","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"nil\\n"}],"function_type":"method","source":{"line":280,"path":"src/init.lua"}},{"name":"Remove","desc":"Removes the provided player from the queue if they are within the queue.\\nIf they are not within the queue, it\'ll do nothing.","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"_shouldFireChange","desc":"","lua_type":"boolean"}],"returns":[{"desc":"true if the player was removed","lua_type":"boolean"}],"function_type":"method","source":{"line":317,"path":"src/init.lua"}},{"name":"RemoveAll","desc":"Removes all the players from the queue in a while loop.","params":[],"returns":[{"desc":"","lua_type":"{[Player]: boolean}\\n"}],"function_type":"method","source":{"line":340,"path":"src/init.lua"}},{"name":"Add","desc":"If the AddResult returned is `AddResult.NotAllowed`, then it will return a second value\\nand that second value is the reasoning from the AllowedWithinQueue option function","params":[{"name":"player","desc":"","lua_type":"Player"}],"returns":[{"desc":"what happened when trying to add the player","lua_type":"(AddResult, string?)"}],"function_type":"method","source":{"line":373,"path":"src/init.lua"}},{"name":"Flush","desc":"If FlushResult is `FlushResult.Success` or `FlushResult.Failure`, it will return a second value. If it was a success,\\nthen that second value is a `TeleportAsyncResult`. If it was not, then it\'s a `string` describing what went wrong.","params":[],"returns":[{"desc":"what happened when trying to flush the TeleportQueue","lua_type":"(FlushResult, (TeleportAsyncResult | string)?)"}],"function_type":"method","source":{"line":424,"path":"src/init.lua"}},{"name":"Destroy","desc":"Cleans up any connections that TeleportQueue and locks `:Add()`, `:Flush()`, `:SetOption()`, `:SetOptions()`.\\nIt will yield until `:Flush()` is done processing. If it has been yielding for over FORCE_REMOVE_ALL_AFTER, then\\nit will automatically stop yielding. \\n\\nOnce it is done yielding, it runs `:RemoveAll()`. It doesn\'t not yield at all if `:Flush()` is not being processed.","params":[],"returns":[],"function_type":"method","yields":true,"source":{"line":472,"path":"src/init.lua"}}],"properties":[{"name":"FlushResult","desc":"A table containing all members of the `FlushResult` string enum.","lua_type":"FlushResult","tags":["enums"],"readonly":true,"source":{"line":153,"path":"src/init.lua"}},{"name":"AddResult","desc":"A table containing all members of the `AddResult` string enum.","lua_type":"AddResult","tags":["enums"],"readonly":true,"source":{"line":161,"path":"src/init.lua"}}],"types":[{"name":"QueueOptions","desc":"","fields":[{"name":"PlaceId","lua_type":"number","desc":""},{"name":"Id","lua_type":"string|number","desc":""},{"name":"MaxPlayers","lua_type":"number?","desc":""},{"name":"TeleportOptions","lua_type":"TeleportOptions?","desc":""},{"name":"AllowedWithinQueue","lua_type":"((TeleportQueue, Player) -> (boolean, string?))?","desc":""},{"name":"OnPlayerRemoved","lua_type":"((TeleportQueue, Player) -> nil)?","desc":""},{"name":"OnPlayerAdded","lua_type":"((TeleportQueue, Player) -> nil)?","desc":""},{"name":"OnOptionUpdated","lua_type":"{(TeleportQueue, any) -> nil}?","desc":""}],"source":{"line":94,"path":"src/init.lua"}},{"name":"UpdateKind","desc":"A string enum value used to describe the result of using `TeleportQueue:Add()`.","fields":[{"name":"PlayersAdded","lua_type":"string","desc":"Players were added"},{"name":"PlayersRemoved","lua_type":"string","desc":"Players were removed"},{"name":"OptionsChanged","lua_type":"string","desc":"Options were changed"},{"name":"Initializing","lua_type":"string","desc":"Observer is being ran for the first time"}],"tags":["enum"],"source":{"line":118,"path":"src/init.lua"}},{"name":"AddResult","desc":"A string enum value used to describe the result of using `TeleportQueue:Add()`.","fields":[{"name":"QueueDestroyed","lua_type":"string","desc":"The TeleportQueue has been destroyed"},{"name":"QueueProcessing","lua_type":"string","desc":"The TeleportQueue is flushing"},{"name":"QueueFull","lua_type":"string","desc":"The TeleportQueue is at MaxPlayers"},{"name":"NotAllowed","lua_type":"string","desc":"The AllowedWithinQueue option rejected the player"},{"name":"PlayerBusy","lua_type":"string","desc":"The player is already within TeleportQueue"},{"name":"PlayerLeft","lua_type":"string","desc":"The player isn\'t a child of game.Players"},{"name":"Success","lua_type":"string","desc":"The TeleportQueue added the player"}],"tags":["enum"],"source":{"line":133,"path":"src/init.lua"}},{"name":"FlushResult","desc":"A string enum value used to describe the result of using `TeleportQueue:Flush()`.","fields":[{"name":"QueueDestroyed","lua_type":"string","desc":"The TeleportQueue has been destroyed"},{"name":"QueueEmpty","lua_type":"string","desc":"The TeleportQueue contains no players"},{"name":"Failure","lua_type":"string","desc":"The TeleportQueue failed when trying to call TeleportAsync"},{"name":"Success","lua_type":"string","desc":"The TeleportQueue was able to flush"}],"tags":["enum"],"source":{"line":145,"path":"src/init.lua"}}],"name":"TeleportQueue","desc":"A TeleportQueue is an object that handles a list of a players that can be teleported to a specified\\nPlaceId with specific TeleportOptions with ease.","source":{"line":169,"path":"src/init.lua"}}')}}]);