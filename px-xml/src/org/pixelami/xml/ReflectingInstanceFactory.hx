package org.pixelami.xml;

import org.pixelami.xml.InstanceFactory;
import org.pixelami.xml.ElementRegistry;
import org.pixelami.xml.IElementFactory;
import org.pixelami.xml.XMLUtil;

class ReflectingInstanceFactory extends InstanceFactory, implements IElementFactory, implements IInstanceFactory
{
    var metaCache:Hash<Dynamic>;
    var meta:Dynamic;

    public function new(registry:ElementRegistry)
    {
        super(registry);
        metaCache = new Hash<String>();
    }

    override public function createInstance(element:Xml):Dynamic
    {
        var type:Class<Dynamic> = this.registry.getClassForElement(element.nodeName);
        buildMeta(type);

        return super.createInstance(element);
    }

	public function setProperty(inst:Dynamic, fieldName:String, value:String):Void
	{
		Reflect.setProperty(inst, fieldName, castValueForField(value));
	}

    override public function castValueForField(inst:Dynamic, fieldName:String, value:String):Dynamic
    {
        var type:Class<Dynamic> = Type.getClass(inst);
        buildMeta(type);

        var fieldType:Class<Dynamic> = getFieldType(inst, fieldName);
        var cValue:Dynamic = value;

        try
        {
            cValue = castValue(value, fieldType);
            //trace("castValue: "+ cValue);
            return cValue;
        }
        catch(e:Dynamic)
        {
            trace(e);
        }

        return cValue;
    }

    override function mapProperties(element:Xml,inst:Dynamic)
    {
        var attrbs:Iterator<String> = element.attributes();
        var type:Class<Dynamic> = Type.getClass(inst);

        for(attr in attrbs)
        {
            var targetType:Class<Dynamic> = getFieldType(inst, attr);
            var value:String = element.get(attr);

            if(targetType == null)
            {
                Reflect.setProperty(inst, attr, value);
                continue;
            }

            try
            {
                var cValue:Dynamic = castValue(value, targetType);
                //trace("castValue: "+ cValue);
                Reflect.setProperty(inst, attr, cValue);
            }
            catch(e:Dynamic)
            {
                trace(e);
            }
        }
    }

    function buildMeta(type:Class<Dynamic>)
    {
        var typeName:String = Type.getClassName(type);
        meta = metaCache.get(typeName);

        if(meta != null) return;

        metaCache.set(typeName, {});
        meta = metaCache.get(typeName);

        while (type != null)
        {
            var typeMeta = haxe.rtti.Meta.getFields(type);

            for (field in Reflect.fields(typeMeta))
            {
                var m = Reflect.field(typeMeta, field);
                //trace(m);
                Reflect.setField(meta, field, m);
            }

            type = Type.getSuperClass(type);
        }
    }

    function getFieldType(inst:Dynamic, fieldName:String):Class<Dynamic>
    {
        var fieldMeta = Reflect.field(meta,fieldName);
        var fieldTypeMeta:Array<Dynamic> = Reflect.field(fieldMeta, "type");
        var fieldTypeName = null;

        if(fieldTypeMeta == null) return null;

        var fieldType:Class<Dynamic> = null;
        fieldTypeName = fieldTypeMeta[0];

        try
        {
            fieldType =  Type.resolveClass(fieldTypeName);
        }
        catch(e:Dynamic)
        {
            trace(e);
        }

        return fieldType;
    }

    function castValue(value:String, targetType:Class<Dynamic>):Dynamic
    {
        switch(targetType)
        {

            case Int: return Std.parseInt(value);
            case Float: return Std.parseFloat(value);
            default:
                return parseString(value, targetType);
        }
    }

    function parseString(value:String, targetType:Class<Dynamic>):Dynamic
    {
        if(StringTools.startsWith(value, "#"))
        {
            if(targetType == Int)
            {
                return XMLUtil.parseHexValue(value);
            }
            return value;
        }
        else if(StringTools.endsWith(value, "%"))
        {
            if(targetType == Float)
            {
                return XMLUtil.parsePercentageValue(value);
            }
            return value;
        }
        return value;
    }
}
