create or replace view dev_dma.tv_asd_top_users_report as (
explain
with 
item_monthly as (
    select 
        item_id,
        date_trunc('month', event_date) as event_month,
        user_id,
        ext_user_id,
        last_day(event_date) as item_last_day_in_month,
        sum(pv_all) as pv_all,
        sum(contacts_all) as contacts_all, 
        sum(favorite_add_all) as favorite_add_all, 
        sum(pv_bivrost) as pv_bivrost, 
        sum(contacts_bivrost) as contacts_bivrost, 
        sum(favorites_bivrost) as favorites_bivrost,
        sum(pv_protools) as pv_protools,
        sum(contacts_protools) as contacts_protools,
        sum(case when is_in_item_day then 1 else 0 end) as days_in_item_day,
        sum(case when is_in_item_day_bivrost then 1 else 0 end) as days_in_item_day_bivrost,
        sum(vas_amount) as vas_amount,
        sum(vas_amount_net) as vas_amount_net,
        sum(performance_vas_write_off) as performance_vas_write_off,
        sum(performance_vas_write_off_net) as performance_vas_write_off_net,
        sum(performance_vas_reserve) as performance_vas_reserve, 
        sum(performance_vas_reserve_net) as performance_vas_reserve_net,
        sum(performance_vas_return) as performance_vas_return,
        sum(performance_vas_return_net) as performance_vas_return_net,
        sum(vas_count_reserved) as vas_count_reserved,
        sum(lf_amount) as lf_amount,
        sum(lf_amount_net) as lf_amount_net,
        sum(lf_tariff_amount) as lf_tariff_amount,
        sum(lf_tariff_amount_net) as lf_tariff_amount_net,
        sum(all_calls_count) as all_calls_count,
        sum(first_calls_count) as first_calls_count,
        sum(all_messages_count) as all_messages_count,
        sum(first_messages_count) as first_messages_count
    from dma.item_day_asd_monthly i
    join dma.current_microcategories cm on i.item_microcat_id=cm.microcat_id
    and cm.logical_category in ('Realty.Commercial', 'Realty.LongRent', 'Realty.NewDevelopments', 'Realty.SecondarySell', 'Realty.ShortRent', 'Realty.Suburban',
                            'Jobs.Vacancies',
                            'Transport.Moto', 'Transport.NewCars', 'Transport.Trucks', 'Transport.UsedCars', 'Transport.Water'
                            )
    where date_trunc('month',event_date)>=getdate()-intervalym '6 months'
    group by 1,2,3,4,5
    )
,messenger_chats as (
    select 
        item_id,
        date_trunc('month',min_event_date) as chat_start_month,
        count(chat_id) as chats_count,
        count(case when with_reply then chat_id else null end) as chats_with_reply,
        sum(case when reply_time is not null then datediff('minute', min_event_date_time, reply_time) else 0 end) as sum_reply_time_minutes
    from DMA.messenger_chat_report
    where not is_spam
    and not is_blocked
    and not is_bad_cookie
    and date_trunc('month',min_event_date)>=getdate()-intervalym '6 months'
    group by 1,2
    )
,prices as (
    SELECT item_id, event_month, price
    FROM    
        (select Item_id,Price, date_trunc('month',actual_date) event_month, row_number() OVER(Partition by Item_id, date_trunc('month',actual_date) order by actual_date desc) as rnk 
        from DDS.S_Item_Price) t 
    WHERE rnk = 1 and Price>0
    )
,price_changes as (
    select  Item_id, event_month, sum(price_change) as price_changes_count, sum(price_change_amount) as price_changes_amount
    from (select Item_id, date_trunc('month',event_date) as event_month
            ,case when abs(Price-LAG(Price) over(partition by Item_id order by event_date))>0 then 1 else 0 end as 'price_change'
            ,case when abs(Price-LAG(Price) over(partition by Item_id order by event_date))>0 then (Price-LAG(Price) over(partition by Item_id order by event_date)) else 0 end as 'price_change_amount'
        from dma.item_day_asd_daily
        where date_trunc('month',event_date)>=getdate()-intervalym '6 months')t
    group by 1,2
    )
select
    im.item_id
    ,date_trunc('month', im.event_month) as event_month
    ,im.pv_all 
    ,im.contacts_all 
    ,im.favorite_add_all 
    ,im.pv_bivrost 
    ,im.contacts_bivrost 
    ,im.favorites_bivrost 
    ,im.pv_protools
    ,im.contacts_protools
    ,im.days_in_item_day 
    ,im.days_in_item_day_bivrost 
    ,ci.External_id as ext_item_id 
    ,ci.user_id 
    ,im.ext_user_id
    ,ci.StartTime as item_start_time 
    ,ci.Close_Date as item_close_date 
    ,ci.Location_id as item_Location_id 
    ,ci.Microcat_id as item_Microcat_id 
    ,p.Price
    ,im.vas_amount 
    ,im.vas_amount_net 
    ,im.performance_vas_write_off
    ,im.performance_vas_write_off_net 
    ,im.performance_vas_reserve 
    ,im.performance_vas_reserve_net 
    ,im.performance_vas_return
    ,im.performance_vas_return_net
    ,im.vas_count_reserved 
    ,im.lf_amount 
    ,im.lf_amount_net 
    ,im.lf_tariff_amount 
    ,im.lf_tariff_amount_net 
    ,im.all_calls_count 
    ,im.first_calls_count 
    ,im.all_messages_count 
    ,im.first_messages_count 
    ,case   when close_date is null 
                then datediff('day',starttime, getdate()-1)
            when close_date is not null and starttime is not null 
                then datediff('day',starttime, close_date)
            else null end as item_lifetime_total
    ,coalesce(chats_count,0) as chats_count
    ,coalesce(chats_with_reply,0) as chats_with_reply
    ,coalesce(sum_reply_time_minutes,0) as sum_reply_time_minutes
    ,cl.Region
    ,cl.RegionGeo
    ,cl.City
    ,cl.CityGeo
    ,cl.LocationGroupName
    ,cm.vertical
    ,cm.category_name
    ,cm.subcategory_name
    ,cm.logical_category
    ,cm.Param1
    ,cm.Param2
    ,cm.Param3
    ,year_of_car.value as year_of_car
    ,ipg.CoordinatesLongitude
    ,ipg.CoordinatesLatitude
    ,ip.NazvanieObektaNedvizhimosti
    ,ip.ObshchayaPloshchad
    ,ip.MestoOsmotra
    ,opyt_raboty.value as opyt_raboty
    ,vin
    ,civc.vin_canonical 
    ,condition.value as condition
    ,nvl(usm.user_segment, ls.segment) user_segment
    ,(case when nvl(usm.user_segment, ls.segment) ilike 'Private.%' then 'private'
           when nvl(usm.user_segment, ls.segment) not ilike 'Private.%' then 'pro' end) as user_is_private_or_pro 
    ,(case when acd.user_is_asd_recognised is true then true else false end) as user_is_asd 
    ,acd.user_personal_manager
    ,acd.personal_manager_team
    ,pc.price_changes_count
    ,pc.price_changes_amount
from item_monthly im
left join dma.current_item ci on ci.Item_id=im.item_id
left join dma.current_locations cl on ci.Location_id=cl.Location_id
left join (select item_id, NazvanieObektaNedvizhimosti, ObshchayaPloshchad, MestoOsmotra, GodVypuska_id, OpytRaboty_id, coalesce(vin, vinilinomerkuzova) as vin, Condition_id from dma.item_parameters) ip on im.item_id=ip.item_id
left join DMA.item_parameters_generic ipg on im.item_id=ipg.item_id
left join dma.current_parameter_values year_of_car on year_of_car.external_id=ip.GodVypuska_id 
left join dma.current_parameter_values opyt_raboty on opyt_raboty.External_ID=ip.OpytRaboty_id
left join dma.current_parameter_values condition on condition.External_ID=ip.Condition_id
left join dma.current_microcategories cm on ci.Microcat_id=cm.Microcat_id
left join messenger_chats mc on im.item_id=mc.item_id and im.event_month=mc.chat_start_month
left join price_changes pc on im.item_id=pc.item_id and pc.event_month=im.event_month 
left join dma.am_client_day acd on im.user_id=acd.user_id and acd.event_date=im.item_last_day_in_month
left join prices p on im.item_id=p.item_id and im.event_month interpolate previous value p.event_month
left join dma.user_segment_market usm 
    on usm.user_id=im.user_id 
    and cm.logical_category_id=usm.logical_category_id
    and im.item_last_day_in_month interpolate previous value usm.converting_date
left join dict.segmentation_ranks ls on cm.logical_category_id = ls.logical_category_id and ls.is_default
left join dma.current_item_vin_canonical civc on civc.item_id = im.item_id
where 
    (cm.vertical='Jobs'
    or
    (cm.vertical='Realty' and ((user_segment not ilike 'Private.%' and user_segment is not null) or acd.user_is_asd_recognised)) 
    or
    (cm.vertical='Transport' and ((user_segment not ilike 'Private.%' and user_segment is not null) or acd.user_is_asd_recognised))
    ) 
    );