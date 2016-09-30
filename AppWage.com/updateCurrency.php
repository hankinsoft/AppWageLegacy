<?php
  error_reporting(E_ALL);

  // ApiKey is required to modify basecurrency.
  $apiKey = '';

  // List of currencies we care about.
  $currencies = array(
	"AED", // United Arab Empirates: Dirham
	"AUD",
	"CAD", // Canadian: Dollars
	"CNY",
	"DKK",
	"EUR",
	"HKD",
	"INR", // India: Rupee
	"IDR", // Indonesian: Rupiah
	"ILS", // Isreal: New Shekel
	"JPY",
	"MXN",
	"NZD",
	"NOK",
	"PHP",
	"GBP",
	"SGD",
	"SEK",
	"CHF",
	"THB",
	"USD", // United States: Dollars
	"TRY", // Turkey: Lira
	"TWD", // New Taiwan Dollar
	"RUB", // Russia: Ruble
	"SAR", // Saudia Arabia: Riyal
	"ZAR", // South Africa: Rand
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
