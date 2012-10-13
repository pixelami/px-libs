package org.pixelami.net;

class Responder
{
    var success:Dynamic->Void;
    var failure:Dynamic->Void;

    public function new(success:Dynamic->Void, failure:Dynamic->Void)
    {
        this.success = success;
        this.failure = failure;
    }

    public function callSuccessHandler(data:String)
    {
        //trace("success");
        success(data);
    }

    public function callFailureHandler(data:String)
    {
        //trace("fail:"+data);
        failure(data);
    }
}