package org.pixelami.util;
class TypedDictionary<KeyT,ValueT>
{
    var keys:Array<KeyT>;
    var values:Array<ValueT>;

    public function new()
    {
        keys = [];
        values = [];
    }

    public function set(key:KeyT, value:ValueT)
    {
        var idx:Int = Lambda.indexOf(keys, key);
        if(idx > -1)
        {
            values.splice(idx,1);
            values.insert(idx,value);
            return;
        }
        keys.push(key);
        values.push(value);
    }

    public function get(key:KeyT):ValueT
    {
        var idx:Int = Lambda.indexOf(keys, key);
        if(idx > -1)
        {
            return values[idx];
        }
        return null;
    }

    public function delete(key:KeyT):Bool
    {
        var idx:Int = Lambda.indexOf(keys, key);
        if(idx > -1)
        {
            keys.splice(idx,1);
            values.splice(idx,1);
            return true;
        }
        return false;
    }

    public function exists(key:KeyT):Bool
    {
        var idx:Int = Lambda.indexOf(keys,key);
        return idx > -1;
    }

    var index:Int;
    public function hasNext():Bool
    {
        if(index < keys.length)
        {
            return true;
        }
        index = 0;
        return false;
    }

    public function next():ValueT
    {
        return values[index];
    }

    public function keysIterator():Iterator<KeyT>
    {
        return keys.iterator();
    }

    public function valuesIterator():Iterator<ValueT>
    {
        return values.iterator();
    }

    public function size():Int
    {
        return keys.length;
    }
}
