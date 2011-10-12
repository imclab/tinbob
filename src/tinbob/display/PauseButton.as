package tinbob.display
{
	public class PauseButton extends ShapeButton
	{
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function PauseButton(w:Number=60, h:Number=60)
		{
			super(w, h);
		}		
		/////////////////////////////////////////////////////////////////////////////////////
		// drawShape ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		override public function drawShape(color:uint):void
		{
			shape.graphics.clear();
			shape.graphics.beginFill(color);
			shape.graphics.drawRect(-11,-11, 8, 24);
			shape.graphics.drawRect(3,-11, 8, 24);
			shape.graphics.endFill();
		}
	}
}