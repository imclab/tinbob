package tinbob.display
{
	import flash.display.Sprite;
	
	import tinbob.display.ExternalGraphics;

	public class Shape2 extends Sprite
	{
		/////////////////////////////////////////////////////////////////////////////////////
		// Constructor ----------------------------------------------------------------------
		/////////////////////////////////////////////////////////////////////////////////////
		public function Shape2()
		{

			var shape:Sprite = new ExternalGraphics.SHAPE_2() as Sprite;
			addChild(shape);
			
			//shape.rotation = Math.random()*360;
		}
		
	}
}