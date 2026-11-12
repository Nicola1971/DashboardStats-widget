/**
 * DashboardStats
 *
 * Dashboard Stats widget plugin for Evolution CMS
 * @author    Nicola Lambathakis
 * @category    plugin
 * @version    3.2.5
 * @license	   http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @events OnManagerWelcomeHome,OnManagerMainFrameHeaderHTMLBlock
 * @internal    @installset base
 * @internal    @modx_category Dashboard
 * @author      Nicola Lambathakis http://www.tattoocms.it/
 * @documentation Requirements: This plugin requires Evolution 1.4 or later
 * @reportissues https://github.com/Nicola1971/WelcomeStats-EvoDashboard-Plugin/issues
 * @link
 * @lastupdate  12/11/2026
 * @internal    @properties &wdgVisibility=Show widget for:;menu;All,AdminOnly,AdminExcluded,ThisRoleOnly,ThisUserOnly;All &ThisRole=Run only for this role:;string;;;(role id) &ThisUser=Run only for this user:;string;;;(username) &wdgTitle= Stats widget Title:;string;Evo Stats  &wdgicon= widget icon:;string;fa-bar-chart-o  &Style= Style:;list;box,round,lite;box &wdgposition=widget position:;text;1 &wdgsizex=widget width:;list;12,6,4,3;12 &DocCountLabel= Documents count label:;string;Documents &startID= Documents count parent:;string;0 &WebUserCountLabel= Web Users label:;string;Web Users &webGroup= Users Web Group:;string;all &UserCountLabel= Manager Users label:;string;Manager Users &AdminCountLabel= Admin label:;string;Admins &HeadBG= Widget Title Background color:;string; &HeadColor= Widget title color:;string; &BodyBG= Widget Body Background color:;string; &BodyColor= Widget Body text color:;string;
 */
// get manager role and username
$role = (int)($_SESSION['mgrRole'] ?? 0);
$user = (string)($_SESSION['mgrShortname'] ?? '');

// PHP 8: default for every property (a configuration saved with an older
// version of the plugin may not contain all of them)
$wdgVisibility     = (string)($wdgVisibility ?? 'All');
$ThisRole          = trim((string)($ThisRole ?? ''));
$ThisUser          = trim((string)($ThisUser ?? ''));
$wdgTitle          = (string)($wdgTitle ?? 'Evo Stats');
$wdgicon           = (string)($wdgicon ?? 'fa-bar-chart-o');
$Style             = (string)($Style ?? 'box');
$wdgposition       = (string)($wdgposition ?? '1');
$wdgsizex          = (string)($wdgsizex ?? '12');
$DocCountLabel     = (string)($DocCountLabel ?? 'Documents');
$startID           = trim((string)($startID ?? '0'));
$WebUserCountLabel = (string)($WebUserCountLabel ?? 'Web Users');
$webGroup          = trim((string)($webGroup ?? 'all'));
$UserCountLabel    = (string)($UserCountLabel ?? 'Manager Users');
$AdminCountLabel   = (string)($AdminCountLabel ?? 'Admins');
$HeadBG            = (string)($HeadBG ?? '');
$HeadColor         = (string)($HeadColor ?? '');
$BodyBG            = (string)($BodyBG ?? '');
$BodyColor         = (string)($BodyColor ?? '');

if (!in_array($Style, array('box', 'round', 'lite'), true)) {
    $Style = 'box';
}
if (!in_array($wdgsizex, array('12', '6', '4', '3'), true)) {
    $wdgsizex = '12';
}
if ($webGroup === '') {
    $webGroup = 'all';
}

// widget visibility
$showWidget = true;
switch ($wdgVisibility) {
    case 'AdminOnly':
        $showWidget = ($role === 1);
        break;
    case 'AdminExcluded':
        $showWidget = ($role !== 1);
        break;
    case 'ThisRoleOnly':
        $showWidget = ($ThisRole !== '' && $role === (int)$ThisRole);
        break;
    case 'ThisUserOnly':
        $showWidget = ($ThisUser !== '' && $user === $ThisUser);
        break;
}

