package org.pixelami.ml;

import org.pixelami.ml.schema.Element;

class SchemaGenerator
{
    var document:Xml;
    var schema:Xml;

    public function new()
    {
        document = Xml.createDocument();
        schema = Xml.createElement("xs:schema");
        document.addChild(schema);
    }

    public function generate(t:haxe.macro.Type)
    {
        //generateChildren(t.get());
		_generate(t);
    }

    function _generate(t:haxe.macro.Type)
    {
        switch(t)
        {
            case haxe.macro.Type.TEnum(t, params): createEnumDefinition(t, params);
            case haxe.macro.Type.TInst(t, params): createTypeDefinition(t, params);
            case haxe.macro.Type.TType(t, params): createClassFactoryDefinition(t, params);

            default:
        }

    }
/*

    function generateChildren(t:haxe.macro.Type)
    {
        trace(t);

        for(c in t.fields)
        {
            _generate(c);
        }

    }
*/

    function createEnumDefinition(t:haxe.macro.Type.Ref<haxe.macro.Type.EnumType>, params : Array<haxe.macro.Type>)
    {
        var type:Xml = Xml.createElement("xs:simpleType");
        var restriction:Xml =  Xml.createElement("xs:restriction");
        type.addChild(restriction);
		var cType:haxe.macro.Type.EnumType = t.get();
		type.set("name", cType.pack.concat([cType.name]).join("."));
        for(name in t.get().names)
        {
            var enumeration:Xml = Xml.createElement("xs:enumeration");
            enumeration.set("name", name);
            restriction.addChild(enumeration);
        }
		schema.addChild(type);
    }

    function createTypeDefinition(t:haxe.macro.Type.Ref<haxe.macro.Type.ClassType>, params : Array<haxe.macro.Type>)
    {
        var type:Xml = Xml.createElement("xs:complexType");
		var cType:haxe.macro.Type.ClassType = t.get();
        type.set("name", cType.pack.concat([cType.name]).join("."));
        var sequence = Xml.createElement("xs:sequence");
        type.addChild(sequence);


		for(field in cType.fields.get())
        {
            if(!isProperty(field)) continue;

            //var e:Xml = Xml.createElement("xs:element");
			//sequence.addChild(e);
            //e.set("name", field.name);
            //e.set("type", getXsType(field.type));

			var a:Xml = Xml.createElement("xs:attribute");
			a.set("name", field.name);
			a.set("type", getXsType(field.type));
			type.addChild(a);
        }
		schema.addChild(type);
    }

    function createClassFactoryDefinition(t:haxe.macro.Type.Ref<haxe.macro.Type.DefType>, params : Array<haxe.macro.Type>)
    {
        var type:Xml = Xml.createElement("xs:complexType");
        type.set("name", t.get().name);
        var sequence = Xml.createElement("xs:sequence");
        type.addChild(sequence);
		var d:haxe.macro.Type.DefType = t.get();

		/*
        for(field in t.get().fields)
        {
            if(!isProperty(field)) continue;

            var e:Xml = Xml.createElement("xs:element");
			sequence.addChild(e);
            e.set("name", field.name);
            e.set("type", getXsType(field.type));
        }
        */
    }

    function createAttribute(f:haxe.macro.Type.ClassField, t:haxe.macro.Type)
    {
        var attribute:Xml = Xml.createElement("xs:attribute");
        attribute.set("name", f.name);
        attribute.set("type", getXsType(t));
        attribute.set("default", getDefault(f));
    }


    function isProperty(field:haxe.macro.Type.ClassField):Bool
    {
        //if(field.isPublic) return true;

		return switch(field.kind)
        {
            case haxe.macro.Type.FieldKind.FVar(r,w): if(field.isPublic) return true;
            default: false;
        }
    }

    function getXsType(type:haxe.macro.Type):String
    {
        return switch(type)
        {
			case haxe.macro.Type.TType(t, params):
				var def:haxe.macro.Type.DefType = t.get();
				getXsType(def.type);

			case haxe.macro.Type.TInst(t, params):
				var type:haxe.macro.Type.ClassType = t.get();
			    type.pack.concat([type.name]).join(".");

			case haxe.macro.Type.TEnum(t, params):
				var type:haxe.macro.Type.EnumType = t.get();
				type.pack.concat([type.name]).join(".");

			case haxe.macro.Type.TMono(t): null;
			case haxe.macro.Type.TFun(a, ret): null;
			case haxe.macro.Type.TAnonymous(a): null;
			case haxe.macro.Type.TLazy(f): getXsType(f());



			case haxe.macro.Type.TDynamic(t): if(t != null) getXsType(t);


        }

    }

    function write()
    {
        sys.io.File.saveContent("resource/components.xsd","<content/>");
    }

	function toString()
	{
		return document.toString();
	}

	function getDefault(t:Dynamic):Dynamic
	{
		return null;
	}
}
