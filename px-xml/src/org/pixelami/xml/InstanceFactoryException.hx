package org.pixelami.xml;

class InstanceFactoryException
{
	public var element:Xml;
	public var error:Dynamic;

	public function new(element:Xml, error:Dynamic)
	{
		this.element = element;
		this.error = error;
	}

	public function toString():String
	{
		return "[InstanceFactoryException " + error + "]";
	}
}
