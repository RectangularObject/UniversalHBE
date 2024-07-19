-- https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp
declare class mtapiHook
    function Remove(self): ()
    function Modify(self, value: any): ()
end
declare class BasePart extends BasePart
    function AddGetHook(self, property: string, value: any): mtapiHook
    function AddSetHook(self, property: string, value: any): mtapiHook
    function AddCallHook(self, functionName: string, callback: (...any) -> ...any): mtapiHook
end
declare class Decal extends Decal
    function AddGetHook(self, property: string, value: any): mtapiHook
    function AddSetHook(self, property: string, value: any): mtapiHook
    function AddCallHook(self, functionName: string, callback: (...any) -> ...any): mtapiHook
end
declare game: typeof(game) & {
    AddGlobalGetHook: (self: DataModel, property: string, value: any) -> mtapiHook,
    AddGlobalSetHook: (self: DataModel, property: string, value: any) -> mtapiHook,
    AddGlobalCallHook: (self: DataModel, functionName: string, callback: (...any) -> ...any) -> mtapiHook,
}
