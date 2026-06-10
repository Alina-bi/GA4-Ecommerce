select *
from {{ ref('int_sessions') }}
where session_revenue < 0