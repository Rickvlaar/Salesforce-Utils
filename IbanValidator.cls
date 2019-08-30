/*******************************************************************************************
 * Name            : IbanValidator
 * Created By      : RickForce
 * Created Date    : 28/08/2019
 * Description     : Class used to check IBAN numbers for validity
 * Test Class      : IbanValidatorTest
 ********************************************************************************************/

// 1. Check that the total IBAN length is correct as per the country. If not, the IBAN is invalid
// 2. Move the four initial characters to the end of the string
// 3. Replace each letter in the string with two digits, thereby expanding the string, where A = 10, B = 11, ..., Z = 35
// 4. Interpret the string as a decimal integer and compute the remainder of that number on division by 97

public class IbanValidator {
	private static String iban;
	private static String errorMessage;
	private static String convertedIban;
	private static Boolean invalid = false;

	//Map values for country code length
	private static Map<String, Integer> maxIbanLengthMap = new Map<String, Integer> {
		'AD' => 24, 'AE' => 23, 'AL' => 28, 'AT' => 20, 'BA' => 20, 'BE' => 16, 'BG' => 22, 'CH' => 21, 'CY' => 28, 'CZ' => 24, 'DE' => 22, 'DK' => 18, 'EE' => 20, 'ES' => 24, 'FI' => 18, 'FO' => 18, 'FR' => 27, 'GB' => 22, 'GE' => 22, 'GI' => 23, 'GL' => 18, 'GR' => 27, 'HR' => 21, 'HU' => 28, 'IE' => 22, 'IL' => 23, 'IS' => 26, 'IT' => 27, 'JO' => 27, 'LB' => 28, 'LI' => 21, 'LT' => 20, 'LU' => 20, 'LV' => 21, 'MC' => 27, 'ME' => 22, 'MK' => 19, 'MT' => 31, 'MU' => 30, 'NL' => 18, 'NO' => 15, 'PL' => 28, 'PT' => 25, 'RO' => 24, 'RS' => 22, 'SA' => 24, 'SE' => 24, 'SI' => 19, 'SK' => 24, 'SM' => 27, 'TN' => 24, 'TR' => 26
	};

	//Map values for integer representations of string
	private static Map<String, String> letterToNumberMap = new Map<String, String> {
		'A' => '10', 'B' => '11', 'C' => '12', 'D' => '13', 'E' => '14', 'F' => '15', 'G' => '16', 'H' => '17', 'I' => '18', 'J' => '19', 'K' => '20', 'L' => '21', 'M' => '22', 'N' => '23', 'O' => '24', 'P' => '25', 'Q' => '26', 'R' => '27', 'S' => '28', 'T' => '29', 'U' => '30', 'V' => '31', 'W' => '32', 'X' => '33', 'Y' => '34', 'Z' => '35'
	};

	private static Boolean hasValidLength(){
		Integer ibanLength = iban.length();
		if (ibanLength >= 2) {
			String countryCode = iban.substring(0, 2);
			Integer maxLength  = maxIbanLengthMap.get(countryCode);
			if (maxLength != null) {
				if (ibanLength == maxLength) {
					return true;
				}
				else {
					errorMessage = 'Invalid IBAN length';
					return invalid;
				}
			}
			else {
				errorMessage = 'Unknown or missing country code';
				return invalid;
			}
		}
        else {
            errorMessage = 'IBAN number too short';
			return invalid;
        }
	}

	private static void rebuildIbanForModCheck(){
		String firstFourChars = iban.substring(0, 4);
		String restOfIban  = iban.substring(4);
		String toConvert = restOfIban + firstFourChars;
		//start conversion
		convertedIban = '';
		Integer i = 0;
		String currentChar;
		while (i < toConvert.length()) {
			currentChar = toConvert.substring(i, (i + 1));
			if (currentChar.isAlpha()) {
				currentChar = letterToNumberMap.get(currentChar);
			}
			convertedIban += currentChar;
			i++;
		}
	}

	// Starting from the leftmost digit of D, construct a number using the first 9 digits and call it N.[Note 3]
	// Calculate N mod 97.
	// Construct a new 9-digit N by concahtenating above result (step 2) with the next 7 digits of D.
	// If there are fewer than 7 digits remaining in D but at least one, then construct a new N, which will have less than 9 digits, from the above result (step 2) followed by the remaining digits of D
	// Repeat steps 2–3 until all the digits of D have been processed

	private static Boolean doModCheck(){
		//Start calculation
		Boolean moreDigitsLeft = true;
		Long mod97 = 97;
		Integer currentPosition = 9;
		String substringToMod = convertedIban.substring(0, 9);
		String result = String.valueOf(math.mod(Long.valueOf(substringToMod), mod97));

		//loop through the rest of iban
		while(moreDigitsLeft) {
			if (convertedIban.substring(currentPosition).length() >= 7 ) {
				substringToMod = result + convertedIban.substring(currentPosition, currentPosition + 7);
				result = String.valueOf(math.mod(Long.valueOf(substringToMod), mod97));
				currentPosition += 7; //increase current position marker
			}
			else {
				moreDigitsLeft = false;
			}
		}
		substringToMod = result + convertedIban.substring(currentPosition);
		result = String.valueOf(math.mod(Long.valueOf(substringToMod), mod97)); //calculate the final result
		if (result == '1') {
			return true;
		}
		errorMessage = 'This IBAN is invalid, please check again';
		return invalid;
	}

	/*  Ibanvalidator.isValid method is used to check IBAN for validity
	 *  @parameter - IbanToCheck: String
	 *  @returns - both the validity as Boolean and an error message if the iban is invalid: Map<Boolean,String>
	 */
	public static Map<Boolean, String> isValid(String ibanToCheck) {
		Map<Boolean, String> returnMap =  new Map<Boolean, String>();
		iban = ibanToCheck.normalizeSpace(); //Remove any spaces that might be present
		if (hasValidLength()) {
			rebuildIbanForModCheck();
			if (doModCheck()) {
				returnMap.put(true, null);
				return returnMap;
			}
		}
		returnMap.put(invalid, errorMessage);
		return returnMap;
	}
}

