<link rel="stylesheet" type="text/css" href="templates/orderforms/{$carttpl}/style.css" />

{php}
            /**
             *
             * @version 0.1
             * @since April, 2013
             * Hijack WHMCS for injecting related domain suggesstions from resllers API.
             * @author: sysadmin18,dave.jay90
             *
             */
             
            
             // Holds domain prices array from admin panel
             $domainprices = array();

            // get smarty variable. avoiding ugly smarty things
            $_cur = $this->get_template_vars('currency');


            $sql = "SELECT tdp.extension, msetupfee year1, qsetupfee year2, ssetupfee year3, asetupfee year4, bsetupfee year5, monthly year6, quarterly year7, semiannually year8, annually year9, biennially year10
                                                    FROM tbldomainpricing tdp, tblpricing tp
                                                    WHERE tdp.extension in ('.com', '.net', '.me', '.info','{$_REQUEST['tld']}')
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

            // wrapper for curl request.
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
            
            
            // if form is submitted ping to ressellers api.
            if ($_REQUEST['sld']) {

                // Searched domain
                $domainRequested = trim(mysql_real_escape_string($_REQUEST['sld']));
                
                // searched tld
                $tld = mysql_real_escape_string($_REQUEST['tld']);
                $tldSearched = end(explode(".",$tld));
                
                // common tld + searched tld. Thanks sysadmin18!!
                $tlds = "&tlds=net&tlds=info&tlds=me";
                if(!in_array($tldSearched,array('net','info','me','com'))){
                    $tlds .= "&tlds={$tldSearched}";
                }

                
                // reseller key
                $key = "HEwrrlcH8GC1H7fkJdfaMbkDrnzZF4vs";
                $user_id = "348833";

                
                // go, pint api
                $base_url = "https://httpapi.com/api/domains/available.json?auth-userid={$user_id}&api-key={$key}";
                print $url_avail = "{$base_url}&domain-name={$domainRequested}&tlds=com{$tlds}&suggest-alternative=true";
                $json_avail = doGetUrlData($url_avail);
                $json_avail = json_decode($json_avail, true);
                
                // prepare ds
                $alternate_domains = array();
                foreach ($json_avail[$domainRequested] as $da => $tlds) {
                    foreach ($tlds as $tld => $state) {
                        if ($state == 'available') {
                            $alternate_domains[$tld][] = $da . "." . $tld;
                        }
                    }
                }


                // prepare general availability of search-domain
                $tlds = array($_REQUEST['tld'],".com", ".me", ".info", ".net");
                $tlds = array_unique($tlds);

                $general_avail = array();
                foreach ($tlds as $tld) {
                    
                    if ($json_avail[$domainRequested . $tld]['status'] == 'available') {
                        $general_avail[$domainRequested . $tld] = "available";
                    } else {
                        $general_avail[$domainRequested . $tld] = "not_available";
                    }
                }
            }
            
            
            // now, please go below for rendering.
            
{/php}

