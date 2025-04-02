public class currencytowords
{
     public String[] units = new String[]{'ZERO ','ONE ','TWO ','THREE ','FOUR ','FIVE ','SIX ','SEVEN ','EIGHT ','NINE ','TEN ',

      'ELEVEN ','TWELVE ','THIRTEEN ','FOURTEEN ','FIFTEEN ',

      'SIXTEEN ','SEVENTEEN ','EIGHTEEN ','NINETEEN '};

     public String[] tens = new String[]{'','','TWENTY','THIRTY','FOURTY','FIFTY','SIXTY','SEVENTY','EIGHTY','NINETY'};
  
      

   
    public  String convert(long i) 
    {

      if( i < 20)  return units[integer.valueOf(i)];

      if( i < 100) return tens[integer.valueOf(i)/10] + ((math.mod(i , 10) > 0)? '' + convert(math.mod(i , 10)):'');

      if( i < 1000) return units[integer.valueOf(i)/100] + ' HUNDRED' + ((math.mod(i , 100) > 0)?' ' + convert(math.mod(i , 100)):'');

      if( i < 10000) return units[integer.valueOf(i)/1000] + ' THOUSAND' + ((math.mod(i , 1000) > 0)?' ' + convert(math.mod(i , 1000)):'');

      if( i < 100000) return convert(i / 1000) + ' THOUSAND' + ((math.mod(i , 1000) > 0)? ' ' + convert(math.mod(i ,1000)):'') ;

      if( i < 1000000) return units[integer.valueOf(i)/100000] + ' LAKH' + ((math.mod(i , 100000) > 0)? ' ' + convert(math.mod(i ,100000)):'') ;

      if( i < 10000000) return convert(i / 100000) + ' LAKH' + ((math.mod(i , 100000) > 0)? ' ' + convert(math.mod(i ,100000)):'') ;

      if(i < 100000000) return units[integer.valueOf(i)/10000000] + ' CRORE' + ((math.mod(i , 10000000) > 0)? '' + convert(math.mod(i , 10000000)):'') ;

      if(i < 1000000000) return convert(i / 10000000) + 'CRORE' + ((math.mod(i , 10000000) > 0)? ' ' + convert(math.mod(i , 10000000)):'') ;
  
      
      return convert(i / 1000000000) + ' CRORE' + ((math.mod(i , 1000000000) > 0) ? '' + convert(math.mod(i , 1000000000)):'')+' only';

    }

 }