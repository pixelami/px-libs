import pixelami.chrome.WebSocketClient;
import pixelami.chrome.ChromeDebuggerClient;

class Main
{

    public static function main()
    {
        var c:ChromeDebuggerClient<WebSocketClient> =
            new ChromeDebuggerClient<WebSocketClient>("http://localhost:9222/json", WebSocketClient);
        c.connectToTab("http://localhost:8000/poster-canvas.html");

        var r = c.sendCommand("Runtime.evaluate",{expression:"a=1", objectGroup: "test", returnByValue: true});
        trace(r);
    }

    public function new()
    {
    }
}
