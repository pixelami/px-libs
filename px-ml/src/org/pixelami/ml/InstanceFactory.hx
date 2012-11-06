package org.pixelami.ml;

import org.pixelami.ml.ClassFactory;
import org.pixelami.xml.ReflectingInstanceFactory;

class InstanceFactory extends ReflectingInstanceFactory
{
	override function castValue(value:Dynamic, targetType:Class<Dynamic>):Dynamic
	{
		trace(targetType);
		return switch(targetType)
		{

			case Int: Std.parseInt(value);
			case Float: Std.parseFloat(value);
			case org.pixelami.ml.IFactory: untyped new ClassFactory(Type.resolveClass(value));
			//case String: parseString(value, targetType);
			default: Std.is(value, String) ? parseString(value, targetType) : value;
		}
	}
}
