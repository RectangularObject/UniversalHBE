-- https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp
type HttpRequestOptions = {
	Url: string,
	Method: "GET" | "HEAD" | "POST" | "PUT" | "DELETE" | "CONNECT" | "OPTIONS" | "TRACE" | "PATCH" | nil,
	Headers: { string }?,
	Body: string?,
}
type HttpResponseData = {
	StatusCode: number,
	StatusMessage: string,
	Headers: { string },
	Body: string?,
}
type CipherMode = "CBC" | "ECB" | "CTR" | "CFB" | "OFB" | "GCM"

declare game: typeof(game) & {
    HttpGet: (self: DataModel, url: string, nocache: boolean?) -> string,
}
declare debug: typeof(debug) & {
	dumpheap: (...any) -> ...any, -- no documentation
	getconstant: (func: (...any) -> ...any | number, index: number) -> any,
	getproto: (func: (...any) -> ...any | number, index: number, active: boolean?) -> (...any) -> ...any | { (...any) -> ...any },
	loadmodule: (module: ModuleScript) -> ...any,
	getstack: (level: number, index: number?) -> any | { any },
	--setconstants: (...any) -> ...any, -- what
	getupvalues: (func: (...any) -> ...any | number) -> { any },
	getupvalue: (func: (...any) -> ...any | number, index: number) -> any,
	--setprotos: (...any) -> ...any, -- what
	getconstants: (func: (...any) -> ...any | number) -> { any },
	getprotos: (func: (...any) -> ...any | number) -> { (...any) -> ...any },
	setproto: (func: (...any) -> ...any, index: number, replacement: (...any) -> ...any) -> (),
	getinfo: (func: (...any) -> ...any | number) -> { source: string, short_src: string, func: (...any) -> ...any, what: string, currentline: number, name: string, nups: number, numparams: number, is_vararg: number },
	setupvalue: (func: (...any) -> ...any | number, index: number, value: any) -> (),
	setconstant: (func: (...any) -> ...any | number, index: number, value: any) -> (),
	--setupvalues: (...any) -> ...any, -- what
	dumprefs: (...any) -> ...any, -- no documentation
}
declare base64: {
	encode: (data: string) -> string,
	decode: (data: string) -> string,
}
declare http: {
	request: (table: HttpRequestOptions) -> HttpResponseData,
}
declare crypt: {
	base64_decode: (data: string) -> string,
	hash: (data: string, algorithm: string) -> string,
	hex: {
		encode: (...any) -> (...any),
		decode: (...any) -> (...any),
	},
	random: (...any) -> (...any),
	decrypt: (data: string, key: string, iv: string, mode: CipherMode) -> string,
	encrypt: (data: string, key: string, iv: string?, mode: CipherMode?) -> (string, string),
	base64decode: (data: string) -> string,
	generatekey: () -> string,
	base64encode: (data: string) -> string,
	generatebytes: (size: number) -> string,
	base64: {
		encode: (data: string) -> string,
		decode: (data: string) -> string,
	},
	url: {
		encode: (...any) -> (...any),
		decode: (...any) -> (...any),
	},
	base64_encode: (data: string) -> string,
	hashes: {
	},
}
declare cache: {
	replace: (object: Instance, newObject: Instance) -> (),
	iscached: (object: Instance) -> boolean,
	invalidate: (object: Instance) -> (),
}
declare Drawing: {
	Fonts: {
		UI: number,
		Monospace: number,
		Plex: number,
		System: number,
	},
	new: ((type: "Line") -> DrawingLine) & ((type: "Text") -> DrawingText) & ((type: "Image") -> DrawingImage) & ((type: "Circle") -> DrawingCircle) & ((type: "Square") -> DrawingSquare) & ((type: "Quad") -> DrawingQuad) & ((type: "Triangle") -> DrawingTriangle),
}

declare class BaseDrawing
	Visible: boolean
	ZIndex: number
	Transparency: number
	Color: Color3
	function Destroy(self): ()
	function Remove(self): ()
end

declare class DrawingLine extends BaseDrawing
	From: Vector2
	To: Vector2
	Thickness: number
end

declare class DrawingText extends BaseDrawing
	Text: string
	TextBounds: Vector2
	Font: typeof(Drawing.Fonts)
	Size: number
	Position: Vector2
	Center: boolean
	Outline: boolean
	OutlineColor: Color3
end

declare class DrawingImage extends BaseDrawing
	Data: string
	Size: Vector2
	Position: Vector2
	Rounding: number
end

declare class DrawingCircle extends BaseDrawing
	NumSides: number
	Radius: number
	Position: Vector2
	Thickness: number
	Filled: boolean
end

declare class DrawingSquare extends BaseDrawing
	Size: Vector2
	Position: Vector2
	Thickness: number
	Filled: boolean
end

declare class DrawingQuad extends BaseDrawing
	PointA: Vector2
	PointB: Vector2
	PointC: Vector2
	PointD: Vector2
	Thickness: number
	Filled: boolean
end

declare class DrawingTriangle extends BaseDrawing
	PointA: Vector2
	PointB: Vector2
	PointC: Vector2
	Thickness: number
	Filled: boolean
end

