package org.pixelami.ml;

import org.pixelami.xml.ITypeDescriptor;
import org.pixelami.xml.macro.MacroTypeInfo;

class TypeElement implements ITypeDescriptor
{
    static var instanceCount:Int = 0;

    public var typeInfo:MacroTypeInfo;

    public var children:Array<TypeElement>;

    public var propertyValueMap:Hash<FieldValue>;

    public var idField:Dynamic;

    var instanceNumber:Int;



    public function new()
    {
        instanceNumber = instanceCount ++;
        propertyValueMap = new Hash<FieldValue>();
        children = [];
    }

	public function hasField(field:String):Bool
	{
		var hasKey:Bool = typeInfo.fields.exists(field);
		for(f in typeInfo.fields.keys())
		{
			//trace("f:" + f);
		}
		trace("hasKey: "+field+" "+hasKey);
		return hasKey;
	}

	public function toString():String
	{
		var buf:StringBuf = new StringBuf();
		buf.add("[TypeElement ");
		buf.add(typeInfo.typeName);
		buf.add(" - ");
		for(prop in propertyValueMap.keys())
		{
			buf.add(prop);
			buf.add(", ");
		}
		buf.add(" ]");
		return buf.toString();
	}
}