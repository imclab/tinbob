package tinbob.display
{
	import flash.display.Sprite;
	
	import tinbob.display.ExternalGraphics;

	public class Shape5 extends Sprite
	{
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function Shape5()
		{
			var shape:Sprite = new ExternalGraphics.SHAPE_5() as Sprite;
			addChild(shape);
		}
		
	}
}