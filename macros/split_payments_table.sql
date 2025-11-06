{% macro split_payments(args) %}
    {{ log('Start setting fail_payments_query...', info=true) }}
    {% set fail_payments_query %}
        create table raw.stripe.payment_fail as
        select *
        from {{ source('stripe', 'payment') }}
        where status = 'fail';
    {% endset %}
    {{ log('Success setting fail_payments_query', info=true) }}

    {{ log('Start setting success_payments_query...', info=true) }}
    {% set success_payments_query %}
        create table raw.stripe.payment_success as
        select *
        from {{ source('stripe', 'payment') }}
        where status = 'success';
    {% endset %}
    {{ log('Success setting success_payments_query', info=true) }}

    {{ log('Start running fail_payments_query...', info=true) }}
    {% do run_query(fail_payments_query) %}
    {{ log('Success running fail_payments_query', info=true) }}
    {{ log('Start running success_payments_query...', info=true) }}
    {% do run_query(success_payments_query) %}
    {{ log('Success running success_payments_query', info=true) }}
{% endmacro %}