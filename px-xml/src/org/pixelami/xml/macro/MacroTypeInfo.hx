package org.pixelami.xml.macro;

import haxe.macro.Type;

class MacroTypeInfo
{
    public var elementName:String;
    public var typeName:String;
    public var type:Type;
    public var fields:Hash<ClassField>;

    public function new()
    {
        fields = new Hash<ClassField>();
    }
}
