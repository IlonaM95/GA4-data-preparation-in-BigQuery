WITH
  user_sessions AS (
  SELECT
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,
    traffic_source.source AS SOURCE,
    traffic_source.medium AS medium,
    CONCAT ( CAST(user_pseudo_id AS string), CAST((
        SELECT
          value.int_value
        FROM
          UNNEST(event_params)
        WHERE
          KEY = 'ga_session_id' ) AS string) ) AS user_sessions_id
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_2021*`
  WHERE
    event_name IN ('session_start')),
  campaign_agg AS (
  SELECT
    CONCAT ( CAST(user_pseudo_id AS string), CAST((
        SELECT
          value.int_value
        FROM
          UNNEST(event_params)
        WHERE
          KEY = 'ga_session_id' ) AS string) ) AS user_sessions_id,
    STRING_AGG(DISTINCT params.value.string_value, ', ') AS campaign
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_2021*`,
    UNNEST(event_params) AS params
  WHERE
    event_name IN ( 'add_to_cart',
      'begin_checkout',
      'purchase')
    AND params.key = 'campaign'
  GROUP BY
    user_sessions_id),
  data_sessions AS (
  SELECT
    us.event_date,
    us.user_sessions_id,
    us.source,
    us.medium,
    COALESCE(ca.campaign, 'n/a') AS campaign
  FROM
    user_sessions us
  LEFT JOIN
    campaign_agg ca
  ON
    us.user_sessions_id = ca.user_sessions_id ),
  conversion_steps AS (
  SELECT
    CONCAT ( CAST(user_pseudo_id AS string), CAST((
        SELECT
          value.int_value
        FROM
          UNNEST(event_params)
        WHERE
          KEY = 'ga_session_id' ) AS string) ) AS user_sessions_id,
    MAX(CASE
        WHEN event_name = 'add_to_cart' THEN 1
        ELSE 0
    END
      ) AS visit_to_cart,
    MAX(CASE
        WHEN event_name = 'begin_checkout' THEN 1
        ELSE 0
    END
      ) AS visit_to_checkout,
    MAX(CASE
        WHEN event_name = 'purchase' THEN 1
        ELSE 0
    END
      ) AS visit_to_purchase
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_2021*`
  WHERE
    event_name IN ('add_to_cart',
      'begin_checkout',
      'purchase')
  GROUP BY
    user_sessions_id )
SELECT
  ds.event_date,
  ds.source,
  ds.medium,
  ds.campaign,
  COUNT(DISTINCT ds.user_sessions_id) AS user_sessions_count,
  SUM(cs.visit_to_cart) AS visit_to_cart,
  SUM(cs.visit_to_checkout) AS visit_to_checkout,
  SUM(cs.visit_to_purchase) AS visit_to_purchase
FROM
  data_sessions ds
LEFT JOIN
  conversion_steps cs
ON
  ds.user_sessions_id = cs.user_sessions_id
WHERE
  cs.visit_to_cart IS NOT NULL
  AND cs.visit_to_checkout IS NOT NULL
  AND cs.visit_to_purchase IS NOT NULL
GROUP BY
  ds.event_date,
  ds.source,
  ds.medium,
  ds.campaign
ORDER BY
  event_date,
  visit_to_purchase DESC,
  visit_to_cart DESC,
  user_sessions_count DESC
LIMIT
  50;