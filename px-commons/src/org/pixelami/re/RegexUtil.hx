package org.pixelami.re;

import org.pixelami.re.MatchInfo;


class RegexUtil
{
	public static function findAll(pattern:EReg,src:String):Array<MatchInfo>
	{
		var _src = src;
		var collector:Array<MatchInfo> = new Array<MatchInfo>();
		var pos:Int = 0;
		while(true)
		{
			var info:MatchInfo = search(pattern,_src);
			if(info == null) break;
			
			// calculate local position within substring
			var lpos:Int = info.position.pos+info.position.len;
			// update global position within original string
			pos += lpos;
			// truncate string for original next search
			_src = _src.substr(lpos);
			// reset the info position to the global position
			info.position.pos = pos;
			collector.push(info);
		}
		return collector;
	}

	public static function search(pattern:EReg,string:String):MatchInfo
	{
		var info:MatchInfo = null;

		if(pattern.match(string))
		{
			var mPos = pattern.matchedPos();
			var groups:Array<String> = [];
			var pos:Int = 0;
			while(true)
			{
				try 
				{
					groups.push(pattern.matched(pos));
					pos ++;
				}
				catch(e:Dynamic)
				{
					//trace(e);
					break;
				}
			}

			info = { position:mPos , groups: groups, match:pattern.matched(0)};
		}
		return info;
		
	}
}
