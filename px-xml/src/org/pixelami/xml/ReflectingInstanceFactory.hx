package org.pixelami.xml;

import org.pixelami.xml.InstanceFactory;
import org.pixelami.xml.ElementRegistry;
import org.pixelami.xml.XMLUtil;

class ReflectingInstanceFactory extends InstanceFactory, implements IInstanceFactory
{
    var metaCache:Hash<Dynamic>;
    var meta:Dynamic;

    public function new(registry:ElementRegistry)
    {
        super(registry);
        metaCache = new Hash<String>();
		errors = [];
    }

    override public function createInstance(element:Xml):Dynamic
    {
        var type:Class<Dynamic> = this.registry.getClassForElement(element.nodeName);
        buildMeta(type);

        return super.createInstance(element);
    }

	override public function setProperty(inst:Dynamic, fieldName:String, value:Dynamic):Void
	{
		var castValue:Dynamic = castValueForField(inst, fieldName, value);
		Reflect.setProperty(inst, fieldName, castValue );
	}

    override public function castValueForField(inst:Dynamic, fieldName:String, value:Dynamic):Dynamic
    {
        var type:Class<Dynamic> = Type.getClass(inst);
        buildMeta(type);

        var fieldType:Class<Dynamic> = getFieldType(inst, fieldName);

		var cValue:Dynamic = value;
		if(!Std.is(fieldType, Array) && Std.is(value, Array)) cValue = value[0];


        try
        {
            cValue = castValue(cValue, fieldType);
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
                try
				{
					Reflect.setProperty(inst, attr, value);
				}
				catch(e:Dynamic)
				{
					trace(e);
					errors.push(new InstanceFactoryException(element, e));
				}
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
				errors.push(new InstanceFactoryException(element, e));
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

    function castValue(value:Dynamic, targetType:Class<Dynamic>):Dynamic
    {
        trace(targetType);
		return switch(targetType)
        {

            case Int: Std.parseInt(value);
            case Float: Std.parseFloat(value);
			//case String: parseString(value, targetType);
            default: Std.is(value, String) ? parseString(value, targetType) : value;
        }
    }

    function parseString(value:Dynamic, targetType:Class<Dynamic>):Dynamic
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
