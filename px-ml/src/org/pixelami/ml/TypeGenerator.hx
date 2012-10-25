package org.pixelami.ml;

import haxe.macro.Expr;
import haxe.macro.Context;
import org.pixelami.xml.macro.MacroTypeInfo;
import org.pixelami.xml.macro.TypeMacroUtil;
import org.pixelami.xml.ElementRegistry;
import org.pixelami.xml.ElementFactory;
import org.pixelami.xml.ElementWalker;

class TypeGenerator
{
    var visited:Hash<Bool>;
    var typeInfos:Hash<MacroTypeInfo>;
    var manifests:Array<String>;

    public function new(manifests:Array<String>)
    {
        this.manifests = manifests;
        trace(manifests);
        visited = new Hash<Bool>();

        var files:Array<String> = [];
        for( p in Context.getClassPath() )
        {
            if( !sys.FileSystem.exists(p) || !sys.FileSystem.isDirectory(p) )  continue;
            //trace(p);
            p = normalizePath(p);
            //trace("normalized path: "+p);
            getMarkupFiles(p, files);
        }
        //trace("files: "+files);

        processManifests();

        var walker:ElementWalker = new ElementWalker();
        var registry:ElementRegistry = new ElementRegistry();

        for(typeInfo in typeInfos.iterator())
        {
            var elementName:String = typeInfo.elementName;
            var type:Class<Dynamic> = TypeElement;
            //trace(typeInfo.elementName);
            //trace(elementName);
            //trace(type);
            registry.mapElementToClass(elementName, type);
        }
        registry.mapElementToClass("hx:Script", ScriptElement);
        //var factory:ReflectingElementFactory = new ReflectingElementFactory(registry);
        var factory:TypeElementFactory = new TypeElementFactory(registry, typeInfos);
        walker.factory = factory;



        for(file in files)
        {
            var generator:CodeGenerator = new CodeGenerator();

            var markup:String = neko.io.File.getContent(file);
            trace("markup: "+markup);
            var xml:Xml = Xml.parse(markup);
            trace(xml.firstElement());
            var elementTree = walker.walk(xml.firstElement());
            //trace(elementTree);
            generator.generate(elementTree);


            var typeName = getTypeName(file);
            var moduleFile = makeModuleFile(file);
            var pack = splitPath(file);
            pack.pop();
            pack.shift();
            generator.packagePath = pack.join(".");

            // create the fields
            var fields:Hash<TypeElement> = generator.publicFields;

            //trace("code: "+code);
            //trace("fields: "+fields);
            generator.moduleName = typeName;


            var source:String = generator.toClassString();
            trace(source);
            neko.io.File.saveContent(moduleFile, source);
            pack.push(typeName);
            var ts = Context.getModule(pack.join("."));
            trace(ts);
        }
    }

    function splitPath(file:String):Array<String>
    {
        var segs = file.split("/");
        if(segs[0] == ".") segs.shift();
        return segs;
    }

    function getTypeName(file:String)
    {
        var lastSlashPos = file.lastIndexOf("/");
        var lastDotPos = file.lastIndexOf(".");
        var idx = lastSlashPos < -1 ? 0 : lastSlashPos + 1;
        return file.substring(idx, lastDotPos);
    }

    function makeModuleFile(file:String):String
    {
        var lastDotPos = file.lastIndexOf(".");
        var moduleFile =  file.substr(0, lastDotPos) + ".hx";
        neko.io.File.saveContent(moduleFile, "");
        return moduleFile;
    }

    function makeTypeDefinition(file:String)
    {
        var segs = splitPath(file);
        var typeName = getTypeName(segs.pop());
        var pos:Position = Context.makePosition({
            min:0, max:0, file:file
        });

        var extendType:TypePath;

        // probably the ids of the declared components
        var fields:Array<Field> = [];

        var td:TypeDefinition = {
            pos:pos,
            params:[],
            pack:segs,
            name:typeName,
            meta:[],
            kind:TDClass(extendType),
            isExtern:true,
            fields:fields
        };

    }

    function getMarkupFiles(directory:String, collector:Array<String>)
    {
        if(!visited.get(directory))
        {
            //trace("visited: "+directory);
            visited.set(directory, true);
        }
        else
        {
            trace("already visited");
            return;
        }

        for( file in neko.FileSystem.readDirectory(directory) )
        {
            if( StringTools.endsWith(file, ".pxml") )
            {
                collector.push(directory + file);
            }
            else if(neko.FileSystem.isDirectory(directory + file) )
            {
                getMarkupFiles(directory + file + "/", collector);
            }
        }
    }

    function normalizePath(path:String):String
    {
        if(!StringTools.startsWith(path, "/") && !StringTools.startsWith(path, "./")) return "./" + path;
        return path;
    }

    function processManifests()
    {
        // we may want to keep this info up in the constructor so that others can
        // access all the processed type info ?
        typeInfos = new Hash<MacroTypeInfo>();

        for(manifest in manifests)
        {
            processManifest(manifest);
        }
    }

    public function processManifest(manifestPath:String)
    {
        var manifest = null;
        try
        {
            manifest = neko.io.File.getContent(manifestPath);
        }
        catch(e:Dynamic)
        {
            trace(e);
        }
        if(manifest == null) return;

        var manifestXML:Xml = Xml.parse(manifest);
        var components = manifestXML.firstElement().elementsNamed("Component");

        for(comp in components)
        {
            //trace("comp: "+comp);
            var typeName = comp.get("class");
            var typeInfo:MacroTypeInfo = TypeMacroUtil.typeInfo(typeName);
            if(typeInfo  == null) continue;
            typeInfo.elementName = comp.get("name");
            trace(typeInfo.elementName);
            typeInfos.set(typeInfo.typeName, typeInfo);
        }


        /*
        if(localClass != null)
        {
            // TODO - find the method field 'processAutoGeneratedMappings' and add the mappings block
            //addMappings(localClass.get(), typeInfos);
        }
        */
    }

	function generateSchema()
	{
		//var schemaGenerator:SchemaGenerator = new SchemaGenerator();

	}
}
