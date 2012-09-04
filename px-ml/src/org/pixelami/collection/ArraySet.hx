package org.pixelami.collection;
class ArraySet<T> extends Hash<Array<T>>
{
    public function new()
    {
        super();
    }

    public function add(key:String, value:T):Void
    {
        if(!exists(key))
        {
            set(key, []);
        }
        get(key).push(value);
    }
}
