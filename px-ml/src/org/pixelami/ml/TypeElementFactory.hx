package org.pixelami.ml;

import org.pixelami.xml.IInstanceFactory;
import org.pixelami.xml.macro.MacroTypeInfo;
import org.pixelami.xml.ElementRegistry;

class TypeElementFactory implements IInstanceFactory
{
    var registry:ElementRegistry;
    var typeInfoMap:Hash<MacroTypeInfo>;
    var typeInfo:MacroTypeInfo;
	var errors:Array<Dynamic>;

    public function new(registry:ElementRegistry, typeInfoMap:Hash<MacroTypeInfo>)
    {
        this.registry = registry;
        this.typeInfoMap = typeInfoMap;
    }

    public function createInstance(element:Xml):Dynamic
    {
        //trace(element);
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

		typeElement.defaultPropertyField = typeElement.typeInfo.defaultPropertyField;
		typeElement.file = element.get("__file");
		typeElement.start = Std.parseInt(element.get("__start"));
		typeElement.end = Std.parseInt(element.get("__end"));


        for(attribute in element.attributes())
        {
            if(attribute == "id") typeElement.idField = element.get(attribute);
            castValueForField(typeElement, attribute, element.get(attribute));
        }
        trace("created "+typeElement+" for "+element.nodeName);
        return typeElement;
    }

    public function castValueForField(inst:Dynamic, fieldName:String, value:String):Dynamic
    {
        var field:haxe.macro.Type.ClassField = typeInfo.fields.get(fieldName);
        //trace("fieldName:"+fieldName);
		if(fieldName == "dataRenderer") trace(field);
        //trace("fieldType:"+field);
        cast(inst, TypeElement).propertyValueMap.set(fieldName, {field:field, value:value});
    }

	public function setProperty(inst:Dynamic, fieldName:String, value:Dynamic):Void
	{
		//trace("setting "+fieldName);
		//trace("setting "+cast(inst, TypeElement).typeInfo.typeName);

		var field:haxe.macro.Type.ClassField = cast(inst, TypeElement).typeInfo.fields.get(fieldName);
		if(fieldName == "dataRenderer") trace(field);
		//trace("setProperty: "+field);
		// unpack arrays
		if(field.name != "Array" && Std.is(value, Array)) value = value[0];
		cast(inst, TypeElement).propertyValueMap.set(fieldName, {field:field, value:value});

		//var castValue = castValueForField(parent, parentProperty, node.firstChild().toString());
		//Reflect.setProperty(parent, parentProperty, castValue);
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

	public function getErrors():Array<Dynamic>
	{
		return errors;
	}

	public function clearErrors():Void
	{
		errors = [];
	}
}