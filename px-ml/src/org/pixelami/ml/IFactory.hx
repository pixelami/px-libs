package org.pixelami.ml;

interface IFactory<T>
{
	var classDefinition(default,null):Class<Dynamic>;
	function newInstance():T;
}
