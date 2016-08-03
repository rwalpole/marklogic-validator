xquery version "3.0" encoding "UTF-8";

(:~
: User: walpolrx
: Date: 03/08/2016
: Time: 14:38
: To change this template use File | Settings | File Templates.
:)

module namespace common = "http://devexe.co.uk/xquery/common";

declare namespace core = "http://www.lexisnexis.com/namespace/sslrp/core";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace lnb-leg = "http://www.lexisnexis.com/namespace/sslrp/lnb-leg";
declare namespace se = "http://www.lexisnexis.com/namespace/sslrp/se";

declare variable $common:editorial-source-location := "http://devexe.co.uk/data/";

declare function common:get-leg-title($dpsi as xs:string) as xs:string {
    fn:doc(fn:concat($common:editorial-source-location,$dpsi,"/blueprint_pif.xml"))//blueprint-pif/pif/metadata/publication-information/publication-title/text()
};

declare function common:get-leg-elems($dpsi as xs:string) as node()* {
    for $doc in fn:collection(fn:concat("/db/data/legislation/",$dpsi))
    order by fn:base-uri($doc) (: enforces ordering by document name! :)
    return
        for $leg in $doc//lnb-leg:*[self::lnb-leg:act or self::lnb-leg:si][fn:not(ancestor::core:comment)][fn:not(ancestor::fn:endnotes)][fn:not(ancestor::se:sources)]
        return $leg
};

declare function common:count-international-legislation($dpsi as xs:string) as xs:string {
    let $international-legislation := fn:collection(fn:concat("/db/data/legislation/",$dpsi,"/"))//lnb-leg:international-legislation[fn:not(ancestor::core:comment)]
    return xs:string(fn:count($international-legislation))
};

declare function common:count-leg-elems($dpsi as xs:string) as element() {
    let $leg-elems := common:get-leg-elems($dpsi)
    let $act-count := fn:count($leg-elems[self::lnb-leg:act])
    let $si-count := fn:count($leg-elems[self::lnb-leg:si])
    return <count acts="{$act-count}" sis="{$si-count}"/>
};

(: accepts key/value pairs as a sequence of strings such as "key=value" :)
declare function common:get-xslt-params($params as xs:string*) as element(parameters) {
    <parameters>{
        for $param in $params
        let $key := fn:substring-before($param,"=")
        let $value := fn:substring-after($param,"=")
        return <param name="{$key}" value="{$value}"/>
    }</parameters>
};