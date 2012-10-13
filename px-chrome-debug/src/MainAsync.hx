import pixelami.chrome.WebSocketClient;
import pixelami.chrome.WebSocketClientAsync;
import pixelami.chrome.ChromeDebuggerClient;

class MainAsync
{

    public static var thread(default,null):neko.vm.Thread;


    public static function main()
    {
        //thread = neko.vm.Thread.current();

        var c:ChromeDebuggerClient<WebSocketClientAsync> = new ChromeDebuggerClient<WebSocketClientAsync>("http://localhost:9222/json", WebSocketClientAsync);
        c.connectToTab("http://localhost:8000/poster-canvas.html");

        var r = c.sendCommand("Runtime.evaluate", {expression:"pageModel", objectGroup: "test", returnByValue: true});
        trace(r);

        /*
        while(true)
        {
            //neko.vm.Thread.readMessage(true);
        }
        */
        neko.vm.Thread.readMessage(true);
    }
}
