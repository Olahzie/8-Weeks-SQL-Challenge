-- Customer Journey

SELECT customer_id,
		subscriptions.plan_id,
		plan_name,
		start_date
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
WHERE customer_id IN (1,2,11,13,15,16,18,19);

-- Customer onboarding journey for customer_id 1

SELECT customer_id,
		subscriptions.plan_id,
		plan_name,
		start_date
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
WHERE customer_id = 1;

-- Customer onboarding journey for customer_id 11

SELECT customer_id,
		subscriptions.plan_id,
		plan_name,
		start_date
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
WHERE customer_id = 11;

-- Customer onboarding journey for customer_id 18

SELECT customer_id,
		subscriptions.plan_id,
		plan_name,
		start_date
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
WHERE customer_id = 18;

-- Customer onboarding journey for customer_id 19

SELECT customer_id,
		subscriptions.plan_id,
		plan_name,
		start_date
FROM foodie_fi.subscriptions
INNER JOIN foodie_fi.plans
ON subscriptions.plan_id = plans.plan_id
WHERE customer_id = 19;