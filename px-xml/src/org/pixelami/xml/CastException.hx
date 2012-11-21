package org.pixelami.xml;

class CastException
{
	public var value:Dynamic;
	public var castToType:Dynamic;
	public var message:String;

	public function new(value:Dynamic, castToType:Dynamic, ?message:String)
	{
		this.value = value;
		this.castToType = castToType;
		this.message = message;
	}
}