declare function getclipboard(): string
declare function mousescroll(pixels: number): ()
declare function makefolder(path: string): ()
declare function mousemoverel(x: number, y: number): ()
declare function mousemoveabs(x: number, y: number): ()
declare function fromclipboard(...:any): ...any
declare function mouse2release(): ()
declare function getsenv(script: LocalScript | ModuleScript): { [string]: any }
declare function setrawmetatable(object: { [any]: any }, metatable: { [any]: any }): ()
declare function checkcaller(): boolean
declare function dumpstring(script: LocalScript | ModuleScript): string
declare function getfenv(...:any): ...any
declare function lz4compress(data: string): string
declare function mouse1release(): ()
declare function rconsolesettitle(title: string): ()
declare function setreadonly(object: { [any]: any }, readonly: boolean): ()
declare function consolecreate(): ()
declare function mouse1press(): ()
declare function getexecutorname(...:any): ...any
declare function lz4decompress(data: string, size: number): string
declare function getrawmetatable(object: { [any]: any }): { [any]: any }
declare function setrenderproperty(drawing: { [any]: any }, property: string, value: any): ()
declare function getreg(...:any): ...any
declare function rconsoleprint(text: string): ()
declare function consoleprint(text: string): ()
declare function newcclosure<T>(func: T): T
declare function getinstances(): { Instance }
declare function getloadedmodules(excludeCore: boolean?): { ModuleScript }
declare function getrenv(): { [string]: any }
declare function checkclosure(func: (...any) -> ...any): boolean
declare function gethui(): Folder
declare function toclipboard(...:any): ...any
declare function request(table: HttpRequestOptions): HttpResponseData
declare function getrenderproperty(drawing: { [any]: any }, property: string): any
declare function readfile(path: string): string
declare function rconsoledestroy(): ()
declare function getobjects(...:any): ...any
declare function consoledestroy(): ()
declare function http_request(table: HttpRequestOptions): HttpResponseData
declare function cloneref<T>(object:T): T
declare function consoleinput(): string
declare function decompile(...:any): ...any
declare function cleardrawcache(): ()
declare function loadstring(source: string, chunkname: string?): (((...any) -> ...any)?, string?)
declare function getscripts(): { LocalScript | ModuleScript }
declare function rconsolename(title: string): ()
declare function getcustomasset(path: string, noCache: boolean): string
declare function isexecutorclosure(func: (...any) -> ...any): boolean
declare function isluau(...:any): ...any
declare function hookmetamethod(object: { [any]: any }, method: string, hook: (...any) -> ...any): (...any) -> ...any
declare function setfpscap(fps: number): ()
declare function isourclosure(func: (...any) -> ...any): boolean
declare function setthreadcontext(identity: number): ()
declare function getthreadcontext(): number
declare function delfolder(path: string): ()
declare function listfiles(path: string): { string }
declare function saveplace(...:any): ...any
declare function replaceclosure<T>(func: T, hook: (...any) -> ...any): T
declare function getidentity(): number
declare function isrbxactive(): boolean
declare function getscripthash(script: LocalScript | ModuleScript): string
declare function getscriptenvs(...:any): ...any
declare function getrunningscripts(): { LocalScript | ModuleScript }
declare function setthreadidentity(identity: number): ()
declare function getthreadidentity(): number
declare function isgameactive(): boolean
declare function base64_decode(data: string): string
declare function serializeinstance(...:any): ...any
declare function delfile(path: string): ()
declare function islclosure(func: (...any) -> ...any): boolean
declare function fireproximityprompt(...:any): ...any
declare function consolesettitle(title: string): ()
declare function setidentity(identity: number): ()
declare function getscriptfunction(script: LocalScript | ModuleScript): (...any) -> ...any
declare function httpget(url: string, nocache: boolean?): string
declare function hookfunction<T>(func: T, hook: (...any) -> ...any): T
declare function mouse1click(): ()
declare function mouse2press(): ()
declare function getcallingscript(): BaseScript
declare function isfolder(path: string): boolean
declare function newlclosure(...:any): ...any
declare function getcallbackvalue(object: Instance, property: string): ((...any) -> ...any)?
declare function isrenderobj(object: any): boolean
declare function identifyexecutor(): (string, string)
declare function firetouchinterest(...:any): ...any
declare function appendfile(path: string, data: string): ()
declare function getscriptbytecode(script: LocalScript | ModuleScript): string
declare function consoleclear(): ()
declare function clonefunction<T>(func: T): T
declare function getnilinstances(): { Instance }
declare function getgc(includeTables: boolean?): { (...any) -> ...any | Instance | { [any]: any } }
declare function getallthreads(...:any): ...any
declare function iscclosure(func: (...any) -> ...any): boolean
declare function getmodules(...:any): ...any
declare function iswriteable(...:any): ...any
declare function celerycmd(...:any): ...any
declare function compareinstances(a: Instance, b: Instance): boolean
declare function isfile(path: string): boolean
declare function getgenv(): { [string]: any }
declare function rconsoleclear(): ()
declare function getscriptclosure(script: LocalScript | ModuleScript): (...any) -> ...any
declare function makewriteable(...:any): ...any
declare function rconsoleinput(): string
declare function rconsolecreate(): ()
declare function setclipboard(text: string): ()
declare function isreadonly(object: { [any]: any }): boolean
declare function saveinstance(...:any): ...any
declare function mouse2click(): ()
declare function dofile(path: string): ()
declare function consolename(...:any): ...any
declare function writefile(path: string, data: string): ()
declare function base64_encode(data: string): string
declare function loadfile(path: string, chunkname: string?): (((...any) -> ...any)?, string?)
declare function getnamecallmethod(): string
