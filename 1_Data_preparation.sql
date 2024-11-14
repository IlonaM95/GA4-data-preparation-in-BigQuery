SELECT
  TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,
  user_pseudo_id,
  (
  SELECT
    value.int_value
  FROM
    UNNEST(event_params)
  WHERE
    KEY = 'ga_session_id') AS session_id,
  event_name,
  geo.country,
  device.category AS device_category,
  traffic_source.source,
  traffic_source.medium,
  (
  SELECT
    value.string_value
  FROM
    UNNEST(event_params)
  WHERE
    KEY = 'campaign') AS campaign_name
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_2021*`
WHERE
  event_name IN ('session_start',
    'view_item',
    'add_to_cart',
    'begin_checkout',
    'add_shipping_info',
    'add_payment_info',
    'purchase')
LIMIT
  50;