package util;

class ObjectUtil
{
	static inline var INDENT:String = "    ";
	static var ref:Array<Dynamic> = [];
	static var refNames:IntHash<String> = new IntHash<String>();

	public static function toString(o:Dynamic)
	{
		return "\n" + _toString(o, 0);
	}

	static function _toString(o:Dynamic, indent:Int):String
	{
		var str:String = "";
		var type = Type.typeof(o);
		var name:String;

		switch(type)
		{
			case TObject:



				// prevent following circular references by checking whether we already visited this object
				var idx:Int = Lambda.indexOf(ref, o);
				if(idx > -1)
				{
					str += refNames.get(idx);
				}
				else
				{
					++indent;
					idx = ref.push(o) - 1;

					name = "Object("+idx+")";
					refNames.set(idx, name);

					str += name;
					str += openObject();
					str += "\n";
					for(field in Reflect.fields(o))
					{
						str += setIndent(indent);
						str += printField(field);
						str += " : ";
						str += _toString(Reflect.field(o, field), indent);
						str += "\n";

					}

					--indent;
					str += setIndent(indent);
					str += closeObject();
				}



			case TClass(t):

				var className = Type.getClassName(t);

				if(className == "String")
				{
					str += printString('"' + o + '"');
				}
				else
					if(className == "Array")
					{


						var a:Array<Dynamic> = cast o;
						str += openArray();

						if(a.length > 0)
						{
							str += "\n";
							++indent;
							str += setIndent(indent);
						}
						for(item in a)
						{
							str += _toString(item, indent);
						}

						if(a.length > 0)
						{
							--indent;
							str += "\n";
							str += setIndent(indent);
						}
						str += closeArray();

					}
					else
					{


						// prevent following circular references by checking whether we already visited this object
						var idx:Int = Lambda.indexOf(ref, o);
						if(idx > -1)
						{
							str += refNames.get(idx);
						}
						else
						{
							++indent;
							idx = ref.push(o) - 1;


							name = className+"("+idx+")";
							refNames.set(idx, name);
							str += name;
							str += openObject();
							str += "\n";
							var fields = Reflect.fields(o);
							for(field in fields)
							{
								str += setIndent(indent);
								str += printField(field);
								str += " : ";
								str += _toString(Reflect.field(o, field), indent);
								str += "\n";
							}

							--indent;
							str += setIndent(indent);
							str += closeObject();
						}


					}



			case TUnknown:

				str += o;


			case TNull, TInt, TFunction, TFloat, TBool:

				str += o;


			case TEnum(v):

				str += o;
		}

		return str;
	}

	static function checkForCircularReference()
	{

	}

	static function setIndent(indent:Int):String
	{
		var ind = "";
		for(i in 0...indent)
		{
			ind += INDENT;
		}
		return ind;
	}

	static function openArray():String
	{
		return "\033[31m[ \033[0m";
	}

	static function closeArray():String
	{
		return "\033[31m] \033[0m";
	}

	static function openObject():String
	{
		return "\033[33m{ \033[0m";
	}

	static function closeObject():String
	{
		return "\033[33m} \033[0m";
	}

	static function orange(str:String):String
	{
		return "\033[33m" + str + "\033[0m";
	}
	static function purple(str:String):String
	{
		return "\033[33m" + str + "\033[0m";
	}
	static function white(str:String):String
	{
		return "\033[33m" + str + "\033[0m";
	}
	static function red(str:String):String
	{
		return "\033[33m" + str + "\033[0m";
	}

	static function printField(field:String):String
	{
		return "\033[33m" + field + "\033[0m";
	}

	static function printString(field:String):String
	{
		return "\033[37m" + field + "\033[0m";
	}

	static function printValue(field:String):String
	{
		return "\033[33m" + field + "\033[0m";
	}
}