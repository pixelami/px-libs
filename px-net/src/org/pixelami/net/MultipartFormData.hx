package org.pixelami.net;


typedef FileData = {
    key:String,
    filename:String,
    data:Dynamic
}

typedef Field = {
    key:String,
    value:String
}

class MultipartFormData
{
    static var BOUNDARY = "----------m_part_boundary_$";
    static var CRLF = "\r\n";

    var fields:Array<Field>;
    var fileData:Array<FileData>;

    public function new()
    {
        fields = new Array<Field>();
        fileData = new Array<FileData>();
    }

    public function addField(key:String, value:String)
    {
        fields.push({key:key, value:value});
    }

    public function addFileData(key:String, filename:String, data:Dynamic)
    {
        fileData.push({key:key, filename:filename, data:data});
    }

    public function encodeMultipartFormaData():String
    {
        var lines = [];
        var body:String = "";


        for (field in fields)
        {
            lines.push("--" + BOUNDARY);
            lines.push("Content-Disposition: form-data; name=\""+ field.key +"\"");
            lines.push("");
            lines.push(field.value);
        }

        for (fd in fileData)
        {

            lines.push("--" + BOUNDARY);
            lines.push("Content-Disposition: form-data; name=\""+fd.key+"\"; filename=\""+fd.filename+"\"");
            lines.push("Content-Type: " + getFileContentType(fd.filename));
            lines.push("");
            lines.push(fd.data);
        }

        lines.push("--" + BOUNDARY + "--");
        lines.push("");
        body = lines.join(CRLF);
        return body;
    }

    public function getContentType():String
    {
         return "multipart/form-data; boundary=" + BOUNDARY;
    }

    function getFileContentType(filename:String):String
    {
        return "application/octet-stream";
    }
}
