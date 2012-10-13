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

    public function generate(t:TypeElement)
    {
        generateChildren(t);
    }

    function _generate(typeElement:TypeElement)
    {
        switch(typeElement.typeInfo.type)
        {
            case haxe.macro.Type.TEnum(t, params): createEnumDefinition(t, params);
            case haxe.macro.Type.TInst(t, params): createTypeDefinition(typeElement, t, params);
            case haxe.macro.Type.TType(t, params): createClassFactoryDefinition(t, params);

            default:
        }

    }

    function generateChildren(t:TypeElement)
    {
        trace(t);

        for(c in t.children)
        {
            _generate(c);
        }

    }

    function createEnumDefinition(t:haxe.macro.Type.Ref<haxe.macro.Type.EnumType>, params : Array<Type>)
    {
        var type:Xml = Xml.createElement("xs:simpleType");
        var restriction:Xml =  Xml.createElement("xs:restriction");
        type.addChild(restriction);
        for(name in t.get().names)
        {
            var enumeration:Xml = Xml.createElement("xs:enumeration");
            enumeration.set("name", name);
            restriction.addChild(enumeration);
        }
    }

    function createTypeDefinition(t:haxe.macro.Type.Ref<haxe.macro.Type.ClassType>, params : Array<Type>)
    {
        var type:Xml = Xml.createElement("xs:complexType");
        type.set("name", t.typeInfo.typeName);
        var sequence = Xml.createElement("xs:sequence");
        type.addChild(sequence);
        for(field in t.typeInfo.fields)
        {
            if(!isProperty(field.kind)) continue;

            var e:Xml = sequence.addChild(Xml.createElement("xs:element"));
            e.set("name", field.name);
            e.set("type", getXsType(field.type));
        }
    }

    function createClassFactoryDefinition(t:haxe.macro.Type.Ref<haxe.macro.Type.DefType>, params : Array<Type>)
    {
        var type:Xml = Xml.createElement("xs:complexType");
        type.set("name", t.typeInfo.typeName);
        var sequence = Xml.createElement("xs:sequence");
        type.addChild(sequence);
        for(field in t.typeInfo.fields)
        {
            if(!isProperty(field.kind)) continue;

            var e:Xml = sequence.addChild(Xml.createElement("xs:element"));
            e.set("name", field.name);
            e.set("type", getXsType(field.type));
        }
    }

    function createAttribute(f:haxe.macro.Type.ClassField, t:haxe.macro.Type)
    {
        var attribute:Xml = Xml.createElement("xs:attribute");
        attribute.set("name", f.name);
        attribute.set("type", getXsType(t));
        attribute.set("default", getDefault(f));
    }


    function isProperty(field:haxe.macro.ClassField):Bool
    {
        return switch(field.kind)
        {
            case haxe.macro.Type.FieldKind.FVar(): true;
            default: false;
        }
    }

    function getXsType(type:haxe.macro.Type):String
    {
        return switch(type)
        {

        }
        trace();
    }

    function write()
    {
        sys.io.File.saveContent("resource/components.xsd");
    }
}
