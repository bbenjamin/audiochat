package
{
	import flash.events.ActivityEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
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
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.rpc.xml.SimpleXMLEncoder;
	
	import spark.components.Group;
	
	//import spark.components.Label;
	
	//include "ActionScript/main.as";
	//import ActionScript.main;
	
	
	public class ChatController extends Application
	{
		//Security.LOCAL_TRUSTED;
		
		private var nc:NetConnection = null;
		private var camera:Camera;
		private var microphone:Microphone;
		private var nsPublish:NetStream = null;                      
		private var nsPlay1:NetStream = null;
		private var nsPlay2:NetStream = null;
		private var nsPlay3:NetStream = null;
		private var nsPlay4:NetStream = null;
		
		//private var Camera:Video;
		private var videoRemote1:Video;
		private var videoRemote2:Video;
		private var videoRemote3:Video;
		private var videoRemote4:Video;
		private var isEnabled:Boolean;
		public var videoRemoteContainer1:UIComponent;
		public var videoRemoteContainer2:UIComponent;
		public var videoRemoteContainer3:UIComponent;
		public var videoRemoteContainer4:UIComponent;
		public var videoCameraContainer:UIComponent;
		public var doPublish:Button;
		public var startTalking:Button;
		public var doSubscribe1:Button;
		public var doSubscribe2:Button;
		public var doSubscribe3:Button;
		public var doSubscribe4:Button;
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
		
		public function mainInit(picked:String):void
		{
			playerVersion.text = Capabilities.version+" (Flex)";
			stage.align = "TL";
			stage.scaleMode = "noScale";
			//videoCamera = new Video(180, 120);
			//videoCameraContainer.addChild(videoCamera);
			videoRemote1 = new Video(12, 8);
			videoRemote2 = new Video(12, 8);
			videoRemote3 = new Video(12, 8);
			videoRemote4 = new Video(12, 8);
			videoRemoteContainer1.addChild(videoRemote1);
			videoRemoteContainer2.addChild(videoRemote2);
			videoRemoteContainer3.addChild(videoRemote3);
			videoRemoteContainer4.addChild(videoRemote4);
			
			subscribeName1.text = "mp3:A1";
			subscribeName2.text = "mp3:A2";
			subscribeName3.text = "mp3:A3";
			subscribeName4.text = "mp3:A4";
			
			//TOGGLE COMMENTS TO SWITCH BETWEEN DEV AND LIVE
			//DEV
			//connectStr.text = "rtmp://localhost/videochat";
			//LIVE
			connectStr.text = "rtmp://ec2-50-16-141-16.compute-1.amazonaws.com/audiochat";
			
			skip = makeSkip(picked);
			//Alert.show(String(skip));
			
			//connectButton.addEventListener(MouseEvent.CLICK, doConnect);
			
			//startTalking.addEventListener(MouseEvent.CLICK, subscribeAll);
			
			
			publishName.text = "mp3:" +picked;
			enablePlayControls(false);
			if(skip >= 0){
				startCamera();
			}	
			
			
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
				options.autoGain = false;
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
			trace("activating=" + event.activating + ", activityLevel=" + 
				microphone.activityLevel);
			//Alert.show("done changed");
			
			
		}
		
		private function onMicStatus(event:StatusEvent):void
		{
			trace("status: level=" + event.level + ", code=" + event.code);
			
			//meter.measuredHeight = myMic.activityLevel;
		}
		
		private function ncOnStatus(infoObject:NetStatusEvent):void
		{
			trace("nc: "+infoObject.info.code+" ("+infoObject.info.description+")");
			if (infoObject.info.code == "NetConnection.Connect.Success" ){
				
				if(skip >=0){publish2();}
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
			////trace("nDO CONNECT CALLED  ");
			//var vids:Array  = new Array();
			var availables:Array = new Array();
			//vids = [videoRemote1,videoRemote2,videoRemote3,videoRemote4];
			availables = [available1,available2,available3,available4];
			if (nc == null)
			{
				// create a connection to the wowza media server
				nc = new NetConnection();
				
				nc.connect(connectStr.text);
				////trace("netConnect got connectd  ");
				// get status information from the NetConnection object
				nc.addEventListener(NetStatusEvent.NET_STATUS, ncOnStatus);
				//nc. = publish2();
				connectButton.label = "Stop";
				
				// uncomment this to monitor frame rate and buffer length
				//setInterval(updateStreamValues, 500);
				/*
				videoCamera.clear();
				videoCamera.attachCamera(camera);
				*/
				
				//videoRemote1.clear();
				//videoRemote1.attachCamera(camera);
				
				if(skip >= 0){
					////trace('what is skip ' +skip);
					/*	vids[skip].clear();
					vids[skip].attachCamera(camera);
					var tempVid:Video =  vids[skip] as Video;
					*/
					//available1.visible = false;
					var tempLabel:Label = availables[skip] as Label;
					
					tempLabel.visible = false;
				}
				
				enablePlayControls(true);
				//publish2();
			}
			else
			{
				
				nsPublish = null;
				nsPlay1 = null;
				/*
				videoCamera.attachCamera(null);
				videoCamera.clear();
				*/
				//videoRemote1.attachCamera(null);
				//videoRemote1.clear();
				/*
				vids[skip].attachCamera(null);
				vids[skip].clear();
				
				delete vids[skip];
				
				for each(var vid:Video in vids){
				vid.attachNetStream(null);
				vid.clear();
				//subscribes.refresh();
				}
				*/
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
				////trace("netConnect got disconnectd  ");
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
			////trace('infoObjectName ' +streamName);
			
			////trace("nsPlay1: "+infoObject.info.code+" ("+infoObject.info.description+")");
			if (infoObject.info.code == "NetStream.Play.StreamNotFound" || infoObject.info.code == "NetStream.Play.Failed"){
				////trace(infoObject.info.description);
			}	
			if (infoObject.info.code == "NetStream.Play.UnpublishNotify"){
				
				////trace (' shut down loop ' + streamName);
				switch(streamName){
					case 'A1':
						nsPlay1.play(null);
						nsPlay1.close();					
						//videoRemote1.clear();
						available1.visible = true;
						// ('SHUT ' + streamName);
						break;
					case 'A2':
						nsPlay2.play(null);
						nsPlay2.close();
						//videoRemote2.clear();
						available2.visible = true;
						////trace ('SHUT ' + streamName);
						break;
					case 'A3':
						nsPlay3.play(null);
						nsPlay3.close();
						//videoRemote3.clear();
						available3.visible = true;
						////trace ('SHUT ' + streamName);
						break;
					case 'A4':
						nsPlay4.play(null);
						nsPlay4.close();
						//videoRemote4.clear();
						available4.visible = true;
						////trace ('SHUT ' + streamName);
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
		public function subscribeAll(slotsInUseAc:Object):void
		{
			//subscribeSlots is a class variable that keeps track of taken slots
			//slotsInUse is passed in on the timer, seeing if status has changed
			//new slots is created on each call compares subscitve 
			
			var newSlots1:Array;
			var newSlots:ArrayCollection = new ArrayCollection(newSlots1);
			var newSub:Boolean = false;
			var slXML:XML = new XML();
			var lilXML:XMLList = new XMLList;
			//cylce through the current slots in use, add new ones to newSlots
			////trace('in subscribe all');
			////trace('before slots null');
			////trace('slotinuse ' + slotsInUseAc);
			
			
			if(slotsInUseAc == null){return;}
			else{newSub =true;}
			slXML = objectToXML(slotsInUseAc);
			
			////trace('slxml length ' +slXML.children().length());
			if(slXML.children().length() == 1){
				//if(slotsInUseAc.source.length == 1){
				lilXML = slXML.slot; 
			}else{
				lilXML = slXML.source..slot; 
				
			}
			////trace('lilxmllengh' + lilXML.length());
			// myXML..lastName
			////trace('lilxml ' +lilXML);
			
			if(lilXML.length() < 1){return;}
			if(lilXML.length() == 1){
				var innt:int = makeSkip(lilXML);
				////trace('one slot taken by ' + lilXML );
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
					break;}
				//trace('sltvariable: ' +slt + ' iltvariable ' + ilt); 
				
				if( subscribeSlots == null){
					newSlots.addItem(ilt);
					//trace('added first' + ilt + 'to new slots');
					newSub = true;
				}
				else if(!subscribeSlots.contains(ilt)){
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
				/*
				nsPlay1 = new NetStream(nc);
				nsPlay2 = new NetStream(nc);
				nsPlay3 = new NetStream(nc);
				nsPlay4 = new NetStream(nc);
				*/
				for each( var pos:int in newSlots.source ){
					//trace('create netstream for ' + pos );
					//if(pos == skip){continue;}
					//nsPlays[pos] = new NetStream(nc);
					switch(pos){
						case 0:
							available1.visible = false;
							nsPlay1 = new NetStream(nc);
							nsPlay1.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);				
							break;
						case 1:
							available2.visible = false;
							nsPlay2 = new NetStream(nc);
							nsPlay2.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							break;
						case 2:
							available3.visible = false;
							nsPlay3 = new NetStream(nc);
							nsPlay3.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							break;
						case 3:
							available4.visible = false;
							nsPlay4 = new NetStream(nc);
							nsPlay4.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							break;
						
					}
					
				}
				
				// //trace the NetStream status information
				/*
				nsPlay1.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
				nsPlay2.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
				nsPlay3.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
				nsPlay4.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
				*/
				for each( var poss:int in newSlots.source ){
					//nsPlays[poss].addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
					//if(poss == skip){continue;}
					switch(poss){
						case 0:
							nsPlay1.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							break;
						case 1:
							nsPlay2.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							break;
						case 2:
							nsPlay3.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							break;
						case 3:
							nsPlay4.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
							break;
						
					}
					////trace('event listener for ' + poss );
				}
				/*
				var nsPlayClientObj1:Object = new Object();
				var nsPlayClientObj2:Object = new Object();
				var nsPlayClientObj3:Object = new Object();
				var nsPlayClientObj4:Object = new Object();
				*/
				for each( var posz:int in newSlots.source ){
					//nsPlayClientObjs[posz]= new Object();
					//if(posz == skip){continue;}
					switch(posz){
						case 0:
							var nsPlayClientObj1:Object = new Object();
							break;
						case 1:
							var nsPlayClientObj2:Object = new Object();
							break;
						case 2:
							var nsPlayClientObj3:Object = new Object();
							break;
						case 3:
							var nsPlayClientObj4:Object = new Object();
							break;
						
					}
					
					//trace('new init of object ' +posz);
				}
				
				/*
				nsPlay1.client = nsPlayClientObj1;
				nsPlay2.client = nsPlayClientObj2;
				nsPlay3.client = nsPlayClientObj3;
				nsPlay4.client = nsPlayClientObj4;
				*/
				for each( var pozz:int in newSlots.source ){
					//nsPlays[pozz].client= nsPlayClientObjs[pozz];
					//if(pozz == skip){continue;}
					switch(pozz){
						case 0:
							nsPlay1.client = nsPlayClientObj1;
							break;
						case 1:
							nsPlay2.client = nsPlayClientObj2;
							break;
						case 2:
							nsPlay3.client = nsPlayClientObj3;
							break;
						case 3:
							nsPlay4.client = nsPlayClientObj4;
							break;
						
					}
					//trace('new nsplay client for ' + pozz);
				}
				/*
				for each( var perz:int in newSlots.source ){
				nsPlayClientObjs[perz].onMetaData = function(infoObject:Object):void
				{
				//trace("onMetaData");
				
				// print debug information about the metaData
				for (var propName:String in infoObject)
				{
				//trace("  "+propName + " = " + infoObject[propName]);
				}
				};		
				//trace('metada slot ' + perz);
				}
				*/
				/*
				nsPlayClientObj1.onMetaData = function(infoObject:Object):void
				{
				//trace("onMetaData");
				
				// print debug information about the metaData
				for (var propName:String in infoObject)
				{
				//trace("  "+propName + " = " + infoObject[propName]);
				}
				};		
				*/
				// set the buffer time to zero since it is chat
				/*
				nsPlay1.bufferTime = 0;
				nsPlay2.bufferTime = 0;
				nsPlay3.bufferTime = 0;
				nsPlay4.bufferTime = 0;
				*/
				for each( var pstn:int in newSlots.source ){
					//trace('pre buffertime ' + pstn); 
					//nsPlays[pstn].bufferTime = 0;
					//if(pstn == skip){continue;}
					switch(pstn){
						case 0:
							nsPlay1.bufferTime = 0;
							break;
						case 1:
							nsPlay2.bufferTime = 0;
							break;
						case 2:
							nsPlay3.bufferTime = 0;
							break;
						case 3:
							nsPlay4.bufferTime = 0;
							break;
						
					} 
				}
				
				// subscribe to the named stream
				/*
				nsPlay1.play(subscribeName1.text);
				nsPlay2.play(subscribeName2.text);
				nsPlay3.play(subscribeName3.text);
				nsPlay4.play(subscribeName4.text);
				*/
				for each( var postrn:int in newSlots.source ){
					//trace('play stream pos =' + postrn + ' and skip is ' + skip);
					//trace('st =' + postrn);
					
					if(postrn == skip){continue;}
					//trace('THE ONE THAT SKIPPED' + postrn);
					//var strmName:String = subscribeNames[0][postrn].text;
					////trace('play stream name ' + strmName );
					//nsPlays[postrn].play(strmName);
					switch(postrn){
						case 0:
							nsPlay1.play(subscribeName1.text);
							
							break;
						case 1:
							nsPlay2.play(subscribeName2.text);
							break;
						case 2:
							nsPlay3.play(subscribeName3.text);
							break;
						case 3:
							nsPlay4.play(subscribeName4.text);
							break;
						
					} 
				}
				
				
				
				/*
				videoRemote1.attachNetStream(nsPlay1);
				videoRemote2.attachNetStream(nsPlay2);
				videoRemote3.attachNetStream(nsPlay3);
				videoRemote4.attachNetStream(nsPlay4);
				*/
				for each( var poztn:int in newSlots.source ){
					//trace('play the ' + poztn +' skip='+skip);
					if(poztn == skip){
						continue;
						
					}
					//trace('attach net stream for' + poztn +' skip='+skip);
					/*
					switch(poztn){
					case 0:
					videoRemote1.attachNetStream(nsPlay1);
					//available1.visible = false;
					
					break;
					case 1:
					videoRemote2.attachNetStream(nsPlay2);
					//available2.visible = false;
					break;
					case 2:
					videoRemote3.attachNetStream(nsPlay3);
					//available3.visible = false;
					break;
					case 3:
					videoRemote4.attachNetStream(nsPlay4);
					//available4.visible = false;
					break;
					
					}
					*/
					//videoRemotes[poztn].attachNetStream(nsPlays[poztn]);
					//trace('ATTACHED THA NET STREAM ' + poztn );
				}
				
				doSubscribe4.label = 'Stop';
			}
			else
			{		
				// here we are shutting down the connection to the server
				//videoRemote1.attachNetStream(null);
				//videoRemote2.attachNetStream(null);
				/*
				videoRemote4.attachNetStream(null);
				nsPlay1.play(null);
				nsPlay1.close();
				
				//doSubscribe1.label = 'Play';
				//doSubscribe2.label = 'Play';
				doSubscribe4.label = 'Play';
				*/
			}
			for each( var st:int in newSlots.source ){
				subscribeSlots.addItem(st);
				//trace('added subscription ' + st);
			}
			for each( var sll:int in subscribeSlots.source ){
				////trace('might close ' + sll);
				//if(sll == skip){continue;}
				////trace('will close ' + sll);
				
				/*switch(sll){
				case 0:
				nsPlay1.play(null);
				nsPlay1.close();
				break;
				case 1:
				nsPlay2.play(null);
				nsPlay2.close();
				break;
				case 2:
				nsPlay3.play(null);
				nsPlay3.close();
				break;
				case 3:
				nsPlay4.play(null);
				nsPlay4.close();
				break;
				
				}
				*/
				/*
				if(sll == -1){ break; }
				//trace('SUBSCRIBE SLOTS HAS '+ sll + ' close stream');
				//if(!slotsInUseAc.contains(sll))
				//if(! sll in slotsInUseAc){
				if(! sll in lilXML){
				
				//trace('DID NOT FIND '+ sll + ' IN SLOTS IN USE');
				nsPlays[sll].play(null);
				nsPlays[sll].close();
				}
				*/
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
		
		public function publish2():void
		{
			//trace('we made it to publish2');
			//doConnect2();
			//if (doPublish.label != 'Stop')
			//{
			// create a new NetStream object for video publishing
			//Alert.show(nc + ' || NSPUBLISH');	
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
			//}
			/*else
			{
			// here we are shutting down the connection to the server
			nsPublish.attachCamera(null);
			nsPublish.attachAudio(null);
			nsPublish.publish("null");
			nsPublish.close();
			
			doPublish.label = 'Publish';
			}
			*/
		}
		public function makeSkip(slotStr:String):int{
			var skp:int;
			////trace('slot string: ' + slotStr);
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