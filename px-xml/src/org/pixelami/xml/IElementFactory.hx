package org.pixelami.xml;

interface IElementFactory
{
    function createInstance(el:Xml):Dynamic;
    function castValueForField(inst:Dynamic, fieldName:String, value:String):Dynamic;
}
