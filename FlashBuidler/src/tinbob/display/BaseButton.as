package tinbob.display
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osflash.signals.Signal;
	
	public class BaseButton extends Sprite
	{
		public var click:Signal;
		public var w:Number;
		public var h:Number;
		private var hit:Shape;
		
		
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function BaseButton(w:Number = 60, h:Number = 60)
		{
			this.w = w;
			this.h = h;
			
			click = new Signal();
			
			hit = new Shape();
			hit.graphics.beginFill(0x000000, 0);
			hit.graphics.drawRect(-w*0.5,-h*0.5,w,h);
			hit.graphics.endFill();
			
			addChild(hit);
			
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			this.buttonMode = true;
			this.useHandCursor = true;
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onRollOver ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onRollOver(e:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);	
			this.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);	
			this.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);	
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onRollOut ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onRollOut(e:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);	
			this.removeEventListener(MouseEvent.CLICK, onClick);	
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);	
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onClick ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function onClick(e:MouseEvent):void
		{
			click.dispatch();
		}
	}
}