package org.pixelami.collection;

import massive.munit.Assert;

class ArrayListTest
{
    var arrayList:ArrayList<Dynamic>;

    @Before
    public function before()
    {
       arrayList = new ArrayList<Dynamic>();
    }

    @Test
    public function addItemTest()
    {
        var o = {id:1};
        arrayList.addItem(o);
        Assert.isTrue(arrayList.length == 1);
        Assert.isTrue(arrayList.getItemAt(0) == o);
    }

    @Test
    public function addItemAtShouldInsertIntoArrayTest()
    {
        var o = {id:1};
        var o2 = {id:2};
        arrayList.addItem(o);
        arrayList.addItem(o);
        arrayList.addItem(o);
        arrayList.addItemAt(0,o2);

        Assert.isTrue(arrayList.getItemAt(0) == o2);
        Assert.isTrue(arrayList.length == 4);
    }

    @Test
    public function addItemAtShouldFailWhenOutOfRangeTest()
    {
        var o = {id:1};
        try
        {
            arrayList.addItemAt(5,o);
        }
        catch(e:Dynamic)
        {
            Assert.isTrue(Std.string(e).indexOf("RangeError") > -1);
            return;
        }
        Assert.fail("Expected RangeError to be thrown");
    }

    @Test
    public function removeItemTest()
    {
        var o = {id:1}
        arrayList.addItem(o);
        arrayList.removeItem(o);

        Assert.isTrue(arrayList.length == 0);
    }


    @Test
    public function removeItemAtTest()
    {
        arrayList.addItem({id:1});
        arrayList.removeItemAt(0);
    }

    @Test
    public function removeAllTest()
    {
        arrayList.addItem({id:1});
        arrayList.addItem({id:1});
        arrayList.addItem({id:1});
        arrayList.removeAll();
    }

    @Test
    public function setItemAtTest()
    {
        arrayList.setItemAt(0,{id:1});
    }
}
