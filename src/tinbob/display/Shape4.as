package tinbob.display
{
	import flash.display.Sprite;
	
	import tinbob.display.ExternalGraphics;

	public class Shape4 extends Sprite
	{
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function Shape4()
		{
			var shape:Sprite = new ExternalGraphics.SHAPE_4() as Sprite;
			addChild(shape);
		}
		
	}
}