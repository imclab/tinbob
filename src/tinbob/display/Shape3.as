package tinbob.display
{
	import flash.display.Sprite;
	
	import tinbob.display.ExternalGraphics;

	public class Shape3 extends Sprite
	{
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function Shape3()
		{
			var shape:Sprite = new ExternalGraphics.SHAPE_3() as Sprite;
			addChild(shape);
		}
		
	}
}