package org.pixelami.uri.processor;

import org.pixelami.uri.URIHandler;

interface IURIHandlerProcessor
{
    var uriHandlerCache:Hash<Array<URIHandler>>;
    var handlers:Array<URIHandler>;
    var filteredHandlers:Array<URIHandler>;

    function setURI(uri:String):Void;
}
