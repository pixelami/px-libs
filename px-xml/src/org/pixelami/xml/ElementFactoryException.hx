package org.pixelami.xml;

class ElementFactoryException
{
	public var element:Xml;
    public var message:String;

    public function new(element:Xml, ?message:String = "")
    {
        this.element = element;
        if(message == "")
        {
            this.message = "Unable to create '"+element.nodeName+"'";
        }
        else
        {
            this.message = message;
        }

    }

	public function toString():String
	{
		return this.message;
	}
}