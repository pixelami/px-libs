package org.pixelami.ml;

import org.pixelami.sys.FileIterator;

class ManifestGenerator
{
    public static function generateFromType(type:String)
    {
        trace(type);
        var t = haxe.macro.Context.getType(type);
        trace(t);


        var classPaths:Array<String> = haxe.macro.Context.getClassPath();


        var modulePaths:Array<String> = [];
        var types:Array<haxe.macro.Type> = [];

        for(cp in classPaths)
        {
            // Due to issue with parsing
            // i.e.
            // /Users/a/dev/lib/haxe/nme/3,4,0/tools/command-line/src/installers/GPHInstaller.hx:1: characters 16-23 : Missing ;
            //
            // have had to remove the haxelib path which kind of makes this a bit useless.
            // The better approach might be not to rely on Context.getModule and instead just use Regex to workout if a Class extends
            // some base visual component and therefore is worth adding to the manifest
            //
            // another approach could be an 'opt in' approach where user explicitly lists classpaths from which to include objects.

            if(StringTools.startsWith(cp,"/Users/a/dev/lib/haxe"))  continue;
            if(StringTools.startsWith(cp,"/Users/a/dev/haxe"))  continue;
            trace(cp);


            var it:HaxeSourceIterator = new HaxeSourceIterator(cp);
            for(hx in it)
            {
                hx = hx.substring(0,hx.lastIndexOf("."));
                if(StringTools.startsWith(hx,cp))
                {
                    var relPath:String;

                    relPath = StringTools.replace(hx,cp,"");
                    //trace(relPath);

                    //modulePaths.push(relPath);
                    var fqcn:String = relPath.split("/").join(".");
                    if(StringTools.startsWith(fqcn,".")) fqcn = fqcn.substring(1);
                    //trace("fqcn: "+fqcn);
                    var moduleTypes:Array<haxe.macro.Type>;
                    try
                    {
                        moduleTypes = haxe.macro.Context.getModule(fqcn);
                    }
                    catch(e:Dynamic)
                    {
                        //trace(e);
                    }
                    if(moduleTypes != null) types = types.concat(moduleTypes);

                }
            }

        }
        trace(types);

    }


    public function new()
    {
    }
}


class HaxeSourceIterator extends FileIterator
{
    public function new(directory:String)
    {
        super(directory);
    }

    override function addFile(path:String)
    {
        if(StringTools.endsWith(path, ".hx")) super.addFile(path);
    }
}