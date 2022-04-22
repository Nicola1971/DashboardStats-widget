/**
 * DashboardStats
 *
 * Dashboard Stats widget plugin for Evolution CMS
 * @author    Nicola Lambathakis
 * @category    plugin
 * @version    3.2.3
 * @license	   http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @events OnManagerWelcomeHome,OnManagerMainFrameHeaderHTMLBlock
 * @internal    @installset base
 * @internal    @modx_category Dashboard
 * @author      Nicola Lambathakis http://www.tattoocms.it/
 * @documentation Requirements: This plugin requires Evolution 1.4 or later
 * @reportissues https://github.com/Nicola1971/WelcomeStats-EvoDashboard-Plugin/issues
 * @link
 * @lastupdate  22/04/2022
 * @internal    @properties &wdgVisibility=Show widget for:;menu;All,AdminOnly,AdminExcluded,ThisRoleOnly,ThisUserOnly;All &ThisRole=Run only for this role:;string;;;(role id) &ThisUser=Run only for this user:;string;;;(username) &wdgTitle= Stats widget Title:;string;Evo Stats  &wdgicon= widget icon:;string;fa-bar-chart-o  &Style= Style:;list;box,round,lite;box &wdgposition=widget position:;text;1 &wdgsizex=widget width:;list;12,6,4,3;12 &DocCountLabel= Documents count label:;string;Documents &startID= Documents count parent:;string;0 &WebUserCountLabel= Web Users label:;string;Web Users &webGroup= Users Web Group:;string;all &UserCountLabel= Manager Users label:;string;Manager Users &AdminCountLabel= Admin label:;string;Admins &HeadBG= Widget Title Background color:;string; &HeadColor= Widget title color:;string; &BodyBG= Widget Body Background color:;string; &BodyColor= Widget Body text color:;string;
 */
