package org.pixelami.ml;

import org.pixelami.xml.macro.MacroTypeInfo;

class TypeElement
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
}