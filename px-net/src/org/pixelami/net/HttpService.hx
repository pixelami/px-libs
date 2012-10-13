package org.pixelami.net;

import haxe.Http;

class HttpService implements AsyncService
{
    private var token:Token;


    public function new()
    {
    }

    public function get(url:String):Token
    {
        var token = new Token();
        var r:Http = new Http(url);


        r.onData = token.setSuccessPayload;
        r.onError = function(error:String)
        {
            token.setFailurePayload({msg:error, url:url});
        }
        r.request(false);



        return token;
    }

    public function post(url:String, params:Hash<String>, headers:Array<String>):Token
    {
        var token = new Token();
        var r:Http = new Http(url);


        r.onData = token.setSuccessPayload;
        r.onError = function(error:String)
        {
            token.setFailurePayload({msg:error, url:url});
        }
        r.request(true);
        return token;
    }

    public function sendMultipart(url:String, multipart:MultipartFormData):Token
    {
        var token = new Token();
        var r:Http = new Http(url);

        var formadata:String = multipart.encodeMultipartFormaData();

        r.onData = token.setSuccessPayload;
        r.onError = token.setFailurePayload;
        r.setHeader("content-type", multipart.getContentType());
        //r.setHeader("content-length", Std.string(formadata.length));

        r.setPostData(formadata);
        r.request(true);
        return token;
    }
}
