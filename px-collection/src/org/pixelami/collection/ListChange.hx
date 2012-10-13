package org.pixelami.collection;

class ListChange<T>
{
    public var type(default,null):ListChangeType;
    public var item(default,null):T;
    public var index(default,null):Int;

    public function new(type:ListChangeType, ?item:Null<T>, ?index:Int)
    {
        this.type = type;
        this.item = item;
        this.index = index;
    }
}
enum ListChangeType {
    Add;
    Remove;
    Insert;
    Refresh;
    All;
}