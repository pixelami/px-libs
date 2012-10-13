package pixelami.chrome;

import haxe.io.Bytes;

class WebSocketFrame
{

    public var fin:Bool;
    public var rsv:Int;
    public var opcode:Int;
    public var payload:Bytes;

    // Fields below are not used when used as a parameter of sendFrame().
    public var length:Int;
    public var mask:Bool;

    public function new()
    {
        fin = true;
        rsv = 0;
        opcode = -1;
        length = 0;
        mask = false ;
    }

}
