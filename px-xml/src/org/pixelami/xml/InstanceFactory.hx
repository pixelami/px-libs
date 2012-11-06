package org.pixelami.xml;


import org.pixelami.xml.IInstanceFactory;
typedef InstanceFactory = InstanceFactoryDefault ;


class InstanceFactoryDefault implements IInstanceFactory
{
    var registry:ElementRegistry;
	var errors:Array<Dynamic>;

    public function new(registry:ElementRegistry)
    {
        this.registry = registry;
    }

    public function createInstance(element:Xml):Dynamic
    {
        if(element.nodeType != Xml.Element)
        {
            throw new ElementFactoryException(element.toString().substr(0,20),"supplied argument is not of type Xml.Element");
        }
        var classForElement:Class<Dynamic> = registry.getClassForElement(element.nodeName);
        //trace("element.nodeName: "+element.nodeName);
        //trace("classForElement: "+classForElement);
        if(classForElement == null)
        {
            //classForElement = Dynamic;
            throw new ElementFactoryException(element.nodeName);
        }

        var elementInstance = null;
        try
        {
            elementInstance = Type.createInstance(classForElement,[]);
            //trace("Created Instance : "+elementInstance);
        }
        catch(e:Dynamic)
        {
             trace("could not call Type.createInstance: "+e);
        }

        //if(elementInstance == null) elementInstance = {};

        if(elementInstance != null) mapProperties(element,elementInstance);

        return elementInstance;
    }

	public function setProperty(inst:Dynamic, fieldName:String, value:Dynamic)
	{
		Reflect.setProperty(inst, fieldName, value);
	}

    public function castValueForField(inst:Dynamic, fieldName:String, value:Dynamic):Dynamic
    {
        return value;
    }


    function mapProperties(element:Xml,inst:Dynamic)
    {
        var attrbs:Iterator<String> = element.attributes();
        //trace("attrbs: "+attrbs);
        //trace("inst attrbs: "+inst);
        for(attr in attrbs)
        {
            var value:String = element.get(attr);
            var numericValue:Float = Std.parseFloat(value);
            //trace("setting "+attr+ ":" + value );

            if(!Math.isNaN(numericValue))
            {
                //Reflect.setField(inst, attr, numericValue);
                Reflect.setProperty(inst, attr, numericValue);
            }
            //else Reflect.setField(inst, attr, value);
            Reflect.setProperty(inst, attr, value);

        }

        if(Std.is(inst, IElement))
        {
            //trace("detected IElement, assigning "+element);
            cast(inst, IElement).xml = element;
        }

    }

	public function getErrors():Array<Dynamic>
	{
		return errors;
	}

}

