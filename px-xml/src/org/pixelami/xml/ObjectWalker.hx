package org.pixelami.xml;

class ObjectWalker
{
    public var factory:ElementFactory;

    public function new()
    {

    }

    public function walk(object:Dynamic, ?element:Xml = null, ?depth:Int = 0):Xml
    {
        if(element == null)
        {
            element = Xml.createDocument();
        }

        var newElement:Xml = factory.createElement(object);

        for(field in Reflect.fields(object))
        {
            var el:Xml = createElement(field, Reflect.field(object,field));
            if(el != null)
            {
                newElement.addChild(el);
            }
        }

        element.addChild(newElement);

        return element;
    }


    public function createElement(name:String, value:Dynamic):Xml
    {
        var valueType:Type.ValueType = Type.typeof(value);
        trace("valueType: "+valueType);
        if(value == null) return null;


        var element:Xml = Xml.createElement(name);

        switch(valueType)
        {
            case Type.ValueType.TObject:
                element.addChild(walk(value, element));

            case Type.ValueType.TClass(c):
                if(Type.getClassName(c) == "String")
                {
                    element.addChild(Xml.createPCData(Std.string(value)));
                }


            case Type.ValueType.TInt, Type.ValueType.TFloat, Type.ValueType.TBool:
                element.addChild(Xml.createPCData(Std.string(value)));
            default:
        }

        return element;
    }
}