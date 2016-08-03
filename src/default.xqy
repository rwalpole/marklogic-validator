xquery version "1.0-ml" encoding "UTF-8";


import module namespace common = "http://devexe.co.uk/xquery/common" at "/modules/common.xqy";
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
let $dpsi := xdmp:get-request-field("dpsi","")
let $title := common:get-leg-title($dpsi)
let $leg-count := common:count-leg-elems($dpsi)
let $act-count := $leg-count/@acts/string()
let $sis-count := $leg-count/@sis/string()
let $international-count := common:count-international-legislation($dpsi)
let $collection := concat("http://devexe.co.uk/collection/",$dpsi)
let $reports := local:get-reports($collection)
let $xslt-params := (
    concat("dpsi=",$dpsi),
    concat("title=",$title),
    concat("acts=",$act-count),
    concat("sis=",$sis-count),
    concat("international=",$international-count))
return transform:transform($reports, "/xslt/schematron.xsl",$xslt-params)