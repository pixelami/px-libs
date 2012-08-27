package org.pixelami.xml;

import massive.munit.Assert;
import org.pixelami.xml.ObjectWalker;
class ObjectWalkerTest
{
    @Test
    public function shouldCreateValidElementNamesForMappedClasses()
    {
        var walker:ObjectWalker = new ObjectWalker();

        var registry:ElementRegistry = new ElementRegistry();


        // This is what we want to test
        registry.mapElementToClass("obj",ObjectA);
        walker.factory = new ElementFactory(registry);

        var o:ObjectA = new ObjectA();
        o.name = "ObjectA";
        o.id = "1";
        o.count = 1;



        var xml:Xml = walker.walk(o);
        trace(xml);
        // Did our mapping work
        Assert.isTrue(xml.firstElement().nodeName == "obj");
    }
}


class ObjectA
{
    public var name:String;
    public var id:String;
    public var count:Int;
    public var enabled:Bool;

    var children:Array<ObjectA>;

    public function new()
    {
        children = [];
    }
}
