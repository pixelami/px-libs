package org.pixelami.xml;

interface IInstanceFactory
{
    function createInstance(el:Xml):Dynamic;
    //function castValueForField(inst:Dynamic, fieldName:String, value:String):Dynamic;
	function setProperty(inst:Dynamic, fieldName:String, value:Dynamic):Void;
}
