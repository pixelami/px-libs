package org.pixelami.xml;

class QName
{
    public static function fromString(nodeName:String, documentNameSpaces:Hash<String>):QName
    {
        var ns:Namespace = new Namespace();
        var localName:String;

        if(nodeName.indexOf(":") > -1)
        {
            var segs:Array<String> = nodeName.split(":");
            ns.name = segs[0];
            ns.uri = documentNameSpaces.get(ns.name);
            localName = segs[1];
        }
        else
        {
            localName = nodeName;
        }

        var q:QName = new QName(ns, localName);
        return q;
    }


    public var namespace(default,null):Namespace;
    public var localName(default,null):String;

    public function new(namespace:Namespace, localName:String)
    {
        this.namespace = namespace;
        this.localName = localName;
    }
}
