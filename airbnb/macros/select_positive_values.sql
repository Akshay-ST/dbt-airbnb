-- dbt compile --inline '{{ select_positive_values("dim_listings_cleansed", "minimum_nights") }}'
-- compiles below sql in cli

-- dbt show --inline '{{ select_positive_values ("dim_listings_cleansed", "minimum_nights") }}'
-- show sql output (initial sample 5 rows)

{% macro select_positive_values(model, column_name) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} > 0
{% endmacro %}