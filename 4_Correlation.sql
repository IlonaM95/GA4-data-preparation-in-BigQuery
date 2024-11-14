WITH
  user_sessions AS (
  SELECT
    CONCAT(CAST(user_pseudo_id AS string), CAST((
        SELECT
          value.int_value
        FROM
          UNNEST(event_params)
        WHERE
          KEY = 'ga_session_id' ) AS string) ) AS user_sessions_id,
    MAX(COALESCE(CAST((
          SELECT
            value.string_value
          FROM
            UNNEST(event_params)
          WHERE
            KEY = 'session_engaged' ) AS int), 0) ) AS session_engaged,
    ROUND(SUM(COALESCE((
          SELECT
            value.int_value
          FROM
            UNNEST(event_params)
          WHERE
            KEY = 'engagement_time_msec' ),0)) / 1000 / 60, 2) AS engagement_time_min,
    MAX(CASE
        WHEN event_name = 'purchase' THEN 1
        ELSE 0
    END
      ) AS purchase
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_2021*`
  GROUP BY
    user_sessions_id ),
  table_result AS (
  SELECT
    user_sessions_id,
    engagement_time_min,
    session_engaged,
    purchase
  FROM
    user_sessions
  ORDER BY
    engagement_time_min DESC,
    purchase DESC,
    session_engaged DESC)
SELECT
  ROUND(CORR(session_engaged, purchase), 4) AS corr_engaged_purchase,-- no correlation 
  ROUND(CORR(engagement_time_min, purchase), 4) AS corr_time_purchase -- low positive correlation
FROM
  table_result
LIMIT
  1;