<?php

$domainprices = array();

$_cur = $this->get_template_vars('currency');


$sql = "SELECT tdp.extension, msetupfee year1, qsetupfee year2, ssetupfee year3, asetupfee year4, bsetupfee year5, monthly year6, quarterly year7, semiannually year8, annually year9, biennially year10
					FROM tbldomainpricing tdp, tblpricing tp
					WHERE tdp.extension in ('.com', '.net', '.me', '.info')
					AND tp.type = 'domainregister'
					AND tp.relid = tdp.id
					AND tp.currency = " . $_cur['id'];
$query = mysql_query($sql) or die(mysql_error());

while ($row = @mysql_fetch_array($query, MYSQL_ASSOC)) {
    if ($row['year1'] != 0)
        $domainprices[$row['extension']][1] = $row['year1'];
    if ($row['year2'] != 0)
        $domainprices[$row['extension']][2] = $row['year2'];
    if ($row['year3'] != 0)
        $domainprices[$row['extension']][3] = $row['year3'];
    if ($row['year4'] != 0)
        $domainprices[$row['extension']][4] = $row['year4'];
    if ($row['year5'] != 0)
        $domainprices[$row['extension']][5] = $row['year5'];
    if ($row['year6'] != 0)
        $domainprices[$row['extension']][6] = $row['year6'];
    if ($row['year7'] != 0)
        $domainprices[$row['extension']][7] = $row['year7'];
    if ($row['year8'] != 0)
        $domainprices[$row['extension']][8] = $row['year8'];
    if ($row['year9'] != 0)
        $domainprices[$row['extension']][9] = $row['year9'];
    if ($row['year10'] != 0)
        $domainprices[$row['extension']][10] = $row['year10'];
}

function doGetUrlData($url) {
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_HEADER, false);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
    //curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 2);
    $json = curl_exec($ch);
    $curlerror = "ErrNo: " . curl_errno($ch) . " ErrMsg: " . curl_error($ch);
    curl_close($ch);
    return $json;
}

if ($_REQUEST['sld']) {

    $domainRequested = mysql_real_escape_string($_REQUEST['sld']);
    $tld = mysql_real_escape_string($_REQUEST['tld']);
    $tlds = "&tlds=net&tlds=info&tlds=me";

    $key = "ChPqzCI4DCruLdyUpgiHCUXRMf2fPwd1";
    $user_id = "458561";

    $base_url = "https://test.httpapi.com/api/domains/suggest-names.json?auth-userid={$user_id}&api-key={$key}";


    $base_url = "https://test.httpapi.com/api/domains/available.json?auth-userid={$user_id}&api-key={$key}";
    $url_avail = "{$base_url}&domain-name={$domainRequested}&tlds=com{$tlds}&suggest-alternative=true";
    $json_avail = doGetUrlData($url_avail);
    $json_avail = json_decode($json_avail, true);

    $alternate_domains = array();
    foreach ($json_avail[$domainRequested] as $da => $tlds) {
        foreach ($tlds as $tld => $state) {
            if ($state == 'available') {
                $alternate_domains[$tld][] = $da . "." . $tld;
            }
        }
    }


    $tlds = array(".com", ".me", ".info", ".net");

    $general_avail = array();
    foreach ($tlds as $tld) {
        print_r($json_avail[$domainRequested . $tld]['status']);
        if ($json_avail[$domainRequested . $tld]['status'] == 'available') {
            $general_avail[$domainRequested . $tld] = "available";
        } else {
            $general_avail[$domainRequested . $tld] = "not_available";
        }
    }
}



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
            print "<td align='left' style='text-align:left;'>{$alternate_domains[$tld][0]} (<a href='javascript:;' {$onclick}><span >View More Suggestions</span><span style='display:none'>Hide Suggestions</span></a>)</td>";
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