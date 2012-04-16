package tinbob.display
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class Seekbar extends Sprite
	{
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor References
		public var player:Object;
		public var w:Number;
		public var h:Number;
		public var borderV:Number;
		public var borderH:Number;
		public var value:Number;
		
		// Functional Objects
		public var stateBeforeInteraction:int;
		public var updateTicker:Timer;
		public var userInteracting:Boolean;
		
		// Display Objects
		public var base:Sprite;
		public var timeBar:Sprite;
		public var loadBar:Sprite;
		public var cursor:Sprite;
		
		private static const STATE_ENDED:int = 0;
		private static const STATE_PLAYING:int = 1;
		private static const STATE_PAUSED:int = 2;
		private static const STATE_CUED:int = 5;

		public function Seekbar(value:Number=0, w:Number=100,h:Number=20, borderV:Number = 20, borderH:Number = 20)
		{
			super();
			this.value=value;
			this.w = w;
			this.h = h;
			this.borderV = borderV;
			this.borderH = borderH;
			this.mouseChildren = false;
			
			base = new Sprite();
			base.graphics.beginFill(0x000000);
			base.graphics.drawRect(0,0,w,h+(borderV*2));
			base.graphics.endFill();
			addChild(base);
			
			timeBar = new Sprite();
			timeBar.graphics.beginFill(0x222222);
			timeBar.graphics.drawRect(0,0,w-(borderH*2),h);
			timeBar.graphics.endFill();
			timeBar.x=borderH+1;
			timeBar.y=borderV+1;
			addChild(timeBar);
			
			
			loadBar = new Sprite();
			loadBar.graphics.beginFill(0x444444);
			loadBar.graphics.drawRect(0,0,w-(borderH*2),h);
			loadBar.graphics.endFill();
			loadBar.x=borderH+1;
			loadBar.y=borderV+1;
			addChild(loadBar);
			
			cursor = new Sprite();
			cursor.graphics.beginFill(0xffffff);
			cursor.graphics.drawRect(-3,1,6,8);
			cursor.graphics.endFill();
			cursor.x=borderH+1;
			cursor.y=borderV+1;
			addChild(cursor);
			
			updateTicker = new Timer(333);
			updateTicker.addEventListener(TimerEvent.TIMER,onUpdateTickerTimer,false,0,true);
						
			userInteracting = false;
					
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// hookPlayer ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function hookPlayer (player:Object):void
		{
			this.player = player;
			
			updateTicker.start();
			
			//Mouse event
			this.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver,false,0,true);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// resize ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function resize (w:Number,h:Number):void
		{
			this.w=w;
			this.h=h;
			
			base.graphics.clear();
			base.graphics.beginFill(0x000000, 0.7);
			//base.graphics.drawRect(0,-borderV,w,h+borderV*2);
			base.graphics.drawRect(0,0,w,h+(borderV*2));
			base.graphics.endFill();
			
			timeBar.graphics.clear();
			timeBar.graphics.beginFill(0x222222);
			timeBar.graphics.drawRect(0,0,w-(borderH*2),h);
			timeBar.graphics.endFill();
			
			loadBar.graphics.clear();
			loadBar.graphics.beginFill(0x444444);
			loadBar.graphics.drawRect(0,0,w-(borderH*2),h);
			loadBar.graphics.endFill();
			
			//update();
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// update ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function update ():void
		{
			var loadedPct:Number = player.getVideoBytesLoaded()/player.getVideoBytesTotal();
			loadBar.x = borderH +1+ int(timeBar.width* player.getVideoStartBytes()/(player.getVideoStartBytes()+player.getVideoBytesTotal()));
			loadBar.width = int((timeBar.width-(loadBar.x-(borderH +1)))*loadedPct);

			if(!userInteracting)cursor.x= int(timeBar.x+player.getCurrentTime()/player.getDuration()*timeBar.width);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// destroy ---------------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function destroy ():void
		{
			player = null;
			updateTicker.stop();
			this.removeEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			this.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			updateTicker.removeEventListener(TimerEvent.TIMER,onUpdateTickerTimer);
		}
		//########################################################
		// onUpdateTickerTimer -----------------------------------
		//########################################################
		private function onUpdateTickerTimer (e:TimerEvent):void
		{
			update();
		}
		//########################################################
		// onMouseOver -------------------------------------------
		//########################################################
		private function onMouseOver (e:MouseEvent=null):void
		{
			this.removeEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut,false,0,true);
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown,false,0,true);
		}
		//########################################################
		// onMouseOut --------------------------------------------
		//########################################################
		private function onMouseOut (e:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			this.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver,false,0,true);
				
		}
		//########################################################
		// onMouseDown -------------------------------------------
		//########################################################
		private function onMouseDown (e:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			this.removeEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove,false,0,true);
			stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp,false,0,true);
			// init user interaction
			initUserChange();
			dispatchUserChange();
		}
		//########################################################
		// onMouseUp ---------------------------------------------
		//########################################################
		private function onMouseUp (e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			this.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver,false,0,true);
			// end the user interaction
			endUserChange();
			// If the mouse is already over, the MOUSE_OVER will not be dispatched,
			// so we need to call it manually;
			if(e.localX>0&&e.localX<this.width&&e.localY>0&&e.localY<this.height)onMouseOver();
		}
		//########################################################
		// onMouseMove -------------------------------------------
		//########################################################
		private function onMouseMove (e:MouseEvent):void
		{
			dispatchUserChange();
		}
		//========================================================
		// initUserChange ------------------------------------
		//========================================================
		private function initUserChange ():void
		{
			userInteracting=true;
			stateBeforeInteraction = player.getPlayerState();
			/*switch(stateBeforeInteraction)
			{
				case STATE_PLAYING:
					player.pauseVideo();
					break;
			}*/
		}
		//========================================================
		// dispatchUserChange ------------------------------------
		//========================================================
		private var tempMouseX:Number;
		private function dispatchUserChange ():void
		{
			tempMouseX = timeBar.mouseX;
			//if(tempMouseX>loadBar.width)tempMouseX=loadBar.width;
			value=tempMouseX/timeBar.width;
			if(value>1)value=1;
			else if(value<0)value=0;
			cursor.x=int(timeBar.x+value*timeBar.width);
			
			// as the user is still pressing the mouse, we pass false to "allowSeekAhead"
			player.seekTo(value*player.getDuration(), false);			
		}
		//========================================================
		// endUserChange -----------------------------------------
		//========================================================
		private function endUserChange():void
		{
			userInteracting=false;
			// now that the user has released the mouse, we pass true to "allowSeekAhead"
			player.seekTo(value*player.getDuration(), true);
			/*switch(stateBeforeInteraction)
			{
				case STATE_PLAYING:
					player.playVideo();
					break;
			}
			*/
		}
	}
}