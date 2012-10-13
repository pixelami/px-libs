// Based on web-socket-js by Hiroshi Ichikawa <http://gimite.net/en/>
// License: New BSD License
// Reference: http://dev.w3.org/html5/websockets/
// Reference: http://tools.ietf.org/html/rfc6455


package pixelami.chrome;

import haxe.io.Input;
import haxe.io.Bytes;
import haxe.io.BytesOutput;


/*
Sample Handshake captured from Chrome Debugger

GET /devtools/page/13_1 HTTP/1.1
Upgrade: websocket
Connection: Upgrade
Host: localhost:9222
Origin: http://localhost:9222
Sec-WebSocket-Key: 8M8/PgfUToU1opLyjJOQmQ==
Sec-WebSocket-Version: 13
Sec-WebSocket-Extensions: x-webkit-deflate-frame



HTTP/1.1 101 WebSocket Protocol Handshake
Upgrade: WebSocket
Connection: Upgrade
Sec-WebSocket-Accept: 6Z71Dkm10ZB0xiKHN+eZ929yCVo=
*/


class WebSocketClient implements IWebSocketClient
{
    static inline var WEB_SOCKET_GUID:String = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

    /*
    static inline var CONNECTING:Int = 0;
    static inline var OPEN:Int = 1;
    static inline var CLOSING:Int = 2;
    static inline var CLOSED:Int = 3;
    */
    static inline var OPCODE_CONTINUATION:Int = 0x00;
    static inline var OPCODE_TEXT:Int = 0x01;
    static inline var OPCODE_BINARY:Int = 0x02;
    static inline var OPCODE_CLOSE:Int = 0x08;
    static inline var OPCODE_PING:Int = 0x09;
    static inline var OPCODE_PONG:Int = 0x0a;

    static inline var STATUS_NORMAL_CLOSURE:Int = 1000;
    static inline var STATUS_NO_CODE:Int = 1005;
    static inline var STATUS_CLOSED_ABNORMALLY:Int = 1006;
    static inline var STATUS_CONNECTION_ERROR:Int = 5000;



    var socket:neko.net.Socket;

    public var connectionState:ConnectionState;

    public var onConnect:Void->Void;
    public var onError:String->Void;
    public var onData:Dynamic->Void;

    var url(default,set_url):String;
    function set_url(value:String):String
    {
        var pos:Int = -1;
        pos = value.indexOf(":");
        if(pos == -1) throw 'new MalformedURL("uri schema not detected (requires ws or wss)")';
        protocol = value.substring(0,pos);
        var s = value.indexOf("//");
        pos = value.indexOf("/",s+2);
        host = value.substring(s, pos);
        uri = value.substr(pos);
        return url = value;
    }

    var host:String;
    var uri:String;
    var protocol:String;

    public function new()
    {
        socket = new neko.net.Socket();
    }

    public function connect(socketUrl:String)
    {
        neko.Lib.println("connect");
        connectionState = ConnectionState.Connecting;
        url = socketUrl;

        socket.connect(new neko.net.Host("localhost"), 9222);
        //socket.setTimeout(10);


        socket.output.write(createWebSocketConnectionHeader());
        socket.output.flush();

        var response:HTTPResponse = parseConnectionResponse();

        if(response.status == "101")
        {
            connectionState = ConnectionState.Connected;
            onConnect();
        }
        else
        {
            // something bad happened
            connectionState = ConnectionState.ConnectionFailed;
        }
    }

    function parseConnectionResponse():HTTPResponse
    {

        var hLines:Array<String> = [];
        var hLine:String;
        while((hLine = this.socket.input.readLine()) != "")
        {
            hLines.push(hLine);
        }

        var headers:Hash<String> = new Hash<String>();
        var line0 = hLines.shift();
        var line0Segs:Array<String> = line0.split(" ");
        var httpStatus = line0Segs[1];
        trace(line0Segs);
        for(h in hLines)
        {
            var index:Int = h.indexOf(":");
            var key = h.substring(0,index);
            var value = h.substr(index+1);
            headers.set(key, StringTools.trim(value));
        }

        return { headers: headers, status: httpStatus };
    }

    public function send(data:Dynamic):Dynamic
    {
        var f:WebSocketFrame = new WebSocketFrame();
        f.mask = true;

        var payloadBytes:BytesOutput = new BytesOutput();

        if(Std.is(data, String))
        {
            payloadBytes.writeString(data);
            f.payload = payloadBytes.getBytes();
            f.opcode = OPCODE_TEXT;
        }

        if(sendFrame(f))
        {
            return readSocket();
        }
        return null;
    }

    public function sendBytes(data:Bytes):Dynamic
    {
        var f:WebSocketFrame = new WebSocketFrame();
        f.mask = true;

        var payloadBytes:BytesOutput = new BytesOutput();

        payloadBytes.write(data);
        f.payload = payloadBytes.getBytes();
        f.opcode = OPCODE_BINARY;

        if(sendFrame(f))
        {
            return readSocket();
        }
        return null;
    }

