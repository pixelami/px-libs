package org.pixelami.uri.processor;

import org.pixelami.uri.URIHandler;
import org.pixelami.re.RegexUtil;
import org.pixelami.re.MatchInfo;

class URIHandlerProcessor implements IURIHandlerProcessor
{
    /**
     * all registered handlers
    **/
    public var handlers:Array<URIHandler>;

    /**
     * the set of handlers the were filtered based on the previous url
    **/
    public var filteredHandlers:Array<URIHandler>;

    /**
     * previously matched handlers based on uri key
    **/
    public var uriHandlerCache:Hash<Array<URIHandler>>;


    public function new()
    {
    }

    public function setURI(uri:String)
    {

        var fhandlers:Array<URIHandler> = uriHandlerCache.get(uri);

        if(fhandlers == null)
        {
            fhandlers = getHandlerMatches(uri);
            fhandlers.sort(sortHandlers);
            trace("Sorted URIHandlers");
            uriHandlerCache.set(uri, fhandlers);

        }

        for(handler in filteredHandlers)
        {
            var notexists:Bool = Lambda.exists(fhandlers, function(v:Dynamic):Bool
            {
                trace(v);
                trace(handler);
                return v != handler;
            });
            if(notexists)
            {
                Reflect.callMethod(handler.ref, Reflect.field(handler.ref, "close"), [uri]);
            }
        }


        for(fhandler in fhandlers)
        {
            // only call newly matched handlers
            var exists:Bool = Lambda.exists(filteredHandlers, function(v:Dynamic):Bool
            {
                trace(v);
                trace(fhandler);
                return v == fhandler;
            });
            if(!exists)
            {
                var o = fhandler.ref();

                Reflect.callMethod(o, Reflect.field(o, fhandler.field), [uri]);
            }


        }
        filteredHandlers = fhandlers;
    }

    function createChangeObject()
    {

    }

    function getHandlerMatches(uri:String)
    {
        var fhandlers = [];
        for(handler in handlers)
        {
            trace("handler: " + handler);
            trace("matching uri: " + uri);
            handler.info = RegexUtil.search(handler.ereg, uri);
            if(handler.info == null) continue;
            trace("match groups: " + handler.info.groups) ;
            if(handler.info.groups.length > 0)
            {

                fhandlers.push(handler);
            }

        }
        return fhandlers;
    }


    /**
     * sort the handlers by their match start position and then their match end position
     * the further to the left of the uri you are matched - the higher precedence you will have
     * all things being equal - shorter matches take precendence
     */

    function sortHandlers(x:URIHandler, y:URIHandler):Int
    {
        if(x.info.position.pos < y.info.position.pos)
        {
            return -1;
        }
        else if(x.info.position.pos > y.info.position.pos)
        {
            return 1;
        }
        else if(x.info.position.pos == y.info.position.pos)
        {
            if(x.info.position.len < y.info.position.len)
            {
                return -1;
            }
            else if(x.info.position.len > y.info.position.len)
            {
                return 1;
            }
        }
        return 0;
    }
}
