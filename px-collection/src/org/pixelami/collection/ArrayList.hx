package org.pixelami.collection;

import org.pixelami.collection.ListChange;
import msignal.Signal;

class ArrayList<T> implements IList<T>
{
    var array:Array<T>;

    public var length(get_length,null):Int;
    function get_length():Int
    {
        return array.length;
    }

    public var change(default,null):msignal.Signal1<ListChange<T>>;

    public function getItemAt(index:Int):T
    {
        return array[index];
    }

    public function new(?array:Array<T>)
    {
        change = new msignal.Signal1<ListChange<T>>();
        this.array = array == null ? [] : array;
    }

    public function addItem(item:T)
    {
        array.push(item);
        change.dispatch(new ListChange(ListChangeType.Add, item, 0));
    }

    public function addItemAt(index:Int, item:T)
    {
        if(array.length < index - 1) throw "RangeError: the index you are attempting to insert at does not exist in this instance";
        array.insert(index, item);
        change.dispatch(new ListChange(ListChangeType.Insert, item, index));
    }

    public function removeItem(value:T)
    {
        var idx:Int = Lambda.indexOf(array, value);
        var items:Array<T> = array.splice(idx,1);
        change.dispatch(new ListChange(ListChangeType.Remove, items[0], idx));
    }

    public function removeItemAt(index:Int):T
    {
         var items:Array<T> = array.splice(index,1);
        change.dispatch(new ListChange(ListChangeType.Remove, items[0], index));
        return items[0];
    }

    public function removeAll()
    {
        array = [];
        change.dispatch(new ListChange(ListChangeType.All));
    }

    public function setItemAt(index:Int, item:T)
    {
        array[index] = item;
        change.dispatch(new ListChange(ListChangeType.Refresh,item, index));
    }
}
