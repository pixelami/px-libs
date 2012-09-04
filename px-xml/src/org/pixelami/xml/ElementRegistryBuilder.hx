package org.pixelami.xml;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;
import org.pixelami.xml.macro.MacroTypeInfo;
import org.pixelami.xml.macro.TypeMacroUtil;

class ElementRegistryBuilder
{
    static var _instance:ElementRegistryBuilder;

    static inline var AUTO_GENERATE_FIELD_NAME:String = "processAutoGeneratedMappings";
    static inline var ELEMENT_NAME_KEY:String = "name";
    static inline var TYPE_NAME_KEY:String = "class";

    static var pos:Position;


    public static function getInstance():ElementRegistryBuilder
    {
        if(_instance == null) _instance = new ElementRegistryBuilder();
        return _instance;
    }


    var fields:Array<Field>;
    var manifest:String;
    var localClass:haxe.macro.Ref<ClassType>;

    public var typeInfos(default, null):Hash<MacroTypeInfo>;

    public function new()
    {

    }

    public static function buildRegistry():Array<Field>
    {
        pos = Context.currentPos();
        var inst:ElementRegistryBuilder = getInstance();
        return inst.process();
    }

    public function process():Array<Field>
    {
        trace("building ElementRegistry");
        // reset some properties.
        localClass = Context.getLocalClass();
        manifest = null;

        // TODO - support compile time manifest definitions
        // TODO - if we can't support defining namespaces at compile time then use a resources/namespaces folder.
        // TODO - we can also autogenerate the manifest by scanning the class paths.

        try
        {
            // for now we assume manifest is here - resources/manifest.xml
            manifest = neko.io.File.getContent('resources/manifest.xml');
        }
        catch(e:Dynamic)
        {
            Context.warning(e, pos);
        }

        fields = Context.getBuildFields();

        if(manifest != null)
        {
            processManifest();
        }
        return fields;
    }

    public function processManifest()
    {
        var manifestXML:Xml = Xml.parse(manifest);
        var components = manifestXML.firstElement().elementsNamed("Component");

        // we may want to keep this info up in the constructor so that others can
        // access all the processed type info ?
        typeInfos = new Hash<MacroTypeInfo>();

        for(comp in components)
        {
            //trace("comp: "+comp);
            var typeName = comp.get("class");
            var typeInfo:MacroTypeInfo = TypeMacroUtil.typeInfo(typeName);
            if(typeInfo  == null) continue;
            typeInfo.elementName = comp.get("name");
            typeInfos.set(typeInfo.typeName, typeInfo);
        }



        if(localClass != null)
        {
            // TODO - find the method field 'processAutoGeneratedMappings' and add the mappings block
            addMappings(localClass.get(), typeInfos);
        }
    }

    /**
     * Method to auto-generate mappings based on contents of manifest.xml
     * This works by inserting the mappings into the 'processAutoGeneratedMappings' method
     * of the ElementRegistry class.
     * Obviously this works as long as ElementRegistry is a singleton - which is perhaps
     * a little presumptuous in some situations.
     * At some future date it may be necessary to create mappings differently.
    **/

    public function addMappings(registryClass:ClassType, typeInfos:Hash<MacroTypeInfo>)
    {
        var autoGenerateField:Field;
        for(field in fields)
        {
            if(field.name == AUTO_GENERATE_FIELD_NAME)
            {
                autoGenerateField = field;
                break;
            }
        }

        var block:Array<Expr>;
        var newPos:Position;

        switch(autoGenerateField.kind)
        {
            case FFun(f):
                switch(f.expr.expr)
                {
                    case EBlock(exprs):
                        block = exprs;
                        newPos = f.expr.pos;

                    default:
                        trace(f.expr);
                        Context.error("No EBlock found in " + AUTO_GENERATE_FIELD_NAME,pos);

                }

            default:
                Context.error("Expected " + Context.getLocalClass().toString() + " to contain function named "+AUTO_GENERATE_FIELD_NAME,pos);
        }


        if(block != null)
        {
            for(typeInfo in typeInfos.iterator())
            {
                var element:String = "\"" + typeInfo.elementName + "\"";
                trace("element: "+element);
                var clzz:String = typeInfo.typeName;
                trace("clzz: "+clzz);
                var src:String = "mapElementToClass(" + element + ", " + clzz + ")";
                var expr = Context.parse(src, newPos);
                block.push(expr);
            }
        }

    }

    /*
    public function processClassPaths()
    {
        var classPaths:Array<String> = Context.getClassPath();
        for(classPath in classPaths)
        {
            processClassPath(classPath);
        }
    }

    public function processClassPath(classPath:String)
    {

        var files:Array<String> = neko.FileSystem.readDirectory(classPath);

        for(file in files)
        {
            if(neko.FileSystem.isDirectory(file))
            {
                processClassPath(classPath + "/" + file);
            }
        }
    }
    */
}
/*
class ClassPathIterator
{
    var dirs:Array<String>;

    public function new(classPath:String)
    {
        dirs = [];
    }

    public function next():String
    {

    }

    public function hasNext():Bool
    {
        if(dirs.length == 0)
        {

        }
    }


}
*/