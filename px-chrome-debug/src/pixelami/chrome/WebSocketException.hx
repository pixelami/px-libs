package pixelami.chrome;

class WebSocketException
{
    var msg:String;
    var inf:haxe.PosInfos;

    public function new(msg, ?inf:haxe.PosInfos)
    {
        this.msg = msg;
        this.inf = inf;
    }

    public function toString():String
    {
        return msg;
    }
}
