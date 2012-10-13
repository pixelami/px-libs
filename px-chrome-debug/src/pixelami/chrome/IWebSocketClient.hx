package pixelami.chrome;
import haxe.io.Bytes;
interface IWebSocketClient
{
    var onConnect:Void->Void;
    var onError:String->Void;
    var onData:Dynamic->Void;
    var onConnectFail:String->Void;

    var connectionState:ConnectionState;

    function connect(url:String):Void;
    function send(data:Dynamic):Bool;

}
