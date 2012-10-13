package pixelami.chrome;
import haxe.Json;

typedef Error = {
    error: { code:Int, message:String, id:Dynamic}
}

typedef Response = {
    result:Dynamic,
    error:Error
}

typedef PageInfo = {
    devtoolsFrontendUrl:String,
    faviconUrl: String,
    thumbnailUrl: String,
    title: String,
    url: String,
    webSocketDebuggerUrl: String
}

typedef PayloadHandlerTuple = {
    payload:Dynamic,
    handler:Dynamic
}


class ChromeDebuggerClient<T:IWebSocketClient>
{
    static var ID_COUNTER:Int = 0;

    var pageUrl:String;
    var webSocketDebuggerUrl:String;
    var wsClient:IWebSocketClient;
    var socketUrl:String;
    var webSocketImpl:Class<T>;

    public function new(socketUrl:String, webSocketImpl:Class<T>)
    {
        this.socketUrl = socketUrl;
        this.webSocketImpl = webSocketImpl;
    }

    public function connectToTab(pageUrl:String)
    {
        this.pageUrl = pageUrl;
        var r = new haxe.Http(socketUrl);
        r.onData = onPageData;
        r.onError = onError;
        r.request(false);
    }

    function onPageData(data:String)
    {
        var pages:Array<PageInfo> = Json.parse(data);
        var found:Bool = false;
        for(pageInfo in pages)
        {
            if(pageInfo.url == pageUrl)
            {
                webSocketDebuggerUrl = pageInfo.webSocketDebuggerUrl;
                found = true;
                break;
            }
        }

        if(!found)
        {
            onError("Page not found: "+pageUrl);
        }

        trace(webSocketDebuggerUrl);

        // Beware of creating IWebSocket implementations that take constructor arguments....
        // They would need to be supplied here.
        wsClient = Type.createInstance(webSocketImpl,[]);
        wsClient.onConnect = onConnect;
        wsClient.onConnectFail = onConnectFail;
        wsClient.onError = onError;
        wsClient.onData = onData;
        wsClient.connect(webSocketDebuggerUrl);
    }

    function delayed(f, time) {
        neko.vm.Thread.create(function() {
            neko.Sys.sleep(time);
            f();
        });
    }



    function onConnect():Void
    {
        trace("Connected to: "+webSocketDebuggerUrl);
    }

    function onConnectFail(error:String)
    {
        trace(error);
    }

    function onData(data:Dynamic):Void
    {
        trace(data);
        try
        {
            var result = haxe.Json.parse(data);
            trace(result);
        }
        catch(e:Dynamic)
        {
            onError(e);
        }


    }

    function onError(error:String)
    {
        trace(error);
    }

    public function sendCommand(method:String, params:Dynamic):Dynamic
    {
        var p = createPayload(method, params);
        var json:String = haxe.Json.stringify(p);

        if(wsClient.connectionState == ConnectionState.Connected)
        {
            var sent = wsClient.send(json);

            // For debugging last response
            //neko.io.File.saveContent("json.txt",str);

//            var o = haxe.Json.parse(str);
//            return o;
        }

        return null;

    }


    function createPayload(method:String, params:Dynamic):Dynamic
    {
        var p = {
            id: ID_COUNTER++,
            method:method,
            params:params
        }

        return p;
    }

}


