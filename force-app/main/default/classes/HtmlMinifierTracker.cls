/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 09-08-2024
 * @last modified by  : @BK
**/
@isTest
public class HtmlMinifierTracker {
    
    @isTest
    static void testMinifyHtml() {
        // Test case 1: Basic HTML content with comments and extra spaces
        String htmlInput1 = '<html>  <!-- This is a comment -->  <body>  <h1>  Heading  </h1>  <p>  Paragraph Test  </p>  </body>  </html>';
        String expectedOutput1 = '<html><body><h1>Heading</h1><p>Paragraph Test</p></body></html>';
        String actualOutput1 = HtmlMinifier.minifyHtml(htmlInput1);
        System.assertEquals(expectedOutput1, actualOutput1, 'The minified HTML output did not match the expected result.');

        // Test case 2: HTML with self-closing tags and unnecessary spaces
        String htmlInput2 = '<html>  <img src="image.jpg"  />  <input type="text"  />  </html>';
        String expectedOutput2 = '<html><img src="image.jpg"/><input type="text"/></html>';
        String actualOutput2 = HtmlMinifier.minifyHtml(htmlInput2);
        System.assertEquals(expectedOutput2, actualOutput2, 'The minified HTML output did not match the expected result.');

        // Test case 3: Empty HTML content
        String htmlInput3 = '';
        String expectedOutput3 = '';
        String actualOutput3 = HtmlMinifier.minifyHtml(htmlInput3);
        System.assertEquals(expectedOutput3, actualOutput3, 'The minified HTML output did not match the expected result for empty input.');

        // Test case 4: HTML with no extra spaces or comments
        String htmlInput4 = '<html><body><h1>Heading</h1><p>Paragraph</p></body></html>';
        String expectedOutput4 = '<html><body><h1>Heading</h1><p>Paragraph</p></body></html>';
        String actualOutput4 = HtmlMinifier.minifyHtml(htmlInput4);
        System.assertEquals(expectedOutput4, actualOutput4, 'The minified HTML output did not match the expected result for input with no extra spaces.');

        // Test case 5: HTML with multiple spaces between tags
        String htmlInput5 = '<html>    <body>    <h1>Heading</h1>    <p>Paragraph</p>    </body>    </html>';
        String expectedOutput5 = '<html><body><h1>Heading</h1><p>Paragraph</p></body></html>';
        String actualOutput5 = HtmlMinifier.minifyHtml(htmlInput5);
        System.assertEquals(expectedOutput5, actualOutput5, 'The minified HTML output did not match the expected result for input with multiple spaces.');

        // Test case 6: HTML with leading and trailing spaces
        String htmlInput6 = '   <html> <body> <h1> Heading </h1> <p> Paragraph </p> </body> </html>   ';
        String expectedOutput6 = '<html><body><h1>Heading</h1><p>Paragraph</p></body></html>';
        String actualOutput6 = HtmlMinifier.minifyHtml(htmlInput6);
        System.assertEquals(expectedOutput6, actualOutput6, 'The minified HTML output did not match the expected result for input with leading and trailing spaces.');
    }
}