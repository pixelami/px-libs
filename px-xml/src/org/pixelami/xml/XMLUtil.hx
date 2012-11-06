package org.pixelami.xml;

class XMLUtil
{
    public static function parseHexValue(value:String):Int
    {
        return Std.parseInt(value.substr(1, value.length));
    }

    public static function parsePercentageValue(value:String):Float
    {
        return Std.parseFloat(value.substr(0, value.length - 1));
    }

	public static function toString(xml:Xml):String
	{
		var buf:StringBuf = new StringBuf();
		appendNode(xml.firstChild(), buf, 0);
		return buf.toString();
	}

	static function appendNode(node:Xml, buf:StringBuf, depth:Int)
	{
		switch(node.nodeType)
		{
			case Xml.Element, Xml.Document:

				createIndent(depth,buf);

				var closeTag = !node.iterator().hasNext();
				buf.add(tagToString(node, closeTag));
				buf.add("\n");
				if(!closeTag)
				{
					depth ++;
					for(childNode in node.iterator())
					{
						appendNode(childNode, buf, depth);
					}
					depth --;

					createIndent(depth,buf);
					buf.add("</" + node.nodeName + ">");
					buf.add("\n");
				}

			default:

				createIndent(depth, buf);
				buf.add(node.nodeValue);
				buf.add("\n");

		}
	}

	static function tagToString(node:Xml, closeTag:Bool):String
	{
		var b:StringBuf = new StringBuf();
		b.add("<");
		b.add(node.nodeName);
		b.add(" ");
		var attributes:Array<String> = [];
		for(att in node.attributes())
		{
			attributes.push(att + "=\"" + node.get(att) + "\"");
		}
		b.add(attributes.join(" "));
		b.add(closeTag ? " />" : ">");
		return b.toString();
	}

	static function createIndent(size:Int, buf:StringBuf)
	{
		return for(i in 0...size) buf.add("\t");
	}
}
