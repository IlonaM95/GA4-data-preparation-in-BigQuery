WITH
  page_location_extract AS(
  SELECT
    (
    SELECT
      value.string_value
    FROM
      UNNEST(event_params)
    WHERE
      KEY = 'page_location') AS page_location,
    CONCAT ( CAST(user_pseudo_id AS string), CAST((
        SELECT
          value.int_value
        FROM
          UNNEST(event_params)
        WHERE
          KEY = 'ga_session_id' ) AS string) ) AS user_sessions_id
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_2020*`
  WHERE
    event_name IN ('session_start')),
  conversion_rate AS(
  SELECT
    CONCAT ( CAST(user_pseudo_id AS string), CAST((
        SELECT
          value.int_value
        FROM
          UNNEST(event_params)
        WHERE
          KEY = 'ga_session_id' ) AS string) ) AS user_sessions_id,
    COUNT(event_name = 'purchase') AS total_purchases,
    MAX(CASE
        WHEN event_name = 'purchase' THEN 1
        ELSE 0
    END
      ) AS visit_to_purchase
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_2020*`
  WHERE
    event_name IN ('purchase')
  GROUP BY
    user_sessions_id )
SELECT
  DISTINCT(CASE
      WHEN ple.page_location IN ('https://shop.googlemerchandisestore.com/', 'http://shop.googlemerchandisestore.com/', 'https://googlemerchandisestore.com/', 'https://www.googlemerchandisestore.com/') THEN 'homepage'
      ELSE REGEXP_EXTRACT(ple.page_location, r'^https?://[^/]+(/[^?#]+)')
  END
    ) AS page_path,
  COUNT(DISTINCT(ple.user_sessions_id)) AS unique_user_sessions,
  SUM(cr.total_purchases) AS total_purchases,
  SUM(cr.visit_to_purchase) AS visit_to_purchase,
  CASE
    WHEN COUNT(DISTINCT(ple.user_sessions_id)) = 0 THEN 0
    ELSE ROUND(SUM(cr.visit_to_purchase) / COUNT(DISTINCT(ple.user_sessions_id)) * 100, 2)
END
  AS conversion_rate_purchases
FROM
  page_location_extract ple
LEFT JOIN
  conversion_rate cr
ON
  ple.user_sessions_id = cr.user_sessions_id
GROUP BY
  page_path
ORDER BY
  visit_to_purchase DESC,
  conversion_rate_purchases DESC,
  unique_user_sessions DESC
LIMIT
  100;