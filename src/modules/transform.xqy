xquery version "1.0-ml" encoding "UTF-8";

(:~
: Provides an abstract API for MarkLogic specific XSL transformation functions
:)
module namespace transform = "http://devexe.co.uk/xquery/transform";

declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace map = "http://marklogic.com/xdmp/map";
declare namespace xdmp = "http://marklogic.com/xdmp";

(:~ given a sequence of key=value strings returns a MarkLogic-style parameter map for transformations :)
declare function transform:get-parameter-map($parameters as xs:string*) as map:map {
    map:map(<map:map>{
        for $parameter in $parameters
        let $key := fn:substring-before($parameter, "="),
            $value := fn:substring-after($parameter, "=")
        return
            <map:entry>
                <map:key>{$key}</map:key>
                <map:value>{$value}</map:value>
            </map:entry>
    }</map:map>)
};

(:~ abstraction of ML specific transformation function :)
declare function transform:transform($doc as node(), $xslt as xs:string, $params as xs:string*) as document-node() {
    let $param-map := transform:get-parameter-map($params)
    return xdmp:xslt-invoke($xslt, document{$doc},$param-map)
};

(:~ abstraction of ML specific transformation function :)
declare function transform:transform($doc as node(), $xslt as xs:string)  as  document-node() {
    xdmp:xslt-invoke($xslt, document{$doc})
};

