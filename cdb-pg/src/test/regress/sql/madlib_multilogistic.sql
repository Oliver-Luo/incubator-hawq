SET client_min_messages TO ERROR;
DROP SCHEMA IF EXISTS madlib_install_check_gpsql_multi_logistic CASCADE;
CREATE SCHEMA madlib_install_check_gpsql_multi_logistic;
SET search_path = madlib_install_check_gpsql_multi_logistic, madlib;

DROP TABLE IF EXISTS patients;
CREATE TABLE patients (
    id INTEGER NOT NULL,
    second_attack INTEGER,
    treatment INTEGER,
    trait_anxiety INTEGER
);

INSERT INTO patients(ID, second_attack, treatment, trait_anxiety) VALUES
( 1, 1, 1, 70),
( 2, 1, 1, 80),
( 3, 1, 1, 50),
( 4, 1, 0, 60),
( 5, 1, 0, 40),
( 6, 1, 0, 65),
( 7, 1, 0, 75),
( 8, 1, 0, 80),
( 9, 1, 0, 70),
(10, 1, 0, 60),
(11, 0, 1, 65),
(12, 0, 1, 50),
(13, 0, 1, 45),
(14, 0, 1, 35),
(15, 0, 1, 40),
(16, 0, 1, 50),
(17, 0, 0, 55),
(18, 0, 0, 45),
(19, 0, 0, 50),
(20, 0, 0, 60);

-- The coefficients are from the source above, the other values have been
-- computed with the IRLS optimizer in MADlib
/*
SELECT * FROM mlogregr(
    'patients', 'second_attack', 2 , 'ARRAY[1, treatment, trait_anxiety]',
    20, 'irls',  0.001
);
*/
-- This is the same test case from the logistic regression example, just called with
-- multinomial logistic regression.
-- computed with the IRLS optimizer in MADlib
SELECT assert(
    relative_error(coef, ARRAY[-6.36, -1.02, 0.119]) < 1e-2 AND
    relative_error(log_likelihood, -9.41) < 1e-2 AND
    relative_error(std_err, ARRAY[3.21, 1.17, 0.0550]) < 0.002 AND
    relative_error(z_stats, ARRAY[-1.98, -0.874, 2.17]) < 0.002 AND
    relative_error(p_values, ARRAY[0.0477, 0.382, 0.0304]) < 1e-3 AND
    relative_error(odds_ratios, ARRAY[0.00172, 0.359, 1.13]) < 0.004 AND
    relative_error(condition_no, 106329) < 1e-2,
    'Multinomial Logistic regression with IRLS optimizer (patients test): Wrong results'
) FROM mlogregr(
    'patients', 'second_attack', 2, 'ARRAY[1, treatment, trait_anxiety]',
    20, 'irls'
);

/*
 * The values given by the multinomial logistic regression were cross checked
 * with the Matlab command mnrfit, which is documented at
 * http://www.mathworks.com/help/toolbox/stats/mnrfit.html
 *
 * One important detail in the mnrfit command is that due to a difference in convention,
 * its answers for the coefficients are the negative of our coefficient.  Our
 * convention is chosen to match the convention of the binary
 * logistic regression implementation in madlib.
 *
 * For completeness, the matlab code needed to check the answers to the 'test3' example
 * is included below.  The code assumes that the data is contained in a csv file
 * and that the columns haven't changed order.  The coefficients will be in the
 * 'B' variable.
 *
 * BEGIN CODE
 *
data = csvread(csvFilename);
N = size(data, 1);			% Number of records
J = size(data, 2)-1;		% Number of covariates

% Integer encoded categories {0,1...K-1}
int_y = 1+data(:,end);		% Categories
x = data(:,1:end-1);		% Independant variables

% Pivot around the last data point
[B,dev,stats] = mnrfit(x,int_y)
 *
 * END CODE
 */

DROP TABLE IF EXISTS test3;

CREATE TABLE test3 (
    feat1 INTEGER,
    feat2 INTEGER,
    cat INTEGER
);

