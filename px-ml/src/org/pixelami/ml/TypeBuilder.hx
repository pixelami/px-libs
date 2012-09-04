package org.pixelami.ml;

class TypeBuilder
{
    public static function buildTypes(manifests:Array<String>)
    {
        var generator:TypeGenerator = new TypeGenerator(manifests);
    }
}
