xquery version "1.0-ml" encoding "UTF-8";

import module namespace transform = "http://devexe.co.uk/xquery/transform" at "/modules/transform.xqy";

declare namespace app="http://lexisnexis.co.uk/apps/analysis-tool";
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

xdmp:set-response-content-type("text/html"),
'<!DOCTYPE html>',
let $identifier := xdmp:get-request-field("identifier","")
let $collection := concat("http://devexe.co.uk/collection/",$identifier)
let $reports := local:get-reports($collection)
return transform:transform($reports, "/xslt/schematron.xsl",(concat("collection=",$collection)))