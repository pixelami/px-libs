package org.pixelami.ml;

import org.pixelami.ml.ClassFactory;
import org.pixelami.xml.ReflectingInstanceFactory;

class InstanceFactory extends ReflectingInstanceFactory
{
	override function castValue(value:Dynamic, targetType:Class<Dynamic>):Dynamic
	{
		return switch(targetType)
		{
			case org.pixelami.ml.IFactory: untyped new ClassFactory(Type.resolveClass(value));
			default: super.castValue(value,targetType);
		}
	}
}
