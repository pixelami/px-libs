package org.pixelami.xml;

/*
<?xml version="1.0"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xs:element name="note">
  <xs:complexType>
    <xs:sequence>
      <xs:element name="to" type="xs:string"/>
      <xs:element name="from" type="xs:string"/>
      <xs:element name="heading" type="xs:string"/>
      <xs:element name="body" type="xs:string"/>
    </xs:sequence>
  </xs:complexType>
</xs:element>

</xs:schema>
 */

class SchemaFactory
{


    public function new()
    {
    }


    function createSchemaElement(name:String, object:Dynamic)
    {
        var e:Xml = Xml.createElement("element");
        e.set("name",name);
        var t:Xml = Xml.createElement("complexType");
        e.addChild(t);
        var s:Xml = Xml.createElement("sequence");
        t.addChild(s);
        for(field in Reflect.fields)
        {

        }


    }
}
