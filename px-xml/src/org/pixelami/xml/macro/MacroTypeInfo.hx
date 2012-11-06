package org.pixelami.xml.macro;

import haxe.macro.Type;

class MacroTypeInfo
{
    public var elementName:String;
    public var typeName:String;
    public var type:haxe.macro.Type;
    public var fields:Hash<ClassField>;
	public var defaultPropertyField:String;
	public var inheritanceChain:Array<String>;

    public function new()
    {
        fields = new Hash<ClassField>();
		inheritanceChain = [];
    }
}
