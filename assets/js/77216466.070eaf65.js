"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[200],{10214:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"Constructs a TeleportQueue object\\n\\n:::caution\\nYou don\'t need to give any QueueOptions when creating a new TeleportQueue, but\\nyou should be wary of the fact that not setting an Id or PlaceId can cause unwanted results!","params":[{"name":"startOptions","desc":"","lua_type":"QueueOptions?"}],"returns":[{"desc":"","lua_type":"TeleportQueue"}],"function_type":"static","source":{"line":166,"path":"src/init.lua"}},{"name":"GetPlayers","desc":"Returns an array of players that are in the queue","params":[],"returns":[{"desc":"","lua_type":"{Player}"}],"function_type":"method","source":{"line":193,"path":"src/init.lua"}},{"name":"SetOption","desc":"Sets an option to a new value. If there\'s a function in OnOptionUpdated\\nfor the option that is changing, it will run that function as well.","params":[{"name":"optionName","desc":"","lua_type":"string"},{"name":"newValue","desc":"","lua_type":"any"}],"returns":[{"desc":"whether it successfully set the option","lua_type":"boolean"}],"function_type":"method","source":{"line":206,"path":"src/init.lua"}},{"name":"GetOption","desc":"","params":[{"name":"optionName","desc":"","lua_type":"string"}],"returns":[{"desc":"The value of the option","lua_type":"any?"}],"function_type":"method","source":{"line":227,"path":"src/init.lua"}},{"name":"GetOptions","desc":"","params":[],"returns":[{"desc":"","lua_type":"QueueOptions"}],"function_type":"method","source":{"line":235,"path":"src/init.lua"}},{"name":"SetOptions","desc":"This can be used to set multiple options at once instead of only one at a time with `:SetOption()`.\\nYou shouldn\'t ever need to use the shouldReconcile parameter since it\'s only used when the TeleportQueue is constructed.","params":[{"name":"newTeleportQueueOptions","desc":"","lua_type":"QueueOptions"},{"name":"shouldReconcile","desc":"decides if reconciled with the defaults","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"nil\\n"}],"function_type":"method","source":{"line":247,"path":"src/init.lua"}},{"name":"Remove","desc":"Removes the provided player from the queue if they are within the queue.\\nIf they are not within the queue, it\'ll do nothing.","params":[{"name":"player","desc":"","lua_type":"Player"}],"returns":[{"desc":"true if the player was removed","lua_type":"boolean"}],"function_type":"method","source":{"line":282,"path":"src/init.lua"}},{"name":"RemoveAll","desc":"Removes all the players from the queue in a while loop.","params":[],"returns":[{"desc":"","lua_type":"{[Player]: boolean}"}],"function_type":"method","source":{"line":303,"path":"src/init.lua"}},{"name":"Add","desc":"If the AddResult returned is `AddResult.NotAllowed`, then it will return a second value\\nand that second value is the reasoning from the AllowedWithinQueue option function","params":[{"name":"player","desc":"","lua_type":"Player"}],"returns":[{"desc":"what happened when trying to add the player","lua_type":"(AddResult, string?)"}],"function_type":"method","source":{"line":325,"path":"src/init.lua"}},{"name":"Flush","desc":"If FlushResult is `FlushResult.Success` or `FlushResult.Failure`, it will return a second value. If it was a success,\\nthen that second value is a `TeleportAsyncResult`. If it was not, then it\'s a `string` describing what went wrong.","params":[],"returns":[{"desc":"what happened when trying to flush the TeleportQueue","lua_type":"(FlushResult, (TeleportAsyncResult | string)?)"}],"function_type":"method","source":{"line":374,"path":"src/init.lua"}},{"name":"Destroy","desc":"Cleans up any connections that TeleportQueue and locks `:Add()`, `:Flush()`, `:SetOption()`, `:SetOptions()`.\\nIt will yield until `:Flush()` is done processing. If it has been yielding for over FORCE_REMOVE_ALL_AFTER, then\\nit will automatically stop yielding. \\n\\nOnce it is done yielding, it runs `:RemoveAll()`. It doesn\'t not yield at all if `:Flush()` is not being processed.","params":[],"returns":[],"function_type":"method","yields":true,"source":{"line":422,"path":"src/init.lua"}}],"properties":[{"name":"FlushResult","desc":"A table containing all members of the `FlushResult` string enum.","lua_type":"FlushResult","tags":["enums"],"readonly":true,"source":{"line":131,"path":"src/init.lua"}},{"name":"AddResult","desc":"A table containing all members of the `AddResult` string enum.","lua_type":"AddResult","tags":["enums"],"readonly":true,"source":{"line":139,"path":"src/init.lua"}}],"types":[{"name":"QueueOptions","desc":"","fields":[{"name":"PlaceId","lua_type":"number","desc":""},{"name":"Id","lua_type":"string|number","desc":""},{"name":"MaxPlayers","lua_type":"number?","desc":""},{"name":"TeleportOptions","lua_type":"TeleportOptions?","desc":""},{"name":"AllowedWithinQueue","lua_type":"((TeleportQueue, Player) -> (boolean, string?))?","desc":""},{"name":"OnPlayerRemoved","lua_type":"((TeleportQueue, Player) -> nil)?","desc":""},{"name":"OnPlayerAdded","lua_type":"((TeleportQueue, Player) -> nil)?","desc":""},{"name":"OnOptionUpdated","lua_type":"{(TeleportQueue, any) -> nil}?","desc":""}],"source":{"line":84,"path":"src/init.lua"}},{"name":"AddResult","desc":"A string enum value used to describe the result of using `TeleportQueue:Add()`.","fields":[{"name":"QueueDestroyed","lua_type":"string","desc":"The TeleportQueue has been destroyed"},{"name":"QueueProcessing","lua_type":"string","desc":"The TeleportQueue is flushing"},{"name":"QueueFull","lua_type":"string","desc":"The TeleportQueue is at MaxPlayers"},{"name":"NotAllowed","lua_type":"string","desc":"The AllowedWithinQueue option rejected the player"},{"name":"PlayerBusy","lua_type":"string","desc":"The player is already within TeleportQueue"},{"name":"PlayerLeft","lua_type":"string","desc":"The player isn\'t a child of game.Players"},{"name":"Success","lua_type":"string","desc":"The TeleportQueue added the player"}],"tags":["enum"],"source":{"line":111,"path":"src/init.lua"}},{"name":"FlushResult","desc":"A string enum value used to describe the result of using `TeleportQueue:Flush()`.","fields":[{"name":"QueueDestroyed","lua_type":"string","desc":"The TeleportQueue has been destroyed"},{"name":"QueueEmpty","lua_type":"string","desc":"The TeleportQueue contains no players"},{"name":"Failure","lua_type":"string","desc":"The TeleportQueue failed when trying to call TeleportAsync"},{"name":"Success","lua_type":"string","desc":"The TeleportQueue was able to flush"}],"tags":["enum"],"source":{"line":123,"path":"src/init.lua"}}],"name":"TeleportQueue","desc":"A TeleportQueue is an object that handles a list of a players that can be teleported to a specified\\nPlaceId with specific TeleportOptions with ease.","source":{"line":147,"path":"src/init.lua"}}')}}]);