<div id="order-web20cart">

    <h1>{if $domain eq "register"}{$LANG.registerdomainname}{else}{$LANG.transferdomainname}{/if}</h1>

    <div class="cartmenu" align="center">{foreach key=num item=productgroup from=$productgroups}
        {if $gid eq $productgroup.gid}
        {$productgroup.name} | 
        {else} <a href="{$smarty.server.PHP_SELF}?gid={$productgroup.gid}">{$productgroup.name}</a> | 
        {/if}
        {/foreach}
        {if $loggedin}
        <a href="{$smarty.server.PHP_SELF}?gid=addons">{$LANG.cartproductaddons}</a> |
        {if $renewalsenabled}<a href="{$smarty.server.PHP_SELF}?gid=renewals">{$LANG.domainrenewals}</a> | {/if}
        {/if}
        {if $registerdomainenabled}{if $domain neq "register"}<a href="{$smarty.server.PHP_SELF}?a=add&domain=register">{$LANG.registerdomain}</a>{else}<strong>{$LANG.registerdomain}</strong>{/if} |{/if}
        {if $transferdomainenabled}{if $domain neq "transfer"}<a href="{$smarty.server.PHP_SELF}?a=add&domain=transfer">{$LANG.transferdomain}</a>{else}<strong>{$LANG.transferdomain}</strong>{/if} |{/if} <a href="{$smarty.server.PHP_SELF}?a=view">{$LANG.viewcart}</a></div>

    {if !$loggedin && $currencies}
    <form method="post" action="cart.php?a=add&domain={$domain}">
        <p align="right">{$LANG.choosecurrency}: <select name="currency" onchange="submit()">{foreach from=$currencies item=curr}
                <option value="{$curr.id}"{if $curr.id eq $currency.id} selected{/if}>{$curr.code}</option>
                {/foreach}</select> <input type="submit" value="Go" /></p>
    </form>
    {/if}

    {if $errormessage}
    <div class="errorbox textcenter">{$errormessage}</div>
    {/if}

    <p>{if $domain eq "register"}{$LANG.registerdomaindesc}{else}{$LANG.transferdomaindesc}{/if}</p>

    <form method="post" action="{$smarty.server.PHP_SELF}?a=add&domain={$domain}">
        <div class="cartbox" align="center">www.
            <input type="text" name="sld" size="40" value="{$sld}" /> 
            <select name="tld">
                {foreach key=num item=listtld from=$tlds}
                <option value="{$listtld}"{if $listtld eq $tld} selected="selected"{/if}>{$listtld}</option>
                {/foreach}
            </select> 
            <input type="submit" value="{$LANG.checkavailability}" />
        </div>
        <p align="center"></p>
    </form>
    {if $availabilityresults}
    <h2>{$LANG.choosedomains}</h2>
    <form method="post" action="{$smarty.server.PHP_SELF}?a=add&domain={$domain}">
        <table class="textcenter" id="domainList" >
            <tr> 
                <th width="486">{$LANG.domainname}</th>
                <th>{$LANG.domainstatus}</th>
                <th>{$LANG.domainmoreinfo}</th>
            </tr>
            {foreach key=num item=result from=$availabilityresults}
            <tr style="display:none">
                <td>{$result.domain}</td>
                <td class="{if $result.status eq $searchvar}textgreen{else}textred{/if}">
                    <label>{if $result.status eq $searchvar}<input type="checkbox" name="domains[]" value="{$result.domain}"{if $result.domain|in_array:$domains} checked{/if} /> {$LANG.domainavailable}{else}{$LANG.domainunavailable}{/if}</label>
                </td>
                <td>{if $result.regoptions}
                    <select name="domainsregperiod[{$result.domain}]">
                        {foreach key=period item=regoption from=$result.regoptions}
                        {if $regoption.$domain}<option value="{$period}">
                            {$period} {$LANG.orderyears} @ {$regoption.$domain}
                        </option>{/if}
                        {/foreach}
                    </select>
                    {/if}</td>
            </tr>
            {/foreach}
            {php}
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

                    print "<td align='left' style='text-align:left;{$currentDomain}' ><span style='padding-right:15px'>{$ea}</span> ";
                    if ($tld != "com") {
                        if (!is_null($alternate_domains[$tld])) {
                            print "(<a href='javascript:;' {$onclick} > <span>View Suggestions </span><span style='display:none'>Hide Suggestions </span></a>) ";
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
                            print "<td align='left' style='text-align:left;'><span style='padding-right:15px'>{$alternate_domains[$tld][0]}</span> (<a href='javascript:;' {$onclick}><span  >View More Suggestions</span><span style='display:none'>Hide Suggestions</span></a>)</td>";
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
                         

            {/php}



        </table>
        <p align="center">
            <input type="submit" value="{$LANG.addtocart}" />
        </p>
    </form>
    {literal}
    
    <script type="text/javascript">
        function doLoadSimilarDomains(){
            jQuery('.availDomains').show("medium");
        }
        
    </script>
    
    <style type="text/css">
        .search{
            background-position: -193px -65px;
            
        }
        .suggest{
            background-position: -225px -81px;
        }
        .ic{
            background-image: url("/templates/phi9/images/opa-icons-black16.png");
            background-repeat: no-repeat;
            margin:3px 3px 0px 0px;
            display: inline-block;
            height: 14px;
            line-height: 14px;
            vertical-align: text-top;
            width: 14px;
        }
    </style>
    {/literal}

    {/if}
    <p align="right">
        <input type="button" value="{$LANG.viewcart}" onclick="window.location='cart.php?a=view'" />
    </p>

</div>