package org.pixelami.uri.context;

import org.pixelami.uri.MetadataUtil;
import org.pixelami.uri.URIHandler;
import org.pixelami.uri.URIController;
import haxe.rtti.Meta;


//@:build(massive.screen.ScreenContextBuilder.buildContext())
class Context
{
    static var _instance:Context;
    public static var instance(get_instance,null):Context;
    static function get_instance():Context
    {
        if(_instance == null) _instance = new Context(new SingletonLock());
        return _instance;
    }

    var typeMap:Hash<Class<Dynamic>>;
    var instanceMap:Hash<Dynamic>;

    public var objects(default,set_objects):Array<Dynamic>;
    function set_objects(value:Array<Dynamic>):Array<Dynamic>
    {
        objects = value;
        //trace(objects);
        for(t in value)
        {
            if(!Std.is(t, Class)) throw "Object is not Class";
            var cname = Type.getClassName(t);
            typeMap.set(cname,t);
            mapURIHandlers(t);
        }
        return objects;
    }


    public function new(lock:SingletonLock)
    {
        typeMap = new Hash<Class<Dynamic>>();
        instanceMap = new Hash<Dynamic>();
    }

    function printMeta(o:Dynamic)
    {
        if(Std.is(o, Array))
        {
            var a:Array<Dynamic> = cast o;
            for(m in a)
            {
                trace(m);
            }
        }
    }

    function mapURIHandlers(type:Class<Dynamic>):Void
    {
        var typeName:String = Type.getClassName(type);
        trace("type: "+typeName);

        var meta = haxe.rtti.Meta.getFields(type);

        var mfields:Array<Dynamic> = MetadataUtil.getMetaInfo(meta,"uri");

        for(f in mfields)
        {
            trace("name: "+f.name);
            trace("meta: "+f.meta[0]);

            var filter:String = f.meta[0];
            var handler:URIHandler =  new URIHandler(filter, function():Dynamic
            {
                /*
                var t =  getInstanceFor(typeName);
                trace("t: "+t);
                trace("tt: "+ Type.typeof(t));
                return t;
                */

                if(!instanceMap.exists(typeName) )
                {
                    var t = typeMap.get(typeName);
                    //trace("t:"+Type.typeof(t));
                    var i = Type.createInstance(t, []);
                    //trace("i:"+Type.typeof(i));
                    instanceMap.set(typeName, i );
                }
                var _t = instanceMap.get(typeName);
                //trace(_t);
                //trace("_t:"+Type.typeof(_t));
                return _t;


            }, f.name);
            trace("adding handler: "+handler);
            URIController.instance.addURIHandler(handler);
        }

    }

    public function getInstanceFor(typeName:String):Dynamic
    {
        if(!instanceMap.exists(typeName) )
        {
            var t = typeMap.get(typeName);
            trace("t:"+Type.typeof(t));
            var i = Type.createInstance(t, []);
            trace("i:"+Type.typeof(i));
            instanceMap.set(typeName, i );
        }
        var _t = instanceMap.get(typeName);
        trace(_t);
        trace("_t:"+Type.typeof(_t));
        return _t;
    }

    public function toString():String
    {
        var s:String = "";
        s += "[Context objects: "+objects+" ]";
        return s;
    }
}

private class SingletonLock
{
    public function new(){}
}

