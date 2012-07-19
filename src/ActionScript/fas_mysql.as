// ActionScript file
/*******************************************************
 * Copyright 2008-2009 FlexAppsStore.com
 * See EULA for Protection of this file @
 * http://www.FlexAppsStore.com
 ********************************************************/

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.managers.PopUpManager;
import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.mxml.HTTPService;
import mx.utils.ArrayUtil;

private var sqlToken:AsyncToken;

/********************************************************
 * Your Configuration Paramaters
 * 
 *********************************************************/
//Enter the name of your database

public var mysql_db:String = "audioflasho"; 

//Enter the url to the php file you placed on your MySQL webserver
//LIVE
//public var mysql_url:String = "http://ec2-50-16-141-16.compute-1.amazonaws.com/flexsqlaudio.php"; 
//http://23.21.77.1/
public var mysql_url:String = "http://ec2-23-21-77-1.compute-1.amazonaws.com/flexsqlaudio.php"; 
//DEV
//public var mysql_url:String = "http://localhost:8888/flexmysqlconn.php"; 


// Enter your private key. This should be a 10 digit string of letters and numbers
// that you make up to minimize the risk of SQL injection against your PHP script.
// This can be anything you want. This key will also need to be entered in the
// flexmysqlconn.php file. 

public var private_key:String = "11234ABCDE";


/********************************************************
 * This function replaces the httpService method.
 * You only need to edit your database name.
 * The url property should be fine.
 * 
 *********************************************************/
public function mysqlQuery(sql:String,fid:String):void {
	
	var http:HTTPService = new HTTPService;
	var parm:Object = new Object;
	
	//showBusyCursor="false"
	
	parm.fas_sql = sql;
	parm.private_key = private_key;
	parm.fas_db = mysql_db; 
	http.url = mysql_url+"?irand="+Math.random();
	
	http.showBusyCursor = false;
	http.request = sql;
	http.addEventListener(ResultEvent.RESULT, mysqlResult);
	http.addEventListener(FaultEvent.FAULT, mysqlFault);
	http.method = "POST";
	
	sqlToken = http.send(parm);
	sqlToken.param = fid;
}

private function mysqlFault(event:FaultEvent):void {
	var err:String = event.fault.faultString;
	Alert.show(err);
}

/********************************************************
 * mysqlResult() should be used to handle all of the
 * returns of your queries. This will end up being a 
 * long case list.
 * 
 *********************************************************/


private function mysqlResult(event:ResultEvent):void{
	
	
	switch(event.token.param){
		
		//Note: All Results are stored in the
		// event.result object
		
		//Create a new case/break for each of your
		//sql query statements
		case "activeSlots":
			
			
			
			inUse = event.result.results.record;
			
			break;
		
		case "signIn":
			takeIt(tempButton, tempSlott);
			PopUpManager.removePopUp(panel);
			break;
		
		case "slotName":
			
			break;
		
		case "startDB":
			dbCheck = new Object;
			
			dbCheck = event.result.results.record;
			
			break;
		case "takeslot":
			//connectQuery();
			break;
		
		case "slots":
			//dropDown.dataProvider = event.result.results.record;	
			//dropDown.labelField = "slot";	
			//activeList.dataProvider = event.result.results.record;
			//activeList.labelField = "slot";
			
			break;
		
		
	}	
}


/********************************************************
 * Functions: Shared Functions
 * 
 *********************************************************/

public function addslashes(tt:String):String{
	var ttt:String = tt.replace(/\u0027+/g,"\\'");
	//return ttt;
	return tt;
}
// ActionScript file