// get manager role
$internalKey = $modx->getLoginUserID();
$sid = $modx->sid;
$role = $_SESSION['mgrRole'];
$user = $_SESSION['mgrShortname'];
// show widget only to Admin role 1
if(($role!=1) AND ($wdgVisibility == 'AdminOnly')) {}
// show widget to all manager users excluded Admin role 1
else if(($role==1) AND ($wdgVisibility == 'AdminExcluded')) {}
// show widget only to "this" role id
else if(($role!=$ThisRole) AND ($wdgVisibility == 'ThisRoleOnly')) {}
// show widget only to "this" username
else if(($user!=$ThisUser) AND ($wdgVisibility == 'ThisUserOnly')) {}
else {
// get language
global $modx,$_lang;
// get plugin id
$result = $modx->db->select('id', $this->getFullTableName("site_plugins"), "name='{$modx->event->activePlugin}' AND disabled=0");
$pluginid = $modx->db->getValue($result);
if($modx->hasPermission('edit_plugin')) {
$button_pl_config = '<a data-toggle="tooltip" href="javascript:;" title="' . $_lang["settings_config"] . '" class="text-muted pull-right float-right" onclick="parent.modx.popup({url:\''. MODX_MANAGER_URL.'?a=102&id='.$pluginid.'&tab=1\',title1:\'' . $_lang["settings_config"] . '\',icon:\'fa-cog\',iframe:\'iframe\',selector2:\'#tabConfig\',position:\'center center\',width:\'80%\',height:\'80%\',hide:0,hover:0,overlay:1,overlayclose:1})" ><i class="fa fa-cog"></i> </a>';
}
$modx->setPlaceholder('button_pl_config', $button_pl_config);
//styles
$Style = isset($Style) ? $Style : 'box';
// documents counter
$doctable = $modx->getFullTableName('site_content');
$countDocQuery = "SELECT (id) FROM $doctable";
$resource = $modx->db->query($countDocQuery);
$num = $modx->db->getRecordCount($resource);

// webusers counter
$webGroup = isset($webGroup) ? $webGroup : '';
// from: ShowMembers v1.1c
// Added to allow for working with v1, v2 and v3
if ( substr($modx->config['settings_version'],0,1) < 3 )
{
	$wua= $modx->getFullTableName('web_user_attributes');
	$wgn= $modx->getFullTableName('webgroup_names');
	$wg= $modx->getFullTableName('web_groups');
} else {
	$wua= $modx->getFullTableName('user_attributes');
	$wgn= $modx->getFullTableName('membergroup_names');
	$wg= $modx->getFullTableName('member_groups');
}
	
if($webGroup == "all") {
  $sql= "SELECT (wua.id) FROM {$wua} wua ORDER BY wua.fullname ASC";
} else {
  $sql= "SELECT (wua.id) FROM {$wua} wua JOIN {$wg} wg ON wg.webuser = wua.internalKey JOIN {$wgn} wgn ON wgn.name

= '{$webGroup}' AND wgn.id = wg.webgroup ORDER BY wua.fullname ASC";
}

$webusers = $modx->db->query($sql);
$count = $modx->db->getRecordCount($webusers);
// end users counter

$userstable = $modx->getFullTableName('user_attributes');
$countusersQuery = "SELECT (id) FROM $userstable WHERE role > 1";
$users = $modx->db->query($countusersQuery);
$userscount = $modx->db->getRecordCount($users);

$countAdminQuery = "SELECT (id) FROM $userstable WHERE role = 1";
$admins = $modx->db->query($countAdminQuery);
$admincount = $modx->db->getRecordCount($admins);


/*Widget Box */

$WidgetOutput = '
<div class="container">
<div class="row">
<div class="col-lg-3 col-sm-6 col-xs-6">
<div class="statbox sblue">
<div class="staticon"><i title="'.$DocCountLabel.'" class="fa fa-file fa-4x"></i></div>
<div class="count"><h3> '.$num.' </h3> '.$DocCountLabel.' </div>
</div>
</div>

<div class="col-lg-3 col-sm-6 col-xs-6">
<div class="statbox sgreen">
<div class="staticon"><i title="'.$WebUserCountLabel.'" class="fa fa-users fa-4x"></i></div>
<div class="count"><h3 class="counter"> '.$count.' </h3> '.$WebUserCountLabel.' </div>
</div>
</div>

<div class="col-lg-3 col-sm-6 col-xs-6">
<div class="statbox syellow">
<div class="staticon"><i title="'.$UserCountLabel.'" class="fa fa-user fa-4x"></i></div>
<div class="count"><h3 class="counter"> '.$userscount.' </h3> '.$UserCountLabel.' </div>
</div>
</div>

<div class="col-lg-3 col-sm-6 col-xs-6">
<div class="statbox sred">
<div class="staticon"><i title="'.$AdminCountLabel.'" class="fa fa-user-md fa-4x"></i></div>
<div class="count"><h3 class="counter"> '.$admincount.' </h3> '.$AdminCountLabel.' </div>
</div>
</div>
</div>
</div>
';

$e = &$modx->Event;
switch($e->name){
/*load styles with OnManagerMainFrameHeaderHTMLBlock*/
case 'OnManagerMainFrameHeaderHTMLBlock':
   if ($Style == 'box') {$cssOutput = '<link type="text/css" rel="stylesheet" href="../assets/plugins/dashboardstats/box.css">';}
   if ($Style == 'round') {$cssOutput = '<link type="text/css" rel="stylesheet" href="../assets/plugins/dashboardstats/round.css">';}
   if ($Style == 'lite') {$cssOutput = '<link type="text/css" rel="stylesheet" href="../assets/plugins/dashboardstats/lite.css">';}
		$e->output($cssOutput);
break;
case 'OnManagerWelcomeHome':
			$widgets['test'] = array(
				'menuindex' =>'1',
				'id' => 'DashboardStats'.$pluginid.'',
				'cols' => 'col-md-'.$wdgsizex.'',
                'headAttr' => 'style="background-color:'.$HeadBG.'; color:'.$HeadColor.';"',
				'bodyAttr' => 'style="background-color:'.$BodyBG.'; color:'.$BodyColor.';"',
				'icon' => ''.$wdgicon.'',
				'title' => ''.$wdgTitle.' '.$button_pl_config.'',
				'body' => '<div class="col-lg-12 col-md-12 col-sm-12 statcontainer">'.$WidgetOutput.' </div>'
			);
            $e->output(serialize($widgets));
    break;
}
}
