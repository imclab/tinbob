package tinbob.display
{
	public class PlayButton extends ShapeButton
	{
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function PlayButton(w:Number=60, h:Number=60)
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
			shape.graphics.moveTo(-11, -14);
			shape.graphics.lineTo(13, 0);
			shape.graphics.lineTo(-11, 14);
			shape.graphics.lineTo(-11, -14);
			shape.graphics.endFill();
		}
	}
}