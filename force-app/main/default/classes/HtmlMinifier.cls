/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 09-08-2024
 * @last modified by  : @BK
**/
public class HtmlMinifier {
    // Method to minify HTML content
    public static String minifyHtml(String htmlContent) {
        if (String.isEmpty(htmlContent)) {
            return htmlContent;
        }
        
        // Remove HTML comments
        String minifiedHtml = htmlContent.replaceAll('<!--.*?-->', '');

        // Remove unnecessary whitespace and newlines
        minifiedHtml = minifiedHtml.replaceAll('\\s+', ' ');
        
        // Remove spaces before and after the start and end tags
        minifiedHtml = minifiedHtml.replaceAll('>(\\s+)([^<]*?)(\\s+)<', '>$2<');

        // Remove spacesin between tags
        minifiedHtml = minifiedHtml.replaceAll('>\\s+<', '><');
        
        // Remove spaces before self-closing tags
        minifiedHtml = minifiedHtml.replaceAll('\\s+/>', '/>');
        
        // Remove leading and trailing spaces
        minifiedHtml = minifiedHtml.trim();
        
        return minifiedHtml;
    }
}