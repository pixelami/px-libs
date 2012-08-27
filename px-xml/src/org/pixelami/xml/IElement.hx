package org.pixelami.xml;

/**
* If you extend IElement you get given the raw xml for parsing later.
**/
interface IElement
{
    var xml(default,set_xml):Xml;
}