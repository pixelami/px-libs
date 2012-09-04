package org.pixelami.sys;

class FileIterator
{
    var files:Array<String>;
    var pos:Int;

    public function new(directory:String)
    {
        files = [];
        pos = 0;
        scan(directory);
    }

    public function hasNext():Bool
    {
        return pos < files.length;
    }

    public function next():String
    {
         return files[pos++];
    }

    function scan(path:String)
    {
        var _files = sys.FileSystem.readDirectory(path);
        for(f in _files)
        {
            var fp = path+ "/" + f;
            if(sys.FileSystem.isDirectory(fp))
            {
                 scan(fp);
            }
            else
            {
                addFile(fp);
            }
        }
    }

    function addFile(path:String)
    {
        files.push(path);
    }

}
