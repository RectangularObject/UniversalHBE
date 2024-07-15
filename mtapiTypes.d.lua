-- https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp
declare class BasePart extends BasePart
    function AddGetHook(self, property: string, value: any)
    function AddSetHook(self, property: string, value: any)
    function AddCallHook(self, functionName: string, callback: (...any) -> ...any)
end
declare class Decal extends Decal
    function AddGetHook(self, property: string, value: any)
    function AddSetHook(self, property: string, value: any)
    function AddCallHook(self, functionName: string, callback: (...any) -> ...any)
end
declare game: typeof(game) & {
    AddGlobalGetHook: (self: DataModel, property: string, value: any) -> (),
    AddGlobalSetHook: (self: DataModel, property: string, value: any) -> (),
    AddGlobalCallHook: (self: DataModel, functionName: string, callback: (...any) -> ...any) -> (),
}
