package org.pixelami.ml;

import org.pixelami.ml.IFactory;

class ClassFactory implements IFactory<Dynamic>
{
	public var classDefinition(default,null):Class<Dynamic>;

	public function new(classDefinition:Class<Dynamic>)
	{
		this.classDefinition = classDefinition;
	}

	public function newInstance()
	{
		return Type.createInstance(classDefinition,[]);
	}
}
