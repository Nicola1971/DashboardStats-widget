/**
 * DashboardStats 3.1 beta1
 *
 * Dashboard Stats widget plugin for Evolution CMS
 * @author    Nicola Lambathakis
 * @category    plugin
 * @version    3.1 beta2
 * @license	   http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @events OnManagerWelcomeHome,OnManagerMainFrameHeaderHTMLBlock
 * @internal    @installset base
 * @internal    @modx_category Dashboard
 * @author      Nicola Lambathakis http://www.tattoocms.it/
 * @documentation Requirements: This plugin requires Evolution 1.3.1 or later
 * @reportissues https://github.com/Nicola1971/WelcomeStats-EvoDashboard-Plugin/issues
 * @link        
 * @lastupdate  30/08/2017
 * @internal    @properties &wdgVisibility=Show widget for:;menu;All,AdminOnly;show &wdgTitle= Stats widget Title:;string;Evo Stats  &wdgicon= widget icon:;string;fa-bar-chart-o  &Style= Style:;list;box,round,lite;box &wdgposition=widget position:;list;1,2,3,4,5,6,7,8,9,10;1 &wdgsizex=widget x size:;list;12,6,4,3;12 &DocCountLabel= Documents count label:;string;Documents &startID= Documents count parent:;string;0 &WebUserCountLabel= Web Users label:;string;Web Users &webGroup= Users Web Group:;string;all &UserCountLabel= Manager Users label:;string;Manager Users &AdminCountLabel= Admin label:;string;Admins 
 */
// get manager role
$role = $_SESSION['mgrRole'];          
if(($role!=1) AND ($wdgVisibility == 'AdminOnly')) {}
else {
// get language
global $modx,$_lang;
// get plugin id
$result = $modx->db->select('id', $this->getFullTableName("site_plugins"), "name='{$modx->event->activePlugin}' AND disabled=0");
$pluginid = $modx->db->getValue($result);
if($modx->hasPermission('edit_plugin')) {
$button_pl_config = '<a data-toggle="tooltip" title="' . $_lang["settings_config"] . '" href="index.php?id='.$pluginid.'&a=102" class="text-muted pull-right" ><i class="fa fa-cog"></i> </a>';
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
$wua= $modx->getFullTableName('web_user_attributes');
$wgn= $modx->getFullTableName('webgroup_names');
$wg= $modx->getFullTableName('web_groups');

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
<div class="col-md-3 col-sm-6 col-xs-6">
<div class="statbox sblue">
<div class="staticon"><i class="fa fa-file fa-4x"></i></div>
<div class="count"><h3> '.$num.' </h3> '.$DocCountLabel.' </div>
</div> 
</div>

<div class="col-md-3 col-sm-6 col-xs-6">
<div class="statbox sgreen">
<div class="staticon"><i class="fa fa-users fa-4x"></i></div>
<div class="count"><h3> '.$count.' </h3> '.$WebUserCountLabel.' </div>
</div> 
</div>

<div class="col-md-3 col-sm-6 col-xs-6">
<div class="statbox syellow">
<div class="staticon"><i class="fa fa-user fa-4x"></i></div>
<div class="count"><h3> '.$userscount.' </h3> '.$UserCountLabel.' </div>
</div> 
</div>

<div class="col-md-3 col-sm-6 col-xs-6">
<div class="statbox sred">
<div class="staticon"><i class="fa fa-user-md fa-4x"></i></div>
<div class="count"><h3> '.$admincount.' </h3> '.$AdminCountLabel.' </div>
</div> 
</div>
';

$e = &$modx->Event;
switch($e->name){
/*load styles with OnManagerMainFrameHeaderHTMLBlock*/
case 'OnManagerMainFrameHeaderHTMLBlock':
	if ($Style == box) {$cssOutput = '<link type="text/css" rel="stylesheet" href="../assets/plugins/dashboardstats/box.css">';}
    if ($Style == round) {$cssOutput = '<link type="text/css" rel="stylesheet" href="../assets/plugins/dashboardstats/round.css">';}
    if ($Style == lite) {$cssOutput = '<link type="text/css" rel="stylesheet" href="../assets/plugins/dashboardstats/lite.css">';}
		$e->output($cssOutput);
break;
case 'OnManagerWelcomeHome':
			$widgets['test'] = array(
				'menuindex' =>'1',
				'id' => 'DashboardStats'.$pluginid.'',
				'cols' => 'col-md-'.$wdgsizex.'',
				'icon' => ''.$wdgicon.'',
				'title' => ''.$wdgTitle.' '.$button_pl_config.'',
				'body' => '<div class="col-md-12 col-sm-12 statcontainer">'.$WidgetOutput.' </div>'
			);	
            $e->output(serialize($widgets));
    break;
}
}