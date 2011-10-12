package tinbob.display
{
	import flash.display.Shape;
	import flash.events.MouseEvent;

	public class ShapeButton extends BaseButton
	{
		public var shape:Shape;
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function ShapeButton(w:Number=60, h:Number=60)
		{
			super(w, h);
			this.graphics.beginFill(0x000000,0.7);
			this.graphics.drawRect(-w*0.5,-h*0.5,w,h);
			this.graphics.endFill();
			shape = new Shape();
			addChild(shape);
			drawShape(0xdddddd);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// drawShape ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function drawShape(color:uint):void
		{
			
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onRollOver ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		override public function onRollOver(e:MouseEvent):void
		{
			super.onRollOver(e);	
			drawShape(0xffffff);
		}
		/////////////////////////////////////////////////////////////////////////////////////
		// onRollOut ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		override public function onRollOut(e:MouseEvent):void
		{
			super.onRollOut(e);	
			drawShape(0xbbbbbb);
		}
	}
}