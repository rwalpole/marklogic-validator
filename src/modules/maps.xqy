xquery version "3.0" encoding "UTF-8";

module namespace maps = "http://devexe.co.uk/xquery/maps";

declare namespace fn = "http://www.w3.org/2005/xpath-functions";
declare namespace map = "http://marklogic.com/xdmp/map";
declare namespace xdmp = "http://marklogic.com/xdmp";
declare namespace xs = "http://www.w3.org/2001/XMLSchema";

declare function maps:add-to-map($map-uri as xs:string, $new-key as xs:string, $value as xs:string) as map:map {
    let $map-xml := fn:doc($map-uri)/map:map,
        $this-map := map:map($map-xml),
        $_ := xdmp:log(fn:concat("Adding entry [",$new-key,",",$value,"] to map ",$map-uri))
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
        $_ := xdmp:log(fn:concat("Removing entry [",$key,",",$value,"] from map ",$map-uri))
    return
        map:new((
            for $current-key in map:keys($this-map)
            return
                if($current-key != $key)then(
                    map:entry($current-key,map:get($this-map,$current-key))
                )else()
        ))
};

declare function maps:get-map-entry($key as xs:string, $value as xs:string) as element(map:entry) {
    <map:entry key="{$key}">
        <map:value xsi:type="xs:string">{$value}</map:value>
    </map:entry>
};
