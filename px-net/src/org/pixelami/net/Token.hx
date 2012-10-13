package org.pixelami.net;

#if neko
typedef Token = AsyncToken;
#else
typedef Token = DefaultToken;
#end

class DefaultToken
{
    private var responders:Array<Responder>;

    public function new()
    {
        responders = [];
    }

    public function addResponder(responder:Responder):Void
    {
        //trace("adding responder");
        responders.push(responder);
    }

    public function setSuccessPayload(data:Dynamic)
    {
        //trace("setSuccessPayload:"+data);
        while(responders.length > 0)
        {
            var responder:Responder = responders.shift();
            responder.callSuccessHandler(data);
        }
    }

    public function setFailurePayload(data:Dynamic)
    {
        //trace("setFailurePayload:"+data);
        while(responders.length > 0)
        {
            var responder:Responder = responders.shift();
            responder.callFailureHandler(data);
        }
    }
}



#if neko

import neko.vm.Thread;

class AsyncToken extends DefaultToken
{
    public function new()
    {
        super();
    }

    override public function setSuccessPayload(data:Dynamic)
    {
        //trace("setSuccessPayload:"+data);

        Thread.create(function(){
            Sys.sleep(.1);
            while(responders.length > 0)
            {
                var responder:Responder = responders.shift();
                responder.callSuccessHandler(data);
            }
        });


    }

    override public function setFailurePayload(data:Dynamic)
    {
        //trace("setFailurePayload: "+data);

        Thread.create(function(){
            Sys.sleep(.1);
            while(responders.length > 0)
            {
                var responder:Responder = responders.shift();
                responder.callFailureHandler(data);
            }
        });

    }
}
#end
