--!strict
local Interface = require("@self/interface")
local VM = require("@self/vm")

type Interface = Interface.Interface
type Module = VM.Module
type Settings = VM.Settings

--[=[
	@class HotReload

	An object used to hold information relevant to hot reloading a certain Luau module / file / script.
]=]

local HotReload = {} :: impl
HotReload.__index = HotReload

type self = {
	Source: string,
	Interface: Interface,
	Module: Module?,

	_waitingForModule: { thread },
	_reloadThread: thread?,
	_main: ((...any) -> ...any)?,

	Settings: Settings,
}
type impl = {
	__index: impl,

	new: (interface: Interface) -> HotReload,

	IsHotReloaded: () -> boolean,
	Reload: (self: HotReload) -> (),
	Run: (self: HotReload, ...any) -> ...any,
}

export type HotReload = typeof(setmetatable({} :: self, HotReload))

local function getDefaultSettings(): Settings
	local settings = VM.luau_newsettings()

	local isHotReloaded = HotReload.IsHotReloaded
	settings.callHooks = {
		callHook = function(func, ...)
			if func ~= isHotReloaded then
				return func, ...
			end

			return function()
				return true
			end
		end,
	}

	return settings
end

--[=[
	Creates a new [HotReload] object with the provided [Interface].
]=]
function HotReload.new(interface: Interface, source: string?): HotReload
	local self = setmetatable({}, HotReload)

	--[=[
		@within HotReload
		@prop Source string

		The name / source of the Luau module thats being hot reloaded by this object.
	]=]
	self.Source = source or debug.info(2, "s")

	--[=[
		@within HotReload
		@prop Interface Interface

		A reference to the [Interface] used to create this HotReload object.
	]=]
	self.Interface = interface

	--[=[
		@within HotReload
		@prop Module Module
	]=]
	self.Module = nil

	--[=[
		@within HotReload
		@prop _waitingForBytecode { thread }
		@private

		A list of threads that are currently yielding and that should be resumed when [HotReload.Module] is available.
	]=]
	self._waitingForModule = {}

	--[=[
		@within HotReload
		@prop _reloadThread thread
		@private

		The thread that's currently fetching the updated code and reloading the code.
	]=]
	self._reloadThread = nil

	--[=[
		@within HotReload
		@prop _main ((...any) -> ...any)?
		@private

		A reference to the Luau module's main function.
	]=]
	self._main = nil

	--[=[
		@within HotReload
		@prop Settings Settings

		The [Fiu] settings that should be used.
	]=]
	self.Settings = getDefaultSettings()

	self:Reload()
	return self
end

--[=[
	Returns true if the current environment is being hot reloaded.
	If it is you shouldn't really try hot loading it again.
]=]
function HotReload.IsHotReloaded(): boolean
	return false
end

local function reload(self: HotReload)
	local bytecodeSuccess, bytecode = pcall(self.Interface.GetBytecode)
	if not bytecodeSuccess then
		print(`[HotReload] Failed to retrieve bytecode for {self.Source}: {bytecode}`)
		return
	end

	local deserializeSuccess, deserialized = pcall(VM.luau_deserialize, bytecode :: any, self.Settings)
	if not deserializeSuccess then
		print(`[HotReload] Failed to deserialize bytecode for {self.Source}: {deserialized}`)
	end

	local module = self.Module
	if not module then
		self.Module = deserialized

		for _, thread in self._waitingForModule do
			coroutine.resume(thread, deserialized)
		end
		table.clear(self._waitingForModule)

		return
	end

	local functionChangeError =
		`[HotReload] Changing the amount of functions or rearranging them is not yet supported. Not hot reloading. (source: {self.Source})`

	if #module.protoList ~= #deserialized.protoList then
		print(functionChangeError)
		return
	end

	for index, proto in module.protoList do
		local dProto = deserialized.protoList[index]
		if proto.nups ~= dProto.nups then
			print(
				`[HotReload] Changing the amount of upvalues that a function has is not yet supported. Not hot reloading. (line: {dProto.linedefined}, function name: {dProto.debugname}, source: {self.Source})`
			)
			return
		end

		if proto.sizep ~= dProto.sizep then
			print(functionChangeError)
			return
		end

		if table.concat(proto.protos, ",") ~= table.concat(dProto.protos, ",") then
			print(functionChangeError)
			return
		end
	end

	print(`[HotReload] Hot reloading {self.Source}`)

	module.stringList = deserialized.stringList
	module.typesVersion = deserialized.typesVersion

	for index, proto in module.protoList do
		local dProto = deserialized.protoList[index]
		proto.maxstacksize = dProto.maxstacksize
		proto.numparams = dProto.numparams
		proto.isvararg = dProto.isvararg
		proto.linedefined = dProto.linedefined
		proto.debugname = dProto.debugname

		proto.sizecode = dProto.sizecode
		proto.code = dProto.code
		proto.debugcode = dProto.debugcode

		proto.sizek = dProto.sizek
		proto.k = dProto.k

		proto.lineinfoenabled = dProto.lineinfoenabled
		proto.instructionlineinfo = dProto.instructionlineinfo
	end

	module.mainProto = deserialized.mainProto
end

--[=[
	Asks the [Interface] for the updated source code and then hot reloads the code.
]=]
function HotReload:Reload()
	if self._reloadThread then
		coroutine.close(self._reloadThread)
	end

	self._reloadThread = coroutine.create(reload)
	coroutine.resume(self._reloadThread :: any, self)
end

--[=[
	Runs the luau module.

	@yields
]=]
function HotReload:Run(...: any): ...any
	local module = self.Module
	if not module then
		table.insert(self._waitingForModule, coroutine.running())
		module = coroutine.yield()
	end

	if not self._main then
		self._main = VM.luau_load(module :: any, getfenv(2), self.Settings)
	end

	return (self._main :: any)(...)
end

return HotReload