if ($showWidget) {
    $e = &$modx->Event;
    switch ($e->name) {
        /* load styles with OnManagerMainFrameHeaderHTMLBlock */
        case 'OnManagerMainFrameHeaderHTMLBlock':
            $e->output('<link type="text/css" rel="stylesheet" href="' . MODX_SITE_URL . 'assets/plugins/dashboardstats/' . $Style . '.css">');
            break;

        case 'OnManagerWelcomeHome':
            global $_lang;
            $charset = $modx->config['modx_charset'] ?? 'UTF-8';
            $h = function ($s) use ($charset) {
                return htmlspecialchars((string)$s, ENT_QUOTES, $charset);
            };

            // get plugin id
            $pluginName = $modx->db->escape((string)$modx->event->activePlugin);
            $pluginid = (int)$modx->db->getValue(
                $modx->db->select('id', $modx->getFullTableName('site_plugins'), "name='{$pluginName}' AND disabled=0")
            );

            // config button
            $button_pl_config = '';
            if ($modx->hasPermission('edit_plugin')) {
                $cfgLabel = (string)($_lang['settings_config'] ?? 'Configuration');
                $cfgJs = $h(addslashes($cfgLabel));
                $button_pl_config = '<a data-toggle="tooltip" href="javascript:;" title="' . $h($cfgLabel) . '" class="text-muted pull-right float-right" onclick="parent.modx.popup({url:\'' . MODX_MANAGER_URL . '?a=102&id=' . $pluginid . '&tab=1\',title1:\'' . $cfgJs . '\',icon:\'fa-cog\',iframe:\'iframe\',selector2:\'#tabConfig\',position:\'center center\',width:\'80%\',height:\'80%\',hide:0,hover:0,overlay:1,overlayclose:1})" ><i class="fa fa-cog"></i> </a>';
            }
            $modx->setPlaceholder('button_pl_config', $button_pl_config);

            // documents counter
            // &startID: 0 (or empty) = all documents; otherwise one or more parent ids
            // (comma separated): counts all their descendants, at any depth
            $doctable = $modx->getFullTableName('site_content');
            $startParents = array();
            foreach (explode(',', $startID) as $pid) {
                $pid = (int)trim($pid);
                if ($pid > 0) {
                    $startParents[$pid] = $pid;
                }
            }
            if (empty($startParents)) {
                $num = (int)$modx->db->getValue($modx->db->select('COUNT(*)', $doctable));
            } else {
                $found = array();
                $level = array_values($startParents);
                while (!empty($level)) {
                    $rs = $modx->db->select('id', $doctable, 'parent IN (' . implode(',', $level) . ')');
                    $next = array();
                    while ($row = $modx->db->getRow($rs)) {
                        $cid = (int)$row['id'];
                        if (!isset($found[$cid]) && !isset($startParents[$cid])) {
                            $found[$cid] = true;
                            $next[] = $cid;
                        }
                    }
                    $level = $next;
                }
                $num = count($found);
            }

            // web users counter (from: ShowMembers v1.1c)
            $settingsVersion = (string)($modx->config['settings_version'] ?? '');
            if ((int)substr($settingsVersion, 0, 1) < 3) {
                $wua = $modx->getFullTableName('web_user_attributes');
                $wgn = $modx->getFullTableName('webgroup_names');
                $wg  = $modx->getFullTableName('web_groups');
            } else {
                $wua = $modx->getFullTableName('user_attributes');
                $wgn = $modx->getFullTableName('membergroup_names');
                $wg  = $modx->getFullTableName('member_groups');
            }
            if ($webGroup === 'all') {
                $sql = "SELECT COUNT(*) FROM {$wua} wua";
            } else {
                $webGroupEsc = $modx->db->escape($webGroup);
                $sql = "SELECT COUNT(*) FROM {$wua} wua
                        JOIN {$wg} wg ON wg.webuser = wua.internalKey
                        JOIN {$wgn} wgn ON wgn.name = '{$webGroupEsc}' AND wgn.id = wg.webgroup";
            }
            $count = (int)$modx->db->getValue($modx->db->query($sql));

            // manager users / admins counters
            $userstable = $modx->getFullTableName('user_attributes');
            $userscount = (int)$modx->db->getValue($modx->db->select('COUNT(*)', $userstable, 'role > 1'));
            $admincount = (int)$modx->db->getValue($modx->db->select('COUNT(*)', $userstable, 'role = 1'));

            /* Widget Box */
            $WidgetOutput = '
<div class="container">
<div class="row">
<div class="col-lg-3 col-sm-6 col-xs-6">
<div class="statbox sblue">
<div class="staticon"><i title="' . $h($DocCountLabel) . '" class="fa fa-file fa-4x"></i></div>
<div class="count"><h3> ' . $num . ' </h3> ' . $h($DocCountLabel) . ' </div>
</div>
</div>

<div class="col-lg-3 col-sm-6 col-xs-6">
<div class="statbox sgreen">
<div class="staticon"><i title="' . $h($WebUserCountLabel) . '" class="fa fa-users fa-4x"></i></div>
<div class="count"><h3 class="counter"> ' . $count . ' </h3> ' . $h($WebUserCountLabel) . ' </div>
</div>
</div>

<div class="col-lg-3 col-sm-6 col-xs-6">
<div class="statbox syellow">
<div class="staticon"><i title="' . $h($UserCountLabel) . '" class="fa fa-user fa-4x"></i></div>
<div class="count"><h3 class="counter"> ' . $userscount . ' </h3> ' . $h($UserCountLabel) . ' </div>
</div>
</div>

<div class="col-lg-3 col-sm-6 col-xs-6">
<div class="statbox sred">
<div class="staticon"><i title="' . $h($AdminCountLabel) . '" class="fa fa-user-md fa-4x"></i></div>
<div class="count"><h3 class="counter"> ' . $admincount . ' </h3> ' . $h($AdminCountLabel) . ' </div>
</div>
</div>
</div>
</div>
';

            // add the widget to the system widgets (do not replace the array)
            $widgets = (isset($widgets) && is_array($widgets)) ? $widgets : array();
            $widgets['DashboardStats'] = array(
                'menuindex' => $wdgposition,
                'id'        => 'DashboardStats' . $pluginid,
                'cols'      => 'col-md-' . $wdgsizex,
                'headAttr'  => 'style="background-color:' . $h($HeadBG) . '; color:' . $h($HeadColor) . ';"',
                'bodyAttr'  => 'style="background-color:' . $h($BodyBG) . '; color:' . $h($BodyColor) . ';"',
                'icon'      => $h($wdgicon),
                'title'     => $h($wdgTitle) . ' ' . $button_pl_config,
                'body'      => '<div class="col-lg-12 col-md-12 col-sm-12 statcontainer">' . $WidgetOutput . ' </div>'
            );
            $e->output(serialize($widgets));
            break;
    }
}
