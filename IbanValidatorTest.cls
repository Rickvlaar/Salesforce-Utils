/*******************************************************************************************
 * Name            : IbanValidatorTest
 * Created By      : RickForce
 * Created Date    : 28/08/2019
 * Description     : Test class for IbanValidator
 ********************************************************************************************/
@isTest
public class IbanValidatorTest {

	@isTest
	public static void correctIbanTest() {
		Map<Boolean, String> testResultMap = new Map<Boolean, String>();
		List<String> testValidIbanList = new List<String> {
			'MU17BOMM0101101030300200000MUR',   //Mauritius
			'NL91ABNA0417164300',               //Netherlands
			'IL620108000000099999999',          //Israel
			'BE68539007547034',                 //Belgium
			'FR1420041010050500013M02606',      //France
			'DE89370400440532013000'            //Germany
		};

		Test.startTest();
		for (String testIban : testValidIbanList) {
			System.debug(testIban + ' result =  ' + GGIbanValidator.isValid(testIban));
			testResultMap.putAll(GGIbanValidator.isValid(testIban));
		}
		Test.stopTest();
		System.assert (!testResultMap.containsKey(false), 'There should be no invalid Iban results');
	}

    @isTest
	public static void invalidChecksum() {
		Map<Boolean, String> testResultMap = new Map<Boolean, String>();
		List<String> testValidIbanList = new List<String> {
			'MU17BOMM0101101030300200004MUR',   //Mauritius
			'NL91ABNA0417164304',               //Netherlands
			'IL620108000000099999990',          //Israel
			'BE68539007547035',                 //Belgium
			'FR1420041010050500013M02607',      //France
			'DE89370400440532013003'            //Germany
		};

		Test.startTest();
		for (String testIban : testValidIbanList) {
			System.debug(testIban + ' result =  ' + GGIbanValidator.isValid(testIban));
			testResultMap.putAll(GGIbanValidator.isValid(testIban));
		}
		Test.stopTest();
		System.assert (!testResultMap.containsKey(true), 'There should be no valid Iban results');
	}

	@isTest
	public static void invalidCountryCodeTest(){
		Map<Boolean, String> testResultMap = new Map<Boolean, String>();

		Test.startTest();
		testResultMap.putAll(GGIbanValidator.isValid('US64SVBKUS6S3300958879'));
		Test.stopTest();
		System.assert (testResultMap.containsKey(false), 'US is not a valid IBAN country');
	}

    @isTest
	public static void invalidIbanLengthTest(){
		Map<Boolean, String> testResultMap = new Map<Boolean, String>();

		Test.startTest();
		testResultMap.putAll(GGIbanValidator.isValid('NL91ABNA04171643003'));
		Test.stopTest();
		System.assert (testResultMap.containsKey(false), 'This IBAN is 1 character too long for NL IBAN');
	}

}
