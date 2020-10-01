<?php
  error_reporting(E_ALL);

  // ApiKey is required to modify basecurrency.
  $apiKey = '';

  // List of currencies we care about.
  $currencies = array(
  "AED", // United Arab Emirates Dirham
  "AUD", // Australian Dollar
  "BGN", // Bulgarian Lev
  "BRL", // Brazilian Real
  "CAD", // Canadian Dollar
  "CHF", // Swiss Franc
  "CLP", // Chilean Peso
  "CNY", // Chinese Yuan
  "COP", // Colombian Peso
  "CZK", // Czech Koruna
  "DKK", // Danish Krone
  "EGP", // Egyptian Pound
  "EUR", // Euro
  "GBP", // Pound Sterling
  "HKD", // Hong Kong Dollar
  "HRK", // Croatian Kuna
  "HUF", // Hungarian Forint
  "IDR", // Indonesian Rupiah
  "ILS", // Israeli New Shekel
  "INR", // Indian Rupee
  "JPY", // Japanese Yen
  "KRW", // Korean Won
  "KZT", // Kazakhstani Tenge
  "MXN", // Mexican Peso
  "MYR", // Malaysian Ringgit
  "NGN", // Nigerian Naira
  "NOK", // Norwegian Krone
  "NZD", // New Zealand Dollar
  "PEN", // Peruvian Sol
  "PKR", // Pakistani Rupee
  "PHP", // Philippine Peso
  "PLN", // Polish Zloty
  "QAR", // Qatari Riyal
  "RON", // Romanian Leu
  "RUB", // Russian Ruble
  "SAR", // Saudi Riyal
  "SEK", // Swedish Krona
  "SGD", // Singapore Dollar
  "THB", // Thai Baht
  "TRY", // Turkish Lira
  "TWD", // New Taiwan Dollar
  "TZS", // Tanzanian Shilling
  "USD", // United States Dollar
  "VND", // Vietnamese Dong
  "ZAR", // South African Rand
  );

  $results = array();

  foreach($currencies as $fromCurrency)
  {
    $results[$fromCurrency] = array();

    $targetURL = 'https://openexchangerates.org/api/latest.json?app_id=' . $apiKey . '&base=' . $fromCurrency;
    $jsonSrc = file_get_contents_retry($targetURL);

    $jsonObj = json_decode($jsonSrc);
    if(FALSE === $jsonObj || empty($jsonObj))
    {
      echo("Failed with: $jsonSrc.\r\n");
      print_r($jsonSrc);
      exit(1);
    } // End of failed to process

    foreach($jsonObj->rates as $currency => $rate)
    {
        $results[$fromCurrency][$currency] = (string)$rate;
    } // End of exchangeRate enumeration

  } // End of currencies loop

  // Update the results.
  $results = array(
	"lastUpdated" => date("M d Y H:i:s"),
	"exchangeRanges" => $results);

  // Save our results
  file_put_contents("ExchangeRates.json",
	json_encode($results, JSON_PRETTY_PRINT));

  // Success
  exit(0);

function file_get_contents_retry($url)
{
  for($i = 0; $i < 10; ++$i)
  {
    $html = trim(@file_get_contents($url));

    if(sizeof($html) > 0 && !empty($html))
    {
      return $html;
    }

    // Short delay before trying again
    sleep(1);
  }

  echo("Failed to get HTML for url: $url\r\n\r\n");
  exit(1);
}

?>
