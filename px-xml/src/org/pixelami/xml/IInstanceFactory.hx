package org.pixelami.xml;

interface IInstanceFactory
{
    function createInstance(el:Xml):Dynamic;
	function setProperty(inst:Dynamic, fieldName:String, value:Dynamic):Void;
	function getErrors():Array<Dynamic>;
}
