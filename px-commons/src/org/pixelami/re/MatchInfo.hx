package org.pixelami.re;

typedef MatchInfo =
{
	public var match:String;
	public var position:{pos:Int,len:Int};
	public var groups:Array<String>;
}
