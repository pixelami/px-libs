package org.pixelami.xml;

class Namespace
{
    public var name(default,default):String;
    public var uri(default,default):String;

    public function new(?name:String=null, ?uri:String=null)
    {
        this.name = name;
        this.uri = uri;
    }
}
