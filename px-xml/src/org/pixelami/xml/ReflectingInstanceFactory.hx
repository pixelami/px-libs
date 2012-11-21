package org.pixelami.xml;

import org.pixelami.xml.CastException;
import org.pixelami.xml.InstanceFactory;
import org.pixelami.xml.ElementRegistry;
import org.pixelami.xml.XMLUtil;

class ReflectingInstanceFactory extends InstanceFactory, implements IInstanceFactory
{
	static var numberPattern:EReg = ~/^0x[0-9ABCDEFabcdef]+$|^[0-9.]+$/;
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

    override function castValueForField(inst:Dynamic, fieldName:String, value:Dynamic):Dynamic
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
		catch(e:CastException)
		{
			var msg = "Unable to cast '"+e.value+"' to "+Type.getClassName(e.castToType)+" for property '"+fieldName+"'";
			//errors.push(new InstanceFactoryException(element,msg));
		}
		catch(e:Dynamic)
		{
			//trace(e);
			//errors.push(new InstanceFactoryException(element, e));
		}

        return cValue;
    }

    override function mapProperties(element:Xml,inst:Dynamic)
    {
        var attrbs:Iterator<String> = element.attributes();
        var type:Class<Dynamic> = Type.getClass(inst);
		var tFields = Type.getInstanceFields(type);
        for(attr in attrbs)
        {
            // ignore any 'private' attributes
			if(attr.substr(0,2) == "__") continue;
			//trace("assigning attr: "+attr);
			var targetType:Class<Dynamic> = getFieldType(inst, attr);
            var value:String = element.get(attr);

			// currently the classfield test is the safest way to check for
			// property assignment errors
			var idx = Lambda.indexOf(tFields, attr);
			if(idx == -1)
			{
				var msg = "Property '"+attr+"' does not exist in "+Type.getClassName(type);
				errors.push(new InstanceFactoryException(element, msg));
			}

            if(targetType == null)
            {
                //trace("no target type for attr '"+attr+"'");
				try
				{
					Reflect.setProperty(inst, attr, value);
				}
				catch(e:Dynamic)
				{
					//trace("could not assign '"+attr+"'");
					//trace(e);

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
			catch(e:CastException)
			{
				var msg = "Unable to cast '"+e.value+"' to "+Type.getClassName(e.castToType)+" for property '"+attr+"'";
				errors.push(new InstanceFactoryException(element,msg));
			}
            catch(e:Dynamic)
            {
                //trace(e);
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
			//trace("typemeta: ");
			//trace(typeMeta);
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
        var fieldTypeMeta:Array<Dynamic> = Reflect.field(fieldMeta, org.pixelami.xml.MetaConst.TYPE_META_NAME);
        var fieldTypeName = null;

        if(fieldTypeMeta == null) return null;

        var fieldType:Class<Dynamic> = null;
        fieldTypeName = fieldTypeMeta[0];

        try
        {
            fieldType = Type.resolveClass(fieldTypeName);
        }
        catch(e:Dynamic)
        {
            trace(e);
        }

        return fieldType;
    }

    function castValue(value:Dynamic, targetType:Class<Dynamic>):Dynamic
    {
        //trace("targetType:" + targetType);
		return switch(targetType)
        {

			case Int:
				if(!numberPattern.match(value)) throw new CastException(value,targetType,"not an Int");
				Std.parseInt(value);
			case Float:
				if(!numberPattern.match(value)) throw new CastException(value,targetType,"not a Float");
				Std.parseFloat(value);

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
