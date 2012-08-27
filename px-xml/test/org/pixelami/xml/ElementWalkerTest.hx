package org.pixelami.xml;


//import org.pixelami.xml.macro.TypeMacroUtil;

import massive.munit.Assert;
import org.pixelami.xml.helper.Element;
import haxe.Resource;

class ElementWalkerTest
{
    var elementWalker:ElementWalker;


    public function new()
    {
    }

    @Before
    public function before()
    {
        elementWalker = new ElementWalker();

    }

    @Test
    public function shouldGenerateCorrectObjectForXMLTemplate1()
    {
        var registry:ElementRegistry = new ElementRegistry();
        registry.mapElementToClass("element", Element );

        elementWalker.factory = new ReflectingInstanceFactory(registry);

        var o:Dynamic = elementWalker.walk( Xml.parse( Resource.getString('template1') ) );

        Assert.isTrue(Std.is(o,Element));

        var element:Element = cast(o, Element);

        //trace(element);
        //trace(element.id);
        //trace(element.name);
        //trace(element.size);

        Assert.isTrue(element.id == 1);
        Assert.isTrue(element.name == "2");
        Assert.isTrue(element.size == 3.0);

        Assert.isTrue(element.children.length == 3);
    }

    @Test
    public function shouldGenerateCorrectObjectForXMLTemplate2()
    {
        var registry:ElementRegistry = new ElementRegistry();
        registry.mapElementToClass("element", Element );

        elementWalker.factory = new ReflectingInstanceFactory(registry);

        var o:Dynamic = elementWalker.walk( Xml.parse( Resource.getString('template2') ) );

        Assert.isTrue(Std.is(o,Element));

        var element:Element = cast(o, Element);
        var childElement = element.children[0];
        //trace(element);
        //trace(childElement);
        Assert.isTrue(childElement.id == 1);
        Assert.isTrue(childElement.name == "element");
        Assert.isTrue(childElement.size == 3.21);
    }
}
