package org.pixelami.net;

class TypedResponder<TResult, TError>
{
    var success:TResult->Void;
    var failure:TError->Void;

    public function new(success:TResult->Void, failure:TError->Void)
    {
        this.success = success;
        this.failure = failure;
    }

    public function callSuccessHandler(data:TResult)
    {
        //trace("success");
        success(data);
    }

    public function callFailureHandler(data:TError)
    {
        //trace("fail:"+data);
        failure(data);
    }
}
