xquery version "1.0-ml" encoding "UTF-8";

import module namespace maps = "http://devexe.co.uk/xquery/maps" at "/modules/maps.xqy";
import module namespace transform = "http://devexe.co.uk/xquery/transform" at "/modules/transform.xqy";

declare namespace app="http://lexisnexis.co.uk/apps/analysis-tool";
declare namespace map="http://marklogic.com/xdmp/map";
declare namespace xdmp = "http://marklogic.com/xdmp";

declare option xdmp:output "method = html";
declare option xdmp:mapping "false";

declare variable $app:ERROR := xs:QName("app:error");

declare function local:get-report($doc as node(), $uri as xs:string) as element(report) {
    <report doc="{fn:base-uri($doc)}">{
        transform:transform($doc, "/schematron/kepler-pluto-commentary.xsl","")
    }</report>
};

declare function local:get-reports($collection as xs:string) as element() {
    try{
        <reports>{
            for $doc in fn:collection($collection)/*
            let $uri := fn:base-uri($doc)
            order by $uri return
                local:get-report($doc, $uri)
        }</reports>
    } catch ($exception) {
        "Problem loading file, received the following exception: ", $exception
    }
};

declare function local:get-namespaces-map($xpath as xs:string) as element(map:map) {
    let $_ := xdmp:log(fn:concat("XPath: ",$xpath))
    return
        <map:map>{
            for $token in tokenize(substring-after($xpath,"/*"),"/\*")
            let $namespace := tokenize($token,"'")[2]
            let $prefix := tokenize($namespace,"/")[last()]
            return maps:get-map-entry($prefix, $namespace)
        }</map:map>

};

declare function local:get-prefixed-xpath($xpath as xs:string) as xs:string* {
    for $token in tokenize(substring-after($xpath,"/*"),"/\*")
    let $namespace := tokenize($token,"'")[2]
    let $prefix := tokenize($namespace,"/")[last()]
    return concat("/",$prefix, replace($token,"\[[\(\)=:a-z/'.-]*\]",""))
};



let $doc := xdmp:get-request-field("doc","")
let $xpath := xdmp:get-request-field("xpath","")
let $identifier := xdmp:get-request-field("identifier","")
return
    if($doc != "")then(
        xdmp:set-response-content-type("application/xml"),
        if($xpath != "")then(
            let $namespaces := map:map(local:get-namespaces-map($xpath))
            let $prefixed-xpath := string-join(local:get-prefixed-xpath($xpath))
            let $doc := doc($doc)
            return xdmp:unpath(concat("$doc/",$prefixed-xpath), $namespaces)
        )else(
            doc($doc)
        )
    )else if($identifier != "")then(
        xdmp:set-response-content-type("text/html"),
        '<!DOCTYPE html>',
        let $collection := concat("http://devexe.co.uk/collection/",$identifier),
            $reports := local:get-reports($collection)
        return transform:transform($reports, "/xslt/schematron.xsl",(concat("collection=",$collection)))
    )else()
