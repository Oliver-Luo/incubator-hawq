SET client_min_messages TO ERROR;
DROP SCHEMA IF EXISTS madlib_install_check_gpsql_sample CASCADE;
CREATE SCHEMA madlib_install_check_gpsql_sample;
SET search_path = madlib_install_check_gpsql_sample, madlib;

SELECT
    assert(
        (chi2_gof_test(observed, expected)).p_value > 1e-5,
        'Results of weighted_sample() do not match the expected distribution.'
    )
FROM (
    SELECT
        value,
        CAST(value AS DOUBLE PRECISION) / (10 * (10 + 1))/2 AS expected,
        count(*) AS observed
    FROM (
        SELECT weighted_sample(i, i) AS value
        FROM
            generate_series(1,10) i,
            generate_series(1,10000) trial
        GROUP BY trial
    ) AS ignored
    GROUP BY value
    ORDER BY value
) AS ignored;

-- Same again for the vector version
SELECT
    assert(
        (chi2_gof_test(observed, expected)).p_value > 1e-5,
        'Results of weighted_sample() do not match the expected distribution.'
    )
FROM (
        SELECT
        value,
        value[1] / (10 * (10 + 1))/2 AS expected,
        count(*) AS observed
    FROM (
        SELECT weighted_sample(ARRAY[i,i]::DOUBLE PRECISION[], i) AS value
        FROM
            generate_series(1,10) i,
            generate_series(1,10000) trial
        GROUP BY trial
    ) AS ignored
    GROUP BY value
    ORDER BY value
) AS ignored;

DROP SCHEMA madlib_install_check_gpsql_sample CASCADE;