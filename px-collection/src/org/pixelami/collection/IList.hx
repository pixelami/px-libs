package org.pixelami.collection;

import msignal.Signal;

interface IList<T>
{
    function addItem(item:T):Void;
    function addItemAt(index:Int, item:T):Void;
    function removeItem(value:T):Void;
    function removeItemAt(index:Int):T;
    function removeAll():Void;
    function getItemAt(index:Int):T;
    function setItemAt(index:Int, item:T):Void;
    var change(default,null):Signal1<ListChange<T>>;
}
