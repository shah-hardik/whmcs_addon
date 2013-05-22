<?php

$format = "";
$formatMe = "";
foreach ($general_avail as $ea => $status) {
    $tld = end(explode(".", $ea));
    if ($tld == "me") {
        $formatMe = $ea;
        continue;
    }
    print "<tr class='availDomains' >";
    $onclick = is_null($alternate_domains[$tld]) ? "" : "onclick='$(\".d{$tld}\").toggle();$(this).children().toggle();'";

    $currentDomain = $_REQUEST['sld'] . $_REQUEST['tld'] == $ea ? "font-weight:bold" : "";

    print "<td align='left' style='text-align:left;{$currentDomain}' >{$ea} ";
    if ($tld != "com") {
        if (!is_null($alternate_domains[$tld])) {
            print "( <a href='javascript:;' {$onclick} > <span>View Suggestions </span><span style='display:none'>Hide Suggestions </span></a>) ";
        }
        print "</td>";
    } else {
        print "</td>";
    }

    if ($status == "available") {
        print "<td align='left'><label><input type='checkbox' name='domains[]' value='{$ea}' /> Available</label></td>";
    } else {
        print "<td align='left'>Unavailable</td>";
    }

    print "<td>";

    $lang = $this->get_template_vars('LANG');
    $currency = $this->get_template_vars('currency');


    if ($domainprices['.' . $tld]) {
        print "<select name='domainsregperiod[{$ea}]'>";
        foreach ($domainprices['.' . $tld] as $period => $price) {
            print "<option value='{$period}'>";
            print $period . " " . $lang['orderyears'] . " @ " . $price . " " . $currency['suffix'];
            print "</option>";
        }
        print "</select>";
    }

    print "</td>";
    print "</tr>";

    if ($tld == "com") {
        if ($alternate_domains[$tld][0]) {
            print "<tr class='availDomains ' >";
            print "<td align='left' style='text-align:left;'>{$alternate_domains[$tld][0]} </td>";
            print "<td align='left'><label><input type='checkbox' name='domains[]' value='{$alternate_domains[$tld][0]}' /> Available</label></td>";
            print "<td>";
            if ($domainprices['.' . $tld]) {
                print "<select name='domainsregperiod[{$alternate_domains[$tld][0]}]'>";
                foreach ($domainprices['.' . $tld] as $period => $price) {
                    print "<option value='{$period}'>";
                    print $period . " " . $lang['orderyears'] . " @ " . $price . " " . $currency['suffix'];
                    print "</option>";
                }
                print "</select>";
            }
            print "</td>";
            print "</tr>";
            array_shift($alternate_domains[$tld]);
        }

        if ($alternate_domains[$tld][0]) {
            print "<tr class='availDomains '  >";
            print "<td align='left' style='text-align:left;'>{$alternate_domains[$tld][0]} (<a href='javascript:;' {$onclick}><span style="padding-left:15px" >View More Suggestions</span><span style='display:none'>Hide Suggestions</span></a>)</td>";
            print "<td align='left'><label><input type='checkbox' name='domains[]' value='{$alternate_domains[$tld][0]}' /> Available</label></td>";
            print "<td>";
            if ($domainprices['.' . $tld]) {
                print "<select name='domainsregperiod[{$alternate_domains[$tld][0]}]'>";
                foreach ($domainprices['.' . $tld] as $period => $price) {
                    print "<option value='{$period}'>";
                    print $period . " " . $lang['orderyears'] . " @ " . $price . " " . $currency['suffix'];
                    print "</option>";
                }
                print "</select>";
            }
            print "</td>";
            print "</tr>";
            array_shift($alternate_domains[$tld]);
        }
    }


    foreach ($alternate_domains[$tld] as $ea) {
        print "<tr class='availDomains d{$tld}' style='display:none' >";
        print "<td align='left' style='text-align: left'>{$ea} </td>";
        print "<td align='left'><label><input type='checkbox' name='domains[]' value='{$ea}' /> Available</label></td>";
        print "<td>";
        if ($domainprices['.' . $tld]) {
            print "<select name='domainsregperiod[{$ea}]'>";
            foreach ($domainprices['.' . $tld] as $period => $price) {
                print "<option value='{$period}'>";
                print $period . " " . $lang['orderyears'] . " @ " . $price . " " . $currency['suffix'];
                print "</option>";
            }
            print "</select>";
        }

        print "</td>";
        print "</tr>";
    }
}
print $format;


$tld = "me";

$format = "<tr class='availDomains' >";
$onclick = is_null($alternate_domains[$tld]) ? "" : "onclick='$(\".d{$tld}\").toggle();$(this).children().toggle();'";

$currentDomain = $_REQUEST['sld'] . $_REQUEST['tld'] == $ea ? "font-weight:bold" : "";

print "<td align='left' style='text-align:left;{$currentDomain}' >{$formatMe} ";
print "</td>";


if ($status == "available") {
    print "<td align='left'><label><input type='checkbox' name='domains[]' value='{$formatMe}' /> Available</label></td>";
} else {
    print "<td align='left'>Unavailable</td>";
}

print "<td>";

if ($domainprices['.' . $tld]) {
    print "<select name='domainsregperiod[{$formatMe}]'>";
    foreach ($domainprices['.' . $tld] as $period => $price) {
        print "<option value='{$period}'>";
        print $period . " " . $lang['orderyears'] . " @ " . $price . " " . $currency['suffix'];
        print "</option>";
    }
    print "</select>";
}

print "</td>";
print "</tr>";


print $format;
