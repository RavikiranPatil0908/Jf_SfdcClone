@isTest
public class currencytowordstracker
{
public static long i;
public static string word;

static testMethod void test1()
{

i=76689;
currencytowords ob = new currencytowords();
word = ob.convert(i);

}
static testMethod void test2()
{
currencytowords ob = new currencytowords();
i=99999999;
word = ob.convert(i);

}
static testMethod void test3()
{
currencytowords ob = new currencytowords();
i=9999999;
word = ob.convert(i);

}
static testMethod void test4()
{
currencytowords ob = new currencytowords();
i=99999;
word = ob.convert(i);

}

static testMethod void test5()
{
currencytowords ob = new currencytowords();
i = 999999999;
word = ob.convert(i);
}

}