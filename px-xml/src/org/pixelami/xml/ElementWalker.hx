package org.pixelami.xml;

class ElementWalker
{
    public var factory:IInstanceFactory;
    public var instanceIndex:Hash<Dynamic>;
    public var namespaceIndex:Hash<Dynamic>;
    public var duplicateIdWarnings:Bool;
	public var strict:Bool;

    public function new(?strict=true)
    {
        this.strict = strict;
		instanceIndex = new Hash<Dynamic>();
    }

    public function walk(el:Xml,parent:Dynamic=null):Dynamic
    {
        var inst:Dynamic = null;
        var node:Xml = el;

        if(node.nodeType != Xml.Element) node = node.firstElement();

        /*
        if(node.nodeType == Xml.Document)
        {
            trace("pointing document to first element") ;
            try
            {
                node = node.firstChild();
                if(node.firstChild().nodeType == Xml.Prolog)
                {
                    node = node.firstElement();
                }
            }
            catch(e:Dynamic)
            {
                //if(e != "Invalid call") trace(e);
            }
        }
        */

        if(node.nodeType == Xml.Element)
        {
            try
            {
                inst = factory.createInstance(node);

                if(node.exists("id"))
                {
                    var nodeId:String = node.get("id");
                    if(duplicateIdWarnings)
                    {
                        if(instanceIndex.exists(nodeId)) trace("WARNING: duplicate id for: "+nodeId);
                    }
                    instanceIndex.set(nodeId, inst);
                }
            }
            catch (e:Dynamic)
            {
                 #if debug
                 //trace(e);
                 #end
            }
        }

        if(inst != null)
        {
            var defaultChildProperty:String = getDefaultChildrenField(inst);
            if(hasField(inst,defaultChildProperty))
            {
                var children:Array<Dynamic> = walkChildren(node,inst);

                if(children.length > 0)
                {
                    Reflect.setProperty( inst, defaultChildProperty , children );
                }
            }

            // if parent is null then take the inst and keep going
            else
            {
                for(e in node.elements())
                {
                    //trace(e);
                    walk(e,inst);
                }
            }
        }
        else
        {
            var parentProperty:String = "";
            // check if we're a parent property
            try
            {
                parentProperty = node.nodeName;

                if(node.nodeName.indexOf(":") > -1)
                {

                    parentProperty = node.nodeName.split(":")[1];
                }
            }
            catch(e:Dynamic)
            {
                //trace(e);
            }



            if(hasField(parent,parentProperty))
            {
                // our parent owns this field so pass the children on to it
                var children:Array<Dynamic> = walkChildren(node,parent);

                if(children.length > 0)
                {
					factory.setProperty(parent, parentProperty, children);

                }
                else
                {
                    if(node.firstChild() != null && node.firstChild().nodeType == Xml.PCData)
                    {
						factory.setProperty(parent, parentProperty, node.firstChild().toString());
                    }
                }
            }
            else
            {
                var msg =  parent + " has no field '" + parentProperty + "'";
				//trace("Warning: " + msg);
				if(strict)
				{

                    var e:ElementFactoryException = new ElementFactoryException(node, msg);
					throw e;
				}
                // keep walking - at this stage we are allowing very loose mapping
                for(e in node.elements())
                {
                    //trace(e);
                    walk(e,parent);
                }
            }
        }

        return inst;
    }

    function walkChildren(element:Xml,parent:Dynamic):Array<Dynamic>
    {
        var c:Array<Dynamic> = new Array<Dynamic>();
        for(e in element.elements())
        {
            var inst:Dynamic = walk(e,parent);
            if(inst != null)
            {
                c.push(inst);
            }
        }
        return c;
    }

    public function getDefaultChildrenField(instance:Dynamic):String
    {
        var m = haxe.rtti.Meta.getType(Type.getClass(instance));
        var defaultChildrenField = Reflect.getProperty(m,"defaultProperty");
        if(defaultChildrenField == null) defaultChildrenField = "children";
        return defaultChildrenField;
    }

    function hasField(inst:Dynamic,field:String):Bool
    {
        if(inst == null) return false;

		var type:Class<Dynamic> = Type.getClass(inst);
		var instanceFields:Array<String> = Type.getInstanceFields(type);
		for(i in 0...instanceFields.length)
		{
			if(instanceFields[i] == field)
			{
				return true;
			}
		}

		if(Std.is(inst,ITypeDescriptor))
		{
			return cast(inst, ITypeDescriptor).hasField(field);
		}

		return false;


    }
}
