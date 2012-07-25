package org.pixelami.binding;

interface IBindingManager
{
    function createBinding(host:Dynamic, hostProperty:String, listener:Dynamic, listenerProperty:String):Void;
    function updateValue(host:Dynamic, hostProperty:String, value:Dynamic):Void;
    function releaseBinding(host:Dynamic, listener:Dynamic):Void;
}
