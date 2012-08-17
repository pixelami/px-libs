package org.pixelami.uri;

@defaultChild("targets")
class Anchor
{

    public var command:String;
    @defaultChild
    public var targets:Array<Dynamic>;

    public var uri:String;

    public function new()
    {
         trace("new Anchor");
    }

    public function execute()
    {
        trace("Anchor execute()");
        for(target in targets)
        {
            trace("target: "+target);
        }

        //Type.createInstance(Type.resolveClass(command),[]).execute();
    }

    public function toString():String
    {
         return "[Anchor uri="+uri+"]";
    }
}
