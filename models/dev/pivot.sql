select
  order_id,
  {{ dbt_utils.pivot(
      'status',
      dbt_utils.get_column_values(ref('stg_stripe__payments'), 'status')
  ) }}
from {{ ref('stg_stripe__payments') }}
group by order_id