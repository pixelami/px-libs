package org.pixelami.net;
class TypedToken<TResult,TError>
{
    private var responders:Array<Responder<TResult, TError>>;

    public function new()
    {
        responders = [];
    }

    public function addResponder(responder:Responder<TResult, TError>):Void
    {
        //trace("adding responder");
        responders.push(responder);
    }

    public function setSuccessPayload(data:TResult)
    {
        //trace("setSuccessPayload:"+data);
        while(responders.length > 0)
        {
            var responder:Responder = responders.shift();
            responder.callSuccessHandler(data);
        }
    }

    public function setFailurePayload(data:TError)
    {
        //trace("setFailurePayload:"+data);
        while(responders.length > 0)
        {
            var responder:Responder<TResult, TError> = responders.shift();
            responder.callFailureHandler(data);
        }
    }
}