INSERT INTO test3(feat1, feat2, cat) VALUES
(1,35,1),
(2,33,0),
(3,39,1),
(1,37,1),
(2,31,1),
(3,36,0),
(2,36,1),
(2,31,1),
(2,41,1),
(2,37,1),
(1,44,1),
(3,33,2),
(1,31,1),
(2,44,1),
(1,35,1),
(1,44,0),
(1,46,0),
(2,46,1),
(2,46,2),
(3,49,1),
(2,39,0),
(2,44,1),
(1,47,1),
(1,44,1),
(1,37,2),
(3,38,2),
(1,49,0),
(2,44,0),
(1,41,2),
(1,50,2),
(2,44,0),
(1,39,1),
(1,40,2),
(1,46,2),
(2,41,1),
(2,39,1),
(2,33,1),
(3,59,2),
(1,41,0),
(2,47,2),
(2,31,0),
(3,42,2),
(1,55,2),
(3,40,1),
(1,44,2),
(1,54,1),
(2,46,1),
(1,54,0),
(2,42,1),
(2,49,2),
(2,41,2),
(2,41,1),
(1,44,0),
(1,57,2),
(2,52,2),
(1,49,0),
(3,41,2),
(3,57,0),
(1,62,1),
(3,33,0),
(2,54,1),
(2,40,2),
(3,52,2),
(2,57,1),
(2,49,1),
(2,46,1),
(1,57,0),
(2,49,2),
(2,52,2),
(2,53,0),
(3,54,2),
(2,57,2),
(3,41,2),
(1,52,0),
(2,57,1),
(1,54,0),
(2,52,1),
(2,52,0),
(2,44,0),
(2,46,2),
(1,49,1),
(2,54,2),
(3,52,2),
(1,44,0),
(3,49,1),
(1,46,2),
(2,54,0),
(2,39,0),
(2,59,0),
(2,45,1),
(3,52,1),
(3,54,0),
(3,44,1),
(2,50,2),
(2,62,1),
(2,59,0),
(2,52,2),
(2,52,1),
(2,46,1),
(2,41,0),
(2,52,2),
(2,52,1),
(2,55,1),
(2,41,1),
(2,49,0),
(1,59,2),
(1,54,0),
(2,54,0),
(2,59,2),
(2,55,2),
(1,62,2),
(2,54,2),
(2,54,2),
(2,54,2),
(2,59,2),
(2,57,1),
(3,61,2),
(3,52,2),
(2,59,2),
(2,62,2),
(1,60,1),
(2,59,2),
(2,65,2),
(3,61,2),
(2,59,2),
(3,59,2),
(2,59,2),
(2,59,2),
(2,65,2),
(3,57,2),
(2,59,2),
(3,49,2),
(1,49,0),
(3,59,2),
(2,62,2),
(3,59,0),
(2,54,2),
(3,63,2),
(1,43,2),
(3,54,2),
(3,52,2),
(1,57,2),
(2,57,0),
(2,57,0),
(2,61,2),
(2,62,0),
(2,62,0),
(1,65,0),
(2,57,2),
(3,59,2),
(2,59,2),
(3,62,2),
(2,65,2),
(2,62,1),
(1,62,0),
(2,62,2),
(3,54,2),
(3,62,2),
(1,65,2),
(3,62,2),
(3,67,0),
(3,65,0),
(1,60,2),
(3,59,2),
(2,59,2),
(2,59,1),
(3,65,0),
(3,62,2),
(3,65,2),
(3,59,0),
(1,59,0),
(3,61,2),
(1,65,2),
(3,67,1),
(3,65,2),
(1,65,2),
(2,67,2),
(1,65,2),
(1,62,2),
(3,52,2),
(3,63,2),
(2,59,2),
(3,65,2),
(2,59,0),
(3,67,2),
(3,67,2),
(3,60,2),
(3,67,2),
(3,62,2),
(2,54,2),
(3,65,2),
(3,62,2),
(2,59,2),
(3,60,2),
(3,63,2),
(3,65,2),
(2,63,1),
(2,67,2),
(2,65,2),
(2,62,2);


SELECT assert(
	relative_error(coef, ARRAY[-3.579, -5.99, 0.636, 0.451, 0.0581, 0.112]) < 1e-2 AND
	relative_error(log_likelihood, -182.22) < 1e-2 AND
	relative_error(std_err, ARRAY[1.219, 1.209, 0.266, 0.273, 0.0214, 0.0216]) < 0.02 AND
	relative_error(z_stats, ARRAY[-2.935, -4.953, 2.3912, 1.653, 2.710, 5.171]) < 0.02 AND
	relative_error(p_values, ARRAY[0.003326, 7.3019e-07, 0.0167, 0.0982, 0.006726, 2.3177e-07]) < 1e-2 AND
	relative_error(odds_ratios, ARRAY[0.02789, 0.002503, 1.8902, 1.5701, 1.0599, 1.119]) < 0.004 AND
	relative_error(condition_no, 256089) < 1e-2,
	'Multinomial Logistic regression with IRLS optimizer (test): Wrong results'
) FROM mlogregr(
    'test3', 'cat', 3 , 'ARRAY[1, feat1, feat2]',
    20, 'irls',  0.001
);

DROP SCHEMA madlib_install_check_gpsql_multi_logistic CASCADE;