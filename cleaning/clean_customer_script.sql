WITH cleaned_customers AS(
	
	SELECT
		-- PK stays as is
		customer_id,

		-- removing white spaces from full_name
		TRIM(full_name) AS full_name,

		-- casting age as INT
		TRY_CAST(age AS INT) AS age,

		-- standardizing the gender column
		CASE 
			WHEN TRIM(gender) = 'Prefer not to say' THEN NULL
			ELSE gender
		END AS gender,

		-- standardizing the email column
		CASE 
			WHEN email LIKE '%_@_%._%' THEN LOWER(TRIM(email))
			ELSE NULL
		END AS email,

		--standardizing the phone column, elimination symbols, area codes, and extensions
		RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
			SUBSTRING(phone, 1, CHARINDEX('x', phone + 'x') - 1)
		, '-',''), '(', ''), ')', ''), '.', ''), '+', ''),10) AS phone,
		
		-- removing white spaces from street_address
		TRIM(street_address) AS street_address,

		-- removing white spaces from city
		TRIM(city) AS city,

		-- removing white spaces from state
		TRIM(state) AS state,

		-- validating the zip code
		CASE
			WHEN REPLACE(zip_code, '''', '') LIKE '[0-9][0-9][0-9][0-9][0-9]' THEN CAST(zip_code AS VARCHAR(10))
			ELSE NULL
		END AS zip_code,


		TRY_CAST(registration_date AS DATE) AS registration_date,

		TRIM(preferred_channel) AS preferred_channel

	FROM dbo.customers

	
)

SELECT *
INSERT INTO dbo.cleaned_customers
FROM cleaned_customers;




