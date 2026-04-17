WITH src_hosts AS (
    select * from {{ ref('src_hosts') }}
)
SELECT
    host_id,
    NVL(host_name,'Anonymous') as host_name,
    is_superhost,
    created_at,
    updated_at
from src_hosts