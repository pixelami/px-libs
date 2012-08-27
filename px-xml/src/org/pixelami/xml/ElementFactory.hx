package org.pixelami.xml;

class ElementFactory
{
    var registry:ElementRegistry;

    public function new(registry:ElementRegistry)
    {
        this.registry = registry;
    }

    public function createElement(inst:Dynamic):Xml
    {
        var type:Class<Dynamic> = Type.getClass(inst);
        var name = registry.getElementForClass(type);
        if(name == null) name = Type.getClassName(type);
        return Xml.createElement(name);
    }
}
