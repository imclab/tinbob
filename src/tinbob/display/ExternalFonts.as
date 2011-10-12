package tinbob.display
{
	public class ExternalFonts
	{
		//    	[Embed(source="../resources/fonts/Envy Code R.ttf", fontName="EnvyCode", fontWeight="normal", fontStyle="regular", unicodeRange="U+0041-U+005A,U+0061-U+007A,U+0030-U+0039,U+002E-U+002E,U+0020-U+002F,U+003A-U+0040,U+005B-U+0060,U+007B-U+007E,U+2018-U+201E", mimeType="application/x-font-truetype", embedAsCFF=false)]

    	[Embed(source="../resources/fonts/Envy Code R.ttf", fontName="EnvyCode", fontWeight="normal", fontStyle="regular", unicodeRange="U+0020-U+007E,U+2018,U+2019,U+201C,U+201D,U+2022,U+2013,U+20AC", mimeType="application/x-font-truetype", embedAsCFF=false)]
    	public static const EnvyCode:String;
    	public static const ENVY_CODE:String = "EnvyCode"; 
		
		[Embed(source="../resources/fonts/Envy Code R Italic.ttf", fontName="EnvyCodeItalic", fontWeight="normal", fontStyle="italic", unicodeRange="U+0020-U+007E,U+2018,U+2019,U+201C,U+201D,U+2022,U+2013,U+20AC", mimeType="application/x-font-truetype", embedAsCFF=false)]
		public static const EnvyCodeItalic:String;
		public static const ENVY_CODE_ITALIC:String = "EnvyCodeItalic"; 
		
		public static const BODY:String = "Monaco, Consolas, Courier New, _typewriter"; 
	}
}