package org.pixelami.ml;

import org.pixelami.xml.macro.MacroTypeInfo;
import org.pixelami.xml.IElementFactory;
import org.pixelami.xml.ElementRegistry;

class TypeElementFactory implements IElementFactory
{
    var registry:ElementRegistry;
    var typeInfoMap:Hash<MacroTypeInfo>;
    var typeInfo:MacroTypeInfo;

    public function new(registry:ElementRegistry, typeInfoMap:Hash<MacroTypeInfo>)
    {
        this.registry = registry;
        this.typeInfoMap = typeInfoMap;
    }

    public function createInstance(element:Xml):Dynamic
    {
        trace(element);
        var type:Class<Dynamic> = registry.getClassForElement(element.nodeName);
        var inst:Dynamic = Type.createInstance(type,[]);
        var typeElement:TypeElement = cast(inst, TypeElement);

        if(Std.is(inst, ScriptElement))
        {
            trace(element.toString());
            cast(inst, ScriptElement).block = element.toString();
            return inst;
        }


        typeElement.typeInfo = typeInfo = getTypeInfo(element);


        for(attribute in element.attributes())
        {
            if(attribute == "id") typeElement.idField = element.get(attribute);
            castValueForField(typeElement, attribute, element.get(attribute));
        }
        //trace("created "+typeElement+" for "+element.nodeName);
        return typeElement;
    }

    public function castValueForField(inst:Dynamic, fieldName:String, value:String):Dynamic
    {
        var field:haxe.macro.Type.ClassField = typeInfo.fields.get(fieldName);
        trace("fieldName:"+fieldName);
        trace("fieldType:"+field);
        cast(inst, TypeElement).propertyValueMap.set(fieldName, {field:field, value:value});
    }

    function getTypeInfo(element:Xml):MacroTypeInfo
    {
        var _typeInfo:MacroTypeInfo;
        if(_typeInfo == null)
        {
            for(info in typeInfoMap)
            {
                if(info.elementName == element.nodeName)
                {
                    _typeInfo = info;
                    break;
                }
            }
        }
        return _typeInfo;
    }
}