package tinbob.display
{
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	import tinbob.data.NavigationInfo;
	
	public class LogoMenu extends Sprite
	{
		public var click:Signal;
		public var _navigationInfo:NavigationInfo;
		
		public var bitmap:Bitmap;
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function LogoMenu() {
			click = new Signal(NavigationInfo);
			
			bitmap = new Bitmap();
			
			_navigationInfo = new NavigationInfo();
			_navigationInfo.label = -1;
			_navigationInfo.isHome = true;
			_navigationInfo.isPost = false;
			
			//enable(false);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// enable -----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function enable(value:Boolean):void
		{
			TweenMax.killTweensOf(bitmap);
			if(value){
				//TweenMax.to(bitmap, 0.2, {tint:null});
				this.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
				this.buttonMode = true;
				this.useHandCursor = true;
			}
			else {
				//TweenMax.to(bitmap, 0.2, {tint:0xffffff});
				this.removeEventListener(MouseEvent.CLICK, onClick);
				this.buttonMode = false;
				this.useHandCursor = false;
			}
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// setBitmapData -----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function setBitmapData(bitmapData:BitmapData):void
		{
			if(!contains(bitmap)) addChild(bitmap);
			bitmap.bitmapData = bitmapData;
			
			bitmap.x = -int(bitmap.width*0.5);
			bitmap.y = -bitmap.height;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onClick -----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onClick(event:MouseEvent):void
		{
			click.dispatch(_navigationInfo);
		}
	}
}