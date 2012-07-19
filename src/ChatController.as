package
{
	import flash.events.ActivityEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.MicrophoneEnhancedMode;
	import flash.media.MicrophoneEnhancedOptions;
	import flash.media.SoundCodec;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.utils.Timer;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	import mx.rpc.xml.SimpleXMLEncoder;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.primitives.Rect;
	
	//import spark.components.Label;
	
	//include "ActionScript/main.as";
	//import ActionScript.main;
	
	
	public class ChatController extends Application
	{
		//Security.LOCAL_TRUSTED;
		public var mike:Boolean = false; 
		public var scrubbed:Boolean =false;	
		private var nc:NetConnection = null;
		private var camera:Camera;
		private var microphone:Microphone;
		private var nsPublish:NetStream = null;                      
		private var nsPlay1:NetStream = null;
		private var nsPlay2:NetStream = null;
		private var nsPlay3:NetStream = null;
		private var nsPlay4:NetStream = null;
		private var theName:String
		//private var Camera:Video;
		private var videoRemote1:Video;
		private var videoRemote2:Video;
		private var videoRemote3:Video;
		private var videoRemote4:Video;
		private var isEnabled:Boolean;
		public var loadingLabel:Label;
		public var videoRemoteContainer1:UIComponent;
		public var videoRemoteContainer2:UIComponent;
		public var videoRemoteContainer3:UIComponent;
		public var videoRemoteContainer4:UIComponent;
		public var videoCameraContainer:UIComponent;
		public var doPublish:Button
		public var startTalking:Button;
		public var doSubscribe1:Button;
		public var doSubscribe2:Button;
		public var doSubscribe3:Button;
		public var doSubscribe4:Button;
		public var subscribeButtons:Array = new Array([doSubscribe1,doSubscribe2,doSubscribe3,doSubscribe4]);
		public var connectButton:Button;
		public var fpsText:Text;
		public var bufferLenText:Text;
		public var connectStr:TextInput;
		public var otherStr:TextInput;
		public var publishName:TextInput;
		public var subscribeName1:TextInput;
		public var subscribeName2:TextInput;
		public var subscribeName3:TextInput;
		public var subscribeName4:TextInput;
		public var playerVersion:Text;
		public var prompt:Text;
		public var prompt2:Text;
		public var skip:int;
		public var subscribeSlots1:Array;
		public var subscribeSlots:ArrayCollection = new ArrayCollection(subscribeSlots1);
		public var available1:Label;
		public var available2:Label;
		public var available3:Label;
		public var available4:Label;
		public var vidScreen:Group;
		public var meter1:Rect;
		public var meter2:Rect;
		public var meter3:Rect;
		public var meter4:Rect;
		
		public var tok:Timer = new Timer(100);
		public var levelNow:Number;
		public var levelTemp1:Number = 0;
		public var levelTemp2:Number = 0;	
		public var levelTemp3:Number = 0;		
		public var levelTemp4:Number = 0;
		public var levelTemps:Array = new Array([levelTemp1,levelTemp2,levelTemp3,levelTemp4]);
		
		public var user1:String;
		public var user2:String;
		public var user3:String;
		public var user4:String;
		
		
		//public var smack:spark.component
		//public var smack:spark.components.Label;
		//public var nsPlayClientObj1:Object; //= new Object();
		//public var nsPlayClientObj2:Object; //= new Object();
		//public var nsPlayClientObj3:Object; //= new Object();
		//public var nsPlayClientObj4:Object;
		//public var inUse:ArrayCollection;
		
		public function ChatController()
		{
			//empty as not using constructor
		}
		public function updateMeter(lev:Number, mtr:Rect, channl:Number):void{
		
			
			levelNow = lev;
			if (levelNow < levelTemps[channl]){
				mtr.percentWidth = levelTemps[channl] - ((levelTemps[channl] - levelNow) /2);
			}
			else{
				mtr.percentWidth = levelNow;
			}
			levelTemps[channl] = mtr.percentWidth;
			//trace('meter ' +mtr.percentWidth);
		
		}
		public function levelCheck(event:TimerEvent):void {
			//var nsPlays:Array = new Array([nsPlay1,nsPlay2,nsPlay3,nsPlay4]);
			//for each(var nsp:NetStream in nsPlays){
				
			//}
			//var buffVal:Number = (nsPlay1.info.audioBytesPerSecond /nsPlay1.info.maxBytesPerSecond) *100;
			
			var meters:Array = new Array(meter1,meter2,meter3,meter4);
			//Alert.show("done changed");
			if(mike && skip >=0){
				updateMeter(microphone.activityLevel ,  meters[skip], skip);
				//trace(microphone.activityLevel);
			};
			if( nsPlay1 != null){
				
				//trace('BUFF LEV' + nsPlay1.info.audioBytesPerSecond);
				//trace('MAX BUFF LEV' + nsPlay1.info.maxBytesPerSecond);
				updateMeter((nsPlay1.info.audioBytesPerSecond /3000) *100,meter1,0);
			}
			if( nsPlay2 != null){
				//trace('BUFF LEV' + nsPlay2.info.audioBytesPerSecond);
				//trace('MAX BUFF LEV' + nsPlay2.info.maxBytesPerSecond);
				updateMeter((nsPlay2.info.audioBytesPerSecond /3000) *100,meter2,1);
			}
			if( nsPlay3 != null){
				//trace('BUFF LEV' + nsPlay3.info.audioBytesPerSecond);
				//trace('MAX BUFF LEV' + nsPlay3.info.maxBytesPerSecond);
				updateMeter((nsPlay3.info.audioBytesPerSecond /3000) *100,meter3,2);
			}
			if( nsPlay4 != null){
				//trace('BUFF LEV' + nsPlay4.info.audioBytesPerSecond);
				updateMeter((nsPlay4.info.audioBytesPerSecond /3000) *100,meter4,3);
			}
			
		}
		
		public function mainInit(picked:String):void
		{
			
			playerVersion.text = Capabilities.version+" (Flex)";
			//stage.align = "TL";
			//stage.scaleMode = "noScale";
			//videoCamera = new Video(180, 120);
			//videoCameraContainer.addChild(videoCamera);
			/*
			videoRemote1 = new Video(12, 8);
			videoRemote2 = new Video(12, 8);
			videoRemote3 = new Video(12, 8);
			videoRemote4 = new Video(12, 8);
			videoRemoteContainer1.addChild(videoRemote1);
			videoRemoteContainer2.addChild(videoRemote2);
			videoRemoteContainer3.addChild(videoRemote3);
			videoRemoteContainer4.addChild(videoRemote4);
			*/
			
			subscribeName1.text = "mp3:A1";
			subscribeName2.text = "mp3:A2";
			subscribeName3.text = "mp3:A3";
			subscribeName4.text = "mp3:A4";
			
			tok.addEventListener(TimerEvent.TIMER, levelCheck);
			tok.start();
			//TOGGLE COMMENTS TO SWITCH BETWEEN DEV AND LIVE
			//DEV
			//connectStr.text = "rtmp://localhost/videochat";
			//LIVE
			//connectStr.text = "rtmp://ec2-50-16-141-16.compute-1.amazonaws.com/audiochat";
			
			connectStr.text = "rtmp://ec2-23-21-77-1.compute-1.amazonaws.com/audiochat";
			skip = makeSkip(picked);
			//Alert.show(String(skip));
			
			//connectButton.addEventListener(MouseEvent.CLICK, doConnect);
			
			//startTalking.addEventListener(MouseEvent.CLICK, subscribeAll);

			//enablePlayControls(false);
			//if(skip >= 0){
			//	startCamera();
			//}	
			
			
		}
		
		
		private function startCamera():void
		{	
			//var subscribes:Array  = new Array();
			//subscribes = [subscribeName1,subscribeName2,subscribeName3,subscribeName4];
			//var subscr:ArrayCollection = new ArrayCollection(subscribes);
			// get the default Flash camera and microphone
			//	camera = Camera.getCamera();
			//microphone = Microphone.getMicrophone();
			//if(Capabilities.version.search('10,3') == -1){
				//Alert.show('Your flash player does not support echo cancellation');
			//}
			
			
			try{
				
				//microphone = Microphone.getMicrophone();
				microphone = Microphone.getEnhancedMicrophone();
				microphone.setUseEchoSuppression(true);
				var options:MicrophoneEnhancedOptions  = new MicrophoneEnhancedOptions();
				options.mode = MicrophoneEnhancedMode.FULL_DUPLEX;
				options.autoGain = true;
				options.echoPath = 128;
				
				options.nonLinearProcessing = true;
				microphone.enhancedOptions = options;
				//trace("getEnhancedMicrophone:OK");
				
			}catch(error:Error){
				microphone = Microphone.getMicrophone();
				Alert.show('Your flash player does not support echo cancellation. Use headset');
				//trace("getEnhancedMicrophone:SUCKED");
				
			}
			/*
			try {
			outputWindow.appendText(“getEnhancedMicrophone:OK\n”);
			r = Microphone.getEnhancedMicrophone(0);
			} catch(error:Error) {
			outputWindow.appendText(“\ngetEnhancedMicrophone:NOT avalaible\n”);
			outputWindow.appendText(“error: ” + error.message);
			r = Microphone.getMicrophone(0);
			}
			return r;
			}
			
			
			
			*/
			// here are all the quality and performance settings that we suggest
			//camera.setMode(180, 120, 15, false);
			//camera.setQuality(2000, 1);
			//camera.setKeyFrameInterval(30);
			//microphone.gain = 80;
			microphone.rate = 11;
			microphone.setSilenceLevel(10);
			microphone.setLoopBack(false);
			
			microphone.codec = SoundCodec.SPEEX; 
			microphone.encodeQuality = 5;
			microphone.framesPerPacket = 2;
			microphone.addEventListener(ActivityEvent.ACTIVITY, onMicActivity );
			microphone.addEventListener(StatusEvent.STATUS, onMicStatus);
			
			/*
			for each(var tx:TextInput in subscribes){
			tx.text = "testing";
			//subscribes.refresh();
			}
			*/
			/*
			subscribeName1.text = "A1";
			subscribeName2.text = "A2";
			subscribeName3.text = "A3";
			subscribeName4.text = "";
			*/
			//publishName.text = "testing";
			//publishName.text = picked;
			
			
		}
		
		private function onMicActivity(event:ActivityEvent):void
		{
			//trace("activating=" + event.activating + ", activityLevel=" + 
			//	microphone.activityLevel);
			/*
			var meters:Array = new Array(meter1,meter2,meter3,meter4);
			//Alert.show("done changed");
			updateMeter(microphone.activityLevel ,  meters[skip], skip);
			*/
			
		}
		
		private function onMicStatus(event:StatusEvent):void
		{
			//trace("status: level=" + event.level + ", code=" + event.code);
			mike = true;
			//meter.measuredHeight = myMic.activityLevel;
		}
		
		private function ncOnStatus(infoObject:NetStatusEvent):void
		{
			//trace("nc: "+infoObject.info.code+" ("+infoObject.info.description+")");
			if (infoObject.info.code == "NetConnection.Connect.Success" ){
				
				if(skip >=0){publish2('Listener');}
			}	
			
			
		}
		/*
		private function doConnect(event:MouseEvent):void
		{
		// connect to the Wowza Media Server
		if (nc == null)
		{
		// create a connection to the wowza media server
		nc = new NetConnection();
		nc.connect(connectStr.text);
		
		// get status information from the NetConnection object
		nc.addEventListener(NetStatusEvent.NET_STATUS, ncOnStatus);
		
		connectButton.label = "Stop";
		
		// uncomment this to monitor frame rate and buffer length
		//setInterval(updateStreamValues, 500);
		/*
		videoCamera.clear();
		videoCamera.attachCamera(camera);
		*/
		/*
		videoRemote1.clear();
		videoRemote1.attachCamera(camera);
		
		enablePlayControls(true);
		}
		else
		{
		nsPublish = null;
		nsPlay1 = null;
		
		//videoCamera.attachCamera(null);
		//videoCamera.clear();
		
		videoRemote1.attachCamera(null);
		videoRemote1.clear();
		
		videoRemote2.attachNetStream(null);
		videoRemote2.clear();
		
		videoRemote3.attachNetStream(null);
		videoRemote3.clear();
		
		videoRemote4.attachNetStream(null);
		videoRemote4.clear();
		
		nc.close();
		nc = null;
		
		enablePlayControls(false);
		
		doSubscribe1.label = 'Play';
		doSubscribe2.label = 'Play';
		doSubscribe3.label = 'Play';
		doSubscribe4.label = 'Play';
		doPublish.label = 'Publish';
		
		connectButton.label = "Connect";
		prompt.text = "";
		}
		}
		*/
		public function doConnect2():void
		{
			// connect to the Wowza Media Server
			//trace("nDO CONNECT CALLED  ");
			//var vids:Array  = new Array();
			var availables:Array = new Array();
			//vids = [videoRemote1,videoRemote2,videoRemote3,videoRemote4];
			availables = [available1,available2,available3,available4];
			if (nc == null)
			{
				// create a connection to the wowza media server
				nc = new NetConnection();
				
				nc.connect(connectStr.text);
				//trace("netConnect got connectd  ");
				// get status information from the NetConnection object
				nc.addEventListener(NetStatusEvent.NET_STATUS, ncOnStatus);
				//nc. = publish2();
				//connectButton.label = "Stop";
				
				// uncomment this to monitor frame rate and buffer length
				//setInterval(updateStreamValues, 500);
				/*
				videoCamera.clear();
				videoCamera.attachCamera(camera);
				*/
				
				//videoRemote1.clear();
				//videoRemote1.attachCamera(camera);
				
				if(skip >= 0){
					//trace('what is skip ' +skip);
					/*	vids[skip].clear();
					vids[skip].attachCamera(camera);
					var tempVid:Video =  vids[skip] as Video;
					*/
					//available1.visible = false;
					var tempLabel:Label = availables[skip] as Label;
					
					tempLabel.text = "This slot assigned to YOU!";
				}
				
				enablePlayControls(true);
				//publish2();
			}
			else
			{
				
				nsPublish = null;
				nsPlay1 = null;
				
				
				/*
				videoRemote2.attachNetStream(null);
				videoRemote2.clear();
				
				videoRemote3.attachNetStream(null);
				videoRemote3.clear();
				
				videoRemote4.attachNetStream(null);
				videoRemote4.clear();
				*/
				nc.close();
				nc = null;
				//trace("netConnect got disconnectd  ");
				enablePlayControls(false);
				
				doSubscribe1.label = 'Play';
				doSubscribe2.label = 'Play';
				doSubscribe3.label = 'Play';
				doSubscribe4.label = 'Play';
				
				doPublish.label = 'Publish';
				
				connectButton.label = "Connect";
				prompt.text = "";
			}
			//publish2();
		}
		
		private function enablePlayControls(isEnable:Boolean):void
		{
			doPublish.enabled = isEnable;
			doSubscribe1.enabled = isEnable;
			doSubscribe2.enabled = isEnable;
			doSubscribe3.enabled = isEnable;
			//doSubscribe4.enabled = isEnable;
			//doSubscribe.enabled = isEnable;
			//publishName.enabled = isEnable;
			subscribeName1.enabled = isEnable;
			subscribeName2.enabled = isEnable;
			subscribeName3.enabled = isEnable;
			subscribeName4.enabled = isEnable;
			//publish2();
		}
		
		// function to monitor the frame rate and buffer length
		private function updateStreamValues():void
		{
			if (nsPlay1 != null)
			{
				fpsText.text = (Math.round(nsPlay1.currentFPS*1000)/1000)+" fps";
				bufferLenText.text = (Math.round(nsPlay1.bufferLength*1000)/1000)+" secs";
			}
			else
			{
				fpsText.text = "";
				bufferLenText.text = "";
			}
		}
		
		private function nsPlayOnStatus(infoObject:NetStatusEvent):void
		{
			var streamName:String = infoObject.info.description;
			
			streamName = streamName.slice(0,2);
			//trace('infoObjectName ' +streamName);
			
			//trace("nsPlay1: "+infoObject.info.code+" ("+infoObject.info.description+")");
			if (infoObject.info.code == "NetStream.Play.StreamNotFound" || infoObject.info.code == "NetStream.Play.Failed"){
				//trace(infoObject.info.description);
			}	
			if (infoObject.info.code == "NetStream.Play.UnpublishNotify"){
				
				//trace (' shut down loop ' + streamName);
				switch(streamName){
					case 'A1':
						nsPlay1.play(null);
						nsPlay1.close();					
						//videoRemote1.clear();
						available1.visible = true;
						available1.text = 'this slot available..';
						meter1.percentWidth = 0;
						// ('SHUT ' + streamName);
						break;
					case 'A2':
						nsPlay2.play(null);
						nsPlay2.close();
						//videoRemote2.clear();
						available2.visible = true;
						available2.text = 'this slot available..';
						meter2.percentWidth = 0;
						//trace ('SHUT ' + streamName);
						break;
					case 'A3':
						nsPlay3.play(null);
						nsPlay3.close();
						//videoRemote3.clear();
						available3.visible = true;
						available3.text = 'this slot available..';
						meter3.percentWidth = 0;
						//trace ('SHUT ' + streamName);
						break;
					case 'A4':
						nsPlay4.play(null);
						nsPlay4.close();
						//videoRemote4.clear();
						available4.visible = true;
						available4.text = 'this slot available..';
						meter4.percentWidth = 0;
						//trace ('SHUT ' + streamName);
						break;
					
				}
				
			}
			/*
			if (infoObject.info.code == "NetConnection.Connect.Success" )
			Alert.show('yea we connecteddd!');
			*/
		}
		
		private function objectToXML(obj:Object):XML 
		{
			var qName:QName = new QName("root");
			var xmlDocument:XMLDocument = new XMLDocument();
			var simpleXMLEncoder:SimpleXMLEncoder = new SimpleXMLEncoder(xmlDocument);
			var xmlNode:XMLNode = simpleXMLEncoder.encodeValue(obj, qName, xmlDocument);
			var xml:XML = new XML(xmlDocument.toString());
			
			return xml;
		}
		
		
		//private function subscribeAll(event:MouseEvent):void
		public function subscribeAll(slotsInUseAc:Object, picked:String):void
		{
			//subscribeSlots is a class variable that keeps track of taken slots
			//slotsInUse is passed in on the timer, seeing if status has changed
			//new slots is created on each call compares subscitve 
			skip = makeSkip(picked);
			var newSlots1:Array;
			var newSlots:ArrayCollection = new ArrayCollection(newSlots1);
			var newSub:Boolean = false;
			var slXML:XML = new XML();
			var lilXML:XMLList = new XMLList;
			var nameXML:XMLList = new XMLList;
			var tempString:String = "";
			//cylce through the current slots in use, add new ones to newSlots
			//trace('in subscribe all');
			//trace('before slots null');
			//trace('slotinuse ' + slotsInUseAc);
			
			scrubbed = true;
			//trace('slotsInUseAc == null' + slotsInUseAc);
			if(slotsInUseAc == null){
				return;}
			else{newSub =true;}
			//trace('ITS NOT NULL, SKIP IS' + skip);
			slXML = objectToXML(slotsInUseAc);
			
			//trace('slxml length ' +slXML.children().length());
			//lilXML = slXML.source..slot; 
			//nameXML = slXML.source..username;
			
			if(slXML.children().length() == 2){
				//if(slotsInUseAc.source.length == 1){
				lilXML = slXML.slot; 
				nameXML = slXML.username; 
			}else{
				lilXML = slXML.source..slot; 
				nameXML = slXML.source..username;				
			}
			
			//trace('lilxmllengh' + lilXML.length());
			// myXML..lastName
			//trace('lilxml ' +lilXML);
			
			if(lilXML.length() < 1){return;}
			if(lilXML.length() == 1){
				var innt:int = makeSkip(lilXML);
				//trace('one slot taken by ' + lilXML );
				if(!subscribeSlots.contains(innt)){
					newSlots.addItem(innt);
					//trace('added more ' + innt + 'to new slots');
					newSub = true;
					
				}
				else{
					//return;
					//trace('skip subscrb');
				}
			}
			
			/*
			if(slotsInUseAc.source.length < 1){
			//trace('its no result');
			return;}
			*/
			//trace('slots in use: ' + slotsInUseAc);
			
			//var slotsInUse:Array = slotsInUseAc.toArray();
			for each( var slt:XML in lilXML ) {
				//trace('SLTSLOT ' + slt);
				var ilt:int = makeSkip(slt);
				if(ilt == -1){
					//trace('negative 1 break');
					continue;}
				//trace('sltvariable: ' +slt + ' iltvariable ' + ilt); 
				
				if( subscribeSlots == null){
					newSlots.addItem(ilt);
					//trace('added first' + ilt + 'to new slots');
					newSub = true;
				}
				else if(!subscribeSlots.contains(ilt) && !newSlots.contains(ilt) ){
					newSlots.addItem(ilt);
					//trace('added more ' + ilt + 'to new slots');
					newSub = true;
				}
			}
			
			
			// = new Object();
			//var nsPlayClientObjs:Array = new Array([nsPlayClientObj1,nsPlayClientObj2,nsPlayClientObj3,nsPlayClientObj4]);
			var doSubscribes:Array  = new Array([doSubscribe1,doSubscribe2,doSubscribe3,doSubscribe4]);
			//var videoRemotes:Array  = new Array([videoRemote1,videoRemote2,videoRemote3,videoRemote4]);
			var subscribeNames:Array  = new Array([subscribeName1,subscribeName2,subscribeName3,subscribeName4]);
			var nsPlays:Array  = new Array([nsPlay1,nsPlay2,nsPlay3,nsPlay4]);
			//if (doSubscribe4.label != 'Stop')
			if (newSub)
			{
				//trace("new subscription");
				// create a new NetStream object for video playback
				
				//assertTrue(myDict.hasOwnProperty("key")==true)
				
				var countr:int = 0
				for each( var pos:int in newSlots.source ){
				
					
					//trace('position =' +pos);
					
					//trace('create netstream for ' + pos );
					if(pos == skip){ 
					    //trace('counter skip ' + skip); 
						countr = countr +1;
						continue;}
					
					//var theName:String = ".";
					//if(nameXML[countr] == null){
					//if( nameXML[countr].hasOwnProperty('username')){
					theName = nameXML[countr];
					//trace('counter ' + countr +' skip=' +skip);
					//trace('the name ' +theName);
					//trace('nameXML[countr]' + nameXML[countr]);
					tempString = new String();
					//nsPlays[pos] = new NetStream(nc);
					switch(pos){
						case 0:
							//trace('the name 1' +theName);
							available1.text = "@ " + theName;
							available1.setStyle("fontSize", 16);
							nsPlay1 = new NetStream(nc);
							nsPlay1.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							doSubscribe1.visible = false;
							nsPlay1.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							var nsPlayClientObj1:Object = new Object();
							nsPlay1.client = nsPlayClientObj1;
							nsPlay1.bufferTime = 0;
							nsPlay1.play(subscribeName1.text);
							meter1.visible = true;
							
							break;
						case 1:
							//trace('the name 2' +theName);
							available2.text = "@ " + theName;
							available2.setStyle("fontSize", 16);
							nsPlay2 = new NetStream(nc);
							nsPlay2.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							doSubscribe2.visible = false;
							nsPlay2.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							var nsPlayClientObj2:Object = new Object();
							nsPlay2.client = nsPlayClientObj2;
							nsPlay2.bufferTime = 0;
							nsPlay2.play(subscribeName2.text);
							meter2.visible = true;
							break;
						case 2:
							//trace('the name 3' +theName);
							available3.text = "@ " + theName;
							available3.setStyle("fontSize", 16);
							nsPlay3 = new NetStream(nc);
							nsPlay3.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							doSubscribe3.visible = false;
							nsPlay3.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							var nsPlayClientObj3:Object = new Object();
							nsPlay3.client = nsPlayClientObj3;
							nsPlay3.bufferTime = 0;
							nsPlay3.play(subscribeName3.text);
							meter3.visible = true;
							break;
						case 3:
							//trace('the name 4' +theName);
							tempString = theName;
							//trace('tempString' + tempString);
							available4.setStyle("fontSize", 16);
							available4.text = "@ " + theName;
							//available4.text =  String(tempString);
							//
							nsPlay4 = new NetStream(nc);
							nsPlay4.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							doSubscribe4.visible = false;
							nsPlay4.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							var nsPlayClientObj4:Object = new Object();
							nsPlay4.client = nsPlayClientObj4;
							nsPlay4.bufferTime = 0;
							nsPlay4.play(subscribeName4.text);
							meter4.visible = true;
							break;
						
					}
					countr = countr +1;
				}
				
				// //trace the NetStream status information
				
				
				
				
				for each( var poztn:int in newSlots.source ){
				
				}
				
				//doSubscribe4.label = 'Stop';
			}
			
			for each( var st:int in newSlots.source ){
				subscribeSlots.addItem(st);
				//trace('added subscription ' + st);
			}
			

		}
		
		private function nsPublishOnStatus(infoObject:NetStatusEvent):void
		{
			//trace("nsPublish: "+infoObject.info.code+" ("+infoObject.info.description+")");
			if (infoObject.info.code == "NetStream.Play.StreamNotFound" || infoObject.info.code == "NetStream.Play.Failed")
				prompt.text = infoObject.info.description;
		}
		
		private function publish(event:MouseEvent):void
		{
			if (doPublish.label == 'Publish')
			{
				// create a new NetStream object for video publishing
				nsPublish = new NetStream(nc);
				
				nsPublish.addEventListener(NetStatusEvent.NET_STATUS, nsPublishOnStatus);
				
				// set the buffer time to zero since it is chat
				nsPublish.bufferTime = 0;
				
				// publish the stream by name
				nsPublish.publish(publishName.text);
				
				// add custom metadata to the stream
				//var metaData:Object = new Object();
				//metaData["description"] = "Chat using VideoChat example."
				//nsPublish.send("@setDataFrame", "onMetaData", metaData);
				
				// attach the camera and microphone to the server
				//nsPublish.attachCamera(camera);
				nsPublish.attachAudio(microphone);
				
				doPublish.label = 'Stop';
			}
			else
			{
				// here we are shutting down the connection to the server
				//nsPublish.attachCamera(null);
				nsPublish.attachAudio(null);
				nsPublish.publish("null");
				nsPublish.close();
				
				doPublish.label = 'Publish';
			}
		}
		
		public function publish2(picked:String):void
		{
			skip = makeSkip(picked);
			publishName.text = "mp3:" +picked;
			startCamera();
			//trace('we made it to publish2');
			//doConnect2();
			//if (doPublish.label != 'Stop')
			//{
			// create a new NetStream object for video publishing
			//Alert.show(nc + ' || NSPUBLISH');	
			var meters:Array = new Array(meter1,meter2,meter3,meter4);
			nsPublish = new NetStream(nc);
			
			nsPublish.addEventListener(NetStatusEvent.NET_STATUS, nsPublishOnStatus);
			
			// set the buffer time to zero since it is chat
			nsPublish.bufferTime = 0;
			
			// publish the stream by name
			nsPublish.publish(publishName.text);
			//trace('nsPublish.publish name: ' + publishName.text);
			// add custom metadata to the stream
			//var metaData:Object = new Object();
			//metaData["description"] = "Chat using VideoChat example."
			//nsPublish.send("@setDataFrame", "onMetaData", metaData);
			
			// attach the camera and microphone to the server
			//nsPublish.attachCamera(camera);
			nsPublish.attachAudio(microphone);
			
			doPublish.label = 'Stop';
			
			//trace(meters);
			//trace(skip);
			var pubMeter:Rect = meters[skip] as Rect;
			
			
			
			
			pubMeter.visible = true;
			pubMeter.fill = new SolidColor(0x660099, 0.9);
			switch(skip){
				case 0:
					
					available1.text = "THIS IS YOUR SLOT";
					available1.setStyle("fontSize", 16);
					break;
				case 1:
					available2.text = "THIS IS YOUR SLOT";
					available2.setStyle("fontSize", 16);
					break;
				case 2:
					available3.text = "THIS IS YOUR SLOT";
					available3.setStyle("fontSize", 16);
					break;
				case 3:
					available4.text = "THIS IS YOUR SLOT";
					available4.setStyle("fontSize", 16);
					break;
				
			}
			
			
			
		}
		
		public function unPublish(picked:String):void{
			skip = makeSkip(picked);
			nsPublish.attachAudio(null);
			nsPublish.publish("null");
			nsPublish.close();
			
			
			
			switch(skip){
				case 0:
				
					doSubscribe1.label = 'Take Slot 1';
					available1.text = 'this slot available.';
					available1.setStyle("fontSize", 10);
					
					break;
				case 1:
					doSubscribe2.label = 'Take Slot 2';
					available2.text = 'this slot available.';
					available1.setStyle("fontSize", 10);
				case 2:
					doSubscribe3.label = 'Take Slot 3';
					available3.text = 'this slot available.';
					available1.setStyle("fontSize", 10);
					break;
				case 3:
					doSubscribe4.label = 'Take Slot 4';
					available4.text = 'this slot available.';
					available1.setStyle("fontSize", 10);
					break;
				
			}
			
			doSubscribe1.visible = true;
			doSubscribe2.visible = true;
			doSubscribe3.visible = true;
			doSubscribe4.visible = true;
			skip = -1;
			//microphone = null;
			//mike = false;
			microphone.gain =0;
			
		}
		
		public function makeSkip(slotStr:String):int{
			var skp:int;
			//trace('slot string: ' + slotStr);
			switch(slotStr){
				case "A1":
					skp = 0;
					
					break;
				case "A2":
					skp = 1;
					break;
				case "A3":
					skp = 2;
					break;
				case "A4":
					skp = 3;
					break;
				default:
					skp = -1;
					break;
			}
			return skp;
		}
		
	}
}// ActionScript file