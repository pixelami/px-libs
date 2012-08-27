package org.pixelami.xml;

class ElementFactoryException
{
    var elementName:String;
    var message:String;

    public function new(elementName:String, ?message:String = "")
    {
        this.elementName = elementName;
        if(message == "")
        {
            this.message = "Unable to create Element "+elementName+"";
        }
        else
        {
            this.message = message;
        }

    }
}