    function createWebSocketConnectionHeader():Bytes
    {
        var clientInfo = socket.host();

        var request:BytesOutput = new BytesOutput();
        request.writeString("GET " + uri + " HTTP/1.1\r\n");
        request.writeString("Upgrade: websocket\r\n");
        request.writeString("Connection: Upgrade\r\n");
        request.writeString("Host: " + host + "\r\n");
        request.writeString("Origin: http://" + clientInfo.host.toString() + "\r\n");
        request.writeString("Sec-WebSocket-Key: " + generateKey() + "\r\n");
        request.writeString("Sec-WebSocket-Version: 13\r\n");
        request.writeString("\r\n");

        return request.getBytes();
    }

    function readSocket():Dynamic
    {
        trace("reading socket...");

        var f = parseFrame();
        var payload:Dynamic = null;
        switch(f.opcode)
        {
            case OPCODE_TEXT: payload = neko.Lib.stringReference(f.payload);
            case OPCODE_BINARY: payload = f.payload;
            case OPCODE_CLOSE: connectionState = ConnectionState.Closed;
            default:
        }
        return payload;
    }



    function sendFrame(frame:WebSocketFrame):Bool
    {
        var plength:Int = frame.payload.length;

        // Generates a mask.
        var mask:BytesOutput = new BytesOutput();
        for(i in 0...4)
        {
            mask.writeByte(randomInt(0, 255));
        }

        var header:BytesOutput = new BytesOutput();
        // FIN + RSV + opcode
        header.writeByte((frame.fin ? 0x80 : 0x00) | (frame.rsv << 4) | frame.opcode);
        if(plength <= 125)
        {
            header.writeByte(0x80 | plength); // Masked + length
        }
        else if(plength > 125 && plength < 65536)
        {
            header.writeByte(0x80 | 126); // Masked + 126
            header.writeInt16(plength);
        }
        else if(plength >= 65536 && plength < 4294967296)
        {
            header.writeByte(0x80 | 127); // Masked + 127
            header.writeUInt16(0); // zero high order bits
            header.writeUInt16(plength);
        }
        else
        {
            trace("Send frame size too large");
        }
        var maskBytes:Bytes = mask.getBytes();
        header.writeBytes(maskBytes, 0, maskBytes.length);

        var maskedPayload:BytesOutput = new BytesOutput();
        maskedPayload.prepare(plength);


        var payloadBytes:Bytes = frame.payload;


        for(i in 0...plength)
        {
            maskedPayload.writeByte(maskBytes.get(i % 4) ^ payloadBytes.get(i));
        }

        try
        {
            var output:BytesOutput = new BytesOutput();
            output.write(header.getBytes());
            output.write(maskedPayload.getBytes());
            socket.output.write(output.getBytes());
            socket.output.flush();
        }
        catch(ex:Dynamic)
        {
            trace("Error while sending frame: " + ex.message);
            /*
            delayed(function():Void
            {

                trace("delayed connecton error");
            }, 0);*/

            return false;
        }
        return true;

    }


    function parseFrame():WebSocketFrame
    {
        var input:Input = socket.input;


        var hlength:Int = 0;
        var plength:Int = 0;
        var frame:WebSocketFrame = new WebSocketFrame();


        var b0:Int = input.readByte();
        frame.fin = (b0 & 0x80) != 0;
        frame.rsv = (b0 & 0x70) >> 4;
        frame.opcode = b0 & 0x0f;
        trace("opcode: "+frame.opcode);
        // Payload unmasking is not implemented because masking frames from server
        // is not allowed. This field is used only for error checking.
        var b1:Int = input.readByte();
        frame.mask = (b1 & 0x80) != 0;
        plength = b1 & 0x7f;

        hlength = 2;
        // TODO - can't throw this error

        trace("plength: "+plength);

        if(plength == 126)
        {
            hlength = 4;
            input.bigEndian = true;
            plength = input.readUInt16();
        }
        else if(plength == 127)
        {
            hlength = 10;
            input.bigEndian = true;
            // Protocol allows 64-bit length, but we only handle 32-bit
            var big:Int = haxe.Int32.toInt(input.readInt32()); // Skip high 32-bits
            plength = haxe.Int32.toInt(input.readInt32()); // Low 32-bits
            if(big != 0)
            {
                trace("Frame length exceeds 4294967295. Bailing out!");
                return null;
            }

        }

        frame.length = hlength + plength;
        frame.payload = Bytes.alloc(plength);
        // we already read 2 bytes
        //input.read( hlength - 2 );
        input.readBytes(frame.payload, 0, plength);
        return frame;

    }

    function randomInt(min:Int, max:Int):Int
    {
        return min + Math.floor(Math.random() * ( cast(max, Float) - min + 1));
    }

    private function generateKey():String
    {
        var vals:Bytes = Bytes.alloc(16);
        for(i in 0...vals.length)
        {
            vals.set(i, randomInt(0, 127));
        }
        return haxe.Serializer.run(vals);
    }
}