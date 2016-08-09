xquery version "3.0" encoding "UTF-8";

module namespace maps = "http://lexisnexis.co.uk/xquery/maps";

import module namespace collections = "http://lexisnexis.co.uk/xquery/collections" at "/modules/collections.xqy";

declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace map = "http://marklogic.com/xdmp/map";
declare namespace xdmp = "http://marklogic.com/xdmp";

declare function maps:add-to-map($map-uri as xs:string, $new-key as xs:string, $value as xs:string) as map:map {
    let $map-xml := fn:doc($map-uri)/map:map,
        $this-map := map:map($map-xml),
        $logged := xdmp:log(fn:concat("Adding entry [",$new-key,",",$value,"] to map ",$map-uri))
    return
        map:new((
            for $key in map:keys($this-map)
            return map:entry($key, map:get($this-map,$key)),
            map:entry($new-key,$value)
        ))
};

declare function maps:delete-from-map($map-uri as xs:string, $key as xs:string) as map:map {
    let $map-xml := fn:doc($map-uri)/map:map,
        $this-map := map:map($map-xml),
        $value := map:get($this-map,$key),
        $logged := xdmp:log(fn:concat("Removing entry [",$key,",",$value,"] from map ",$map-uri))
    return
        map:new((
            for $current-key in map:keys($this-map)
            return
                if($current-key != $key)then(
                    map:entry($current-key,map:get($this-map,$current-key))
                )else()
        ))
};

declare function maps:get-map-uri($collection-uri as xs:string) as xs:string {
    if($collection-uri=$collections:amendment-history-uri)then(
        'amendment-hisory-table-enactments.xml'
    )else if($collection-uri=$collections:commentary-uri)then(
        'commentary-titles.xml'
    )else if($collection-uri=$collections:unversioned-acts-uri)then(
        'unversioned-acts-enactments.xml'
    )else if($collection-uri=$collections:unversioned-sis-uri)then(
        'unversioned-sis-enactments.xml'
    )else if($collection-uri=$collections:versioned-acts-uri)then(
        'versioned-acts-enactments.xml'
    )else if($collection-uri=$collections:versioned-sis-uri)then(
        'versioned-si-enactments.xml'
    )else("")

};

declare function maps:check-available($citation as xs:string) as xs:boolean {
    if(fn:ends-with($citation,"a"))then(
        fn:exists(fn:doc("versioned-acts-enactments.xml")/map:map/map:entry[@key=$citation])
    )else if(fn:ends-with($citation,"s"))then(
        fn:exists(fn:doc("versioned-si-enactments.xml")/map:map/map:entry[@key=$citation])
    )else(fn:false())
};
