package org.pixelami.uri;


import org.pixelami.re.MatchInfo;

class URIHandler {

    public var field:String;
    public var filter:String;
    public var ref:Void->Dynamic;
    public var info:MatchInfo;

    private var _ereg:EReg;
    public var ereg(get_ereg,null):EReg;
    function get_ereg():EReg
    {
        trace("ereg filter: "+filter);
        if(_ereg == null) _ereg = new EReg(filter,"");
        return _ereg;
    }

    public function new(filter:String,ref:Void->Dynamic,field:String)
    {
        this.filter = filter;
        this.field = field;
        this.ref = ref;
    }


}
