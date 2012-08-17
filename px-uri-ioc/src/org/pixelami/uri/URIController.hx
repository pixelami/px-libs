package org.pixelami.uri;

import org.pixelami.uri.processor.URIHandlerProcessor;
import org.pixelami.uri.processor.IURIHandlerProcessor;
import org.pixelami.uri.URIHandler;
import org.pixelami.re.RegexUtil;
import org.pixelami.re.MatchInfo;

class URIController
{

    static var _instance:URIController;
    public static var instance(get_instance,null):URIController;
    static function get_instance():URIController
    {
        if(_instance == null) _instance = new URIController(new SingletonLock());
        return _instance;
    }

    /**
     * list of processors that process the registered URIHandlers each time the URI changes
    **/
    public var uriProcessors:Array<IURIHandlerProcessor>;


    var uriHandlerCache:Hash<Array<URIHandler>>;

    var handlers:Array<URIHandler>;

    var filteredHandlers:Array<URIHandler>;




    public function new(lock:SingletonLock)
    {
        uriHandlerCache = new Hash<Array<URIHandler>>();
        handlers = [];
        filteredHandlers = [];
        uriProcessors = [];

        uriProcessors.push(new URIHandlerProcessor());
    }



    public function addURIHandler(handler:URIHandler):Void
    {
        // TODO optimize caching strategy - this is the sledgehammer approach
        uriHandlerCache = new Hash<Array<URIHandler>>();

        handlers.push(handler);
    }

    public function setURI(uri:String)
    {
        // TODO add authentication handler

        for(p in uriProcessors)
        {
            p.filteredHandlers = filteredHandlers;
            p.handlers = handlers;
            p.uriHandlerCache = uriHandlerCache;
            p.setURI(uri);
        }

    }


    public function redirect(from:String, to:String):Void
    {
        // a redirect should probably take the form of a Command that displays stores the 'from' value,
        // so that some user interation or other event can recall it.
    }
}


private class SingletonLock
{
    public function new(){}
}