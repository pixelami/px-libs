package org.pixelami.collection;
class ArraySet<T> extends Hash<Array<T>>
{
    var map:Hash<Array<T>>;
    public function new()
    {
        map = new Hash<Array<T>>();
    }

    public function add(key:String, value:T):Void
    {
        if(!map.exists(key))
        {
            map.set(key, []);
        }
        map.get(key).push(value);
    }
}
