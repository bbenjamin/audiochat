// ActionScript file
/*******************************************************
 * Copyright 2008-2009 FlexAppsStore.com
 * See EULA for Protection of this file @
 * http://www.FlexAppsStore.com
 ********************************************************/

import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.controls.Alert;
import mx.events.ListEvent;

private var t:Timer;
private var baseTimer:int;
private var sec:String;
private var ms:String;
private const SEC_MASK:String = "00";
private const MS_MASK:String = "000";

private function switchstring(st:String):int{
	var inttt:int;
	switch(st){
		case "A1":
			inttt = 1;
			
			break;
		case "A2":
			inttt = 2;
			break;
		case "A3":
			inttt = 3;
			break;
		case "A4":
			inttt = 4;
			break;
		default:
			inttt = -1;
			break;
	}	
	return inttt;	
}

private function slots():void{
	mysqlQuery("SELECT slot FROM slots WHERE active=0","slots");
}
private function activeSlots():void{
	//mysqlQuery("SELECT slot FROM slots WHERE active=1 AND slot LIKE 'S%'","activeSlots");
	mysqlQuery("SELECT slot FROM slots WHERE active=1","activeSlots");
}
private function takeSlot():void{
	//var qur:String = "UPDATE slots SET active=1 WHERE slot='"+picked+"'";
	var idd:int;
	idd = switchstring(picked);
	if(picked == 'Listener'){
		return;
	}
	else{
		var qur:String = "UPDATE slots SET active=1 WHERE slot='" + picked + "'";
		//trace(qur);
		mysqlQuery(qur,"takeslot");
	}
	/*
	if (idd >= 0){
	var qur:String = "UPDATE slots SET active=1 WHERE id="+idd;
	trace(qur);
	mysqlQuery(qur,"takeslot");
	
	}
	*/
}

public function leaveSlot(sl:String):void{
	var idd:int;
	idd = switchstring(picked);
	if (idd >= 0){
		//var qur:String = "UPDATE slots SET active=0 WHERE id="+idd;
		//mysqlQuery(qur,"leaveslot");
	}
}

/*	
private function f1(event:TimerEvent):void {


var d:Date = new Date(getTimer() - baseTimer);
sec = (SEC_MASK + d.seconds).substr(-SEC_MASK.length);
ms = (MS_MASK + d.milliseconds).substr(-MS_MASK.length);

}


private function test():void {
mainbar.visible = true;
mysqlQuery("SELECT * FROM geo_master where city like '%Las%' LIMIT 100","test");
}

private function getCount():void {
mysqlQuery("SELECT COUNT(*) as mycount from geo_master","getCount");
}

private function startLarge():void {
statbar.visible = true;
t = new Timer(10);

t.addEventListener(TimerEvent.TIMER, f1);

t.start();

mysqlQuery ("SELECT count(*) as cnt1 FROM tbl_big","getTotalLarge");

mysqlQuery("SELECT count(*) as cnt1 FROM tbl_big " + 
"WHERE city like '%a%'","startLarge");

}



private function getStates():void {
mysqlQuery("SELECT DISTINCT(state) as zstate from geo_master order by state","getStates");
}

private function statesMostCities():void {
mysqlQuery("SELECT DISTINCT(state) as zstate, count(city) as zcnt " +
"from geo_master " +
"where state <> '' " +
"group by zstate  " +
"order by zcnt desc " +
"limit 10","statesMostCities");
}

private function doSearch():void {
mysqlQuery("SELECT * FROM geo_master " + 
"WHERE zip = '"+txtZip.text+"'","doSearch");
}


private function doError():void {
//This table does not exist
mysqlQuery("SELECT city, states FROME geo_master","doError");

}




private function getDataforCB():void {
mysqlQuery("SELECT * FROM geo_master order by zip desc limit 100","getDataforCB");
}


private function cbExample(event:ListEvent):void {
lblCB.text = "City: " + event.currentTarget.selectedItem.city + " - State: " + event.currentTarget.selectedItem.state;	
}
*/


// ActionScript file