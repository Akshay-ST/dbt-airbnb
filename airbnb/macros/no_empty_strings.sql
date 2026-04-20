{# Here is my solution after removing most of the white spaces #}

{% macro no_empty_strings(model) %}
    {%- for col in adapter.get_columns_in_relation(model) -%}
        {%- if col.is_string() %}
            {{ col.name }} IS NOT NULL AND {{ col.name }} <> '' AND
        {%- endif %}
    {%- endfor %}
    TRUE
{% endmacro %}


-- dbt compile --inline '{{ no_empty_strings(ref("dim_listings_cleansed")) }}'
/*
originally without whitespaces removed
Compiled inline node is:

    
        
    
        
            LISTING_NAME IS NOT NULL AND LISTING_NAME <> '' AND
        
    
        
            ROOM_TYPE IS NOT NULL AND ROOM_TYPE <> '' AND
        
    
        
    
        
    
        
    
        
    
        
    
    TRUE

*/

-- dbt compile --inline 'SELECT * {{ ref("dim_listings_cleansed") }} WHERE {{ no_empty_strings(ref("dim_listings_cleansed")) }}'
/*
Compiled inline node is:
SELECT * AIRBNB.DEV.dim_listings_cleansed WHERE 
    
        
    
        
            LISTING_NAME IS NOT NULL AND LISTING_NAME <> '' AND
        
    
        
            ROOM_TYPE IS NOT NULL AND ROOM_TYPE <> '' AND
        
    
        
    
        
    
        
    
        
    
        
    
    TRUE

*/