/* @header 
datamart: DMA.asd_user_stats_by_month_12m_bivrost
type: FULL_REFRESH
keys:
  - month
  - user_ext
params:
  - name: launch_id
scheduled:
  - first_date: $TODAY[-1]
    last_date: $TODAY[-1]
*/


create table if not exists dev_dma.asd_user_stats_by_month_12m_bivrost
(
    launch_id int not null,
    user_ext int,
    user_name varchar(256),
    shop_name varchar(1024),
    user_category varchar(256),
    user_subcategory varchar(256),
    user_region varchar(256),
    "month" date,
    item_views int,
    contacts int,
    active_items_d int,
    active_items int,
    item_views_bivrost int,
    contacts_bivrost int,
    items_started int,
    items_reactivated int,
    items_blocked int,
    lf_payment numeric(37,15),
    lf_payment_net numeric(37,15),
    vas_payment numeric(37,15),
    vas_payment_net numeric(37,15),
    subs_payment numeric(37,15),
    subs_payment_net numeric(37,15),
    extension_payment numeric(37,15),
    extension_payment_net numeric(37,15),
    Domofond_VAS_payment numeric(37,15),
    Domofond_VAS_payment_net numeric(37,15),
    shop_payment numeric(37,15),
    shop_payment_net numeric(37,15),
    context_payment numeric(37,15),
    context_payment_net numeric(37,15),
    paid_contact_payment numeric(37,15),
    paid_contact_payment_net numeric(37,15),
    autoteka_payment numeric(37,15),
    autoteka_payment_net numeric(37,15),
    subscription_burned numeric(37,15),
    subscription_burned_net numeric(37,15),
    subscription_bonuses_burned numeric(37,15),
    subscription_bonuses_burned_net numeric(37,15),
    extension_burned numeric(37,15),
    extension_burned_net numeric(37,15),
    total_payment numeric(37,15),
    total_payment_net numeric(37,15),
    wallet_pay_in numeric(37,15),
    current_segment varchar(1),
    historical_segment varchar(1),
    team_end_of_month varchar(256),
    user_personal_manager_end_of_month varchar(256),
    user_is_blocked boolean,
    user_is_shop boolean,
    shop_tariff varchar(128),
    team_mapping_end_of_month varchar(1024),
    user_balance_net numeric(37,15),
    user_balance numeric(37,15),
    actual_personal_manager_team varchar(256),
    actual_personal_manager_team_mapping varchar(1024),
    actual_user_personal_manager varchar(256),
    number_of_messages int,
    unique_message_sender_users int,
    SFAccount_id int,
    SFAccount_SalesforceID varchar(64),
    SFTopParentAccount_id int,
    calls_count int,
    is_asd int,
    protools_user varchar(128),
    unique_message_sender_users_d int,
    user_balance_net_d numeric(37,15),
    user_balance_d numeric(37,15),
    INN int,
    reply_percent numeric(20,2),
    chats_with_reply int,
    chat_count int,
    reply_percent_less_1h numeric(20,2),
    item_views_protools int, 
	contacts_protools int,
	first_messages_count int,
	replies_more_than_1h int
)
order by user_ext, "month"
segmented by hash(user_ext) all nodes
partition by launch_id;

create local temp table maxdate on commit preserve rows as /*+direct*/ (
	select max(event_date) as maxdate
	from dma.am_client_day
)
order by maxdate
unsegmented all nodes;
select analyze_statistics('maxdate');


create local temp table ui on commit preserve rows as /*+direct*/ (
	select distinct
		acd.user_id,
		acd.shop_name,
		acd.external_user_id as external_id,
		acd.user_name as name,
		acd.user_category,
		acd.user_subcategory,
		acd.user_region,
		acd.personal_manager_team,
		acd.user_personal_manager
	from dma.am_client_day acd
	where date(acd.event_date) = (select * from maxdate)
)
order by user_id
segmented by hash(user_id) all nodes;
select analyze_statistics('ui');


create local temp table messenger_messages on commit preserve rows as /*+direct*/ (
    select
        to_user_id,
        date_trunc('month',event_date)::date as message_month,
        count(message_id) as number_of_messages,
        count(distinct from_user_id) as unique_message_sender_users,
        sum(case when mm.is_first_message then 1 else 0 end) as first_messages_count
    from DMA.messenger_messages mm
    where not mm.is_spam 
    and not mm.is_blocked 
    and not mm.is_deleted
    and not mm.is_bad_cookie
    and EventType_id in (18250001,18750001,244734750001)
    and date_trunc('month',event_date) >= date_trunc('month', getdate()- intervalym '36 month')
    GROUP BY 1,2
)
order by to_user_id, message_month
segmented by hash(to_user_id) all nodes;
select analyze_statistics('messenger_messages');


create local temp table messenger_messages_d on commit preserve rows as /*+direct*/ (
    select
        to_user_id, /*user_id получателя*/
        event_date::date as message_month, /*дата отправки сообщения*/
        count(message_id) as number_of_messages, /*кол-во сообщений*/
        count(distinct from_user_id) as unique_message_sender_users, /*кол-во уникальных отправителей*/
        sum(case when mm.is_first_message then 1 else 0 end) as first_messages_count
    from DMA.messenger_messages mm
    where not mm.is_spam 
    and not mm.is_blocked 
    and not mm.is_deleted
    and not mm.is_bad_cookie
    and EventType_id in (18250001,18750001,244734750001)
    and date_trunc('month',event_date) >= date_trunc('month', getdate()- intervalym '2 month')
    GROUP BY 1,2
)
order by to_user_id, message_month
segmented by hash(to_user_id) all nodes;
select analyze_statistics('messenger_messages_d');


create local temp table User_details on commit preserve rows as /*+direct*/ (
	select distinct
		user_id,
		personal_manager_team,
		user_personal_manager,
		user_is_blocked,
		user_is_shop,
		shop_tariff,
		user_balance_net,
		user_balance,
		date_trunc('month',event_date)::date as event_date,
		atm.team_vertical_bi_mapping as 'mapping'
	from
		dma.am_client_day acd
		left join dma.asd_teams_mapping atm on atm.team_variations = acd.personal_manager_team
	where
		date(acd.event_date) = (select * from maxdate) or date(acd.event_date)=last_day(acd.event_date)
)
order by user_id, event_date
segmented by hash(user_id) all nodes;
select analyze_statistics('User_details');


create local temp table User_details_d on commit preserve rows as /*+direct*/ (
	select
		user_id,
		personal_manager_team,
		user_personal_manager,
		user_is_blocked,
		user_is_shop,
		shop_tariff,
		user_balance_net,
		user_balance,
		event_date::date
	from
		dma.am_client_day acd
	where
		date_trunc('month',acd.event_date) >= date_trunc('month',getdate() - intervalym '2 month')
)
order by user_id, event_date
segmented by hash(user_id) all nodes;
select analyze_statistics('User_details_d');


create local temp table needed_items on commit preserve rows as /*+direct*/ (
	SELECT
		i.user_id
		,i.item_id as needed_item_id
	from
		dma.current_item i
		join ui on i.user_id = ui.user_id
)
order by user_id
segmented by hash(user_id) all nodes;
select analyze_statistics('needed_items');


create local temp table pmt on commit preserve rows as /*+direct*/ (
	select
		cp.seller_id as user_id,
		CASE
			WHEN date_trunc('month', cp.event_time) < date_trunc('month',getdate()- intervalym '2 month')
			then date_trunc('month', cp.event_time)::date
			else cp.event_time::date
		END as 'event_date',
		sum( case when cp.transaction_type = 'listing.fee' and cp.is_revenue then cp.amount else 0 end ) as lf_payment,
		sum( case when cp.transaction_type = 'listing.fee' and cp.is_revenue then cp.amount_net else 0 end ) as lf_payment_net,
		sum( case when cp.transaction_type in ('VAS', 'Performance VAS write off', 'Performance VAS burned', 'VAS write off', 'VAS burned') and cp.is_revenue then cp.amount else 0 end ) as vas_payment,
		sum( case when cp.transaction_type in ('VAS', 'Performance VAS write off', 'Performance VAS burned', 'VAS write off', 'VAS burned') and cp.is_revenue then cp.amount_net else 0 end ) as vas_payment_net,
		sum( case when cp.transaction_type = 'subscription write off' and cp.is_revenue then cp.amount else 0 end ) as subs_payment,
		sum( case when cp.transaction_type = 'subscription write off' and cp.is_revenue then cp.amount_net else 0 end ) as subs_payment_net,
		sum( case when cp.transaction_type = 'extension write off' and cp.is_revenue then cp.amount else 0 end ) as extension_payment,
		sum( case when cp.transaction_type = 'extension write off' and cp.is_revenue then cp.amount_net else 0 end ) as extension_payment_net,
		sum( case when cp.transaction_type = 'Domofond VAS' and cp.is_revenue then cp.amount else 0 end ) as Domofond_VAS_payment,
		sum( case when cp.transaction_type = 'Domofond VAS' and cp.is_revenue then cp.amount_net else 0 end ) as Domofond_VAS_payment_net,
		sum( case when cp.transaction_type = 'shop write off' and cp.is_revenue then cp.amount else 0 end ) as shop_payment,
		sum( case when cp.transaction_type = 'shop write off' and cp.is_revenue then cp.amount_net else 0 end ) as shop_payment_net,
		sum( case when cp.transaction_type = 'avito.context' and cp.is_revenue then cp.amount else 0 end ) as context_payment,
		sum( case when cp.transaction_type = 'avito.context' and cp.is_revenue then cp.amount_net else 0 end ) as context_payment_net,
		sum( case when cp.transaction_type = 'paid contact' and cp.is_revenue then cp.amount else 0 end ) as paid_contact_payment,
		sum( case when cp.transaction_type = 'paid contact' and cp.is_revenue then cp.amount_net else 0 end ) as paid_contact_payment_net,
		sum( case when cp.transaction_type = 'autoteka' and cp.is_revenue then cp.amount else 0 end ) as autoteka_payment,
		sum( case when cp.transaction_type = 'autoteka' and cp.is_revenue then cp.amount_net else 0 end ) as autoteka_payment_net,
		sum( case when cp.transaction_type = 'subscription burned' and cp.is_revenue then cp.amount else 0 end ) as subscription_burned,
		sum( case when cp.transaction_type = 'subscription burned' and cp.is_revenue then cp.amount_net else 0 end ) as subscription_burned_net,
		sum( case when cp.transaction_type = 'subscription bonuses burned' and cp.is_revenue then cp.amount else 0 end ) as subscription_bonuses_burned,
		sum( case when cp.transaction_type = 'subscription bonuses burned' and cp.is_revenue then cp.amount_net else 0 end ) as subscription_bonuses_burned_net,
		sum( case when cp.transaction_type = 'extension burned' and cp.is_revenue then cp.amount else 0 end ) as extension_burned,
		sum( case when cp.transaction_type = 'extension burned' and cp.is_revenue then cp.amount_net else 0 end ) as extension_burned_net,
		sum( case when cp.is_revenue then cp.amount else 0 end ) as total_payment,
		sum( case when cp.is_revenue then cp.amount_net else 0 end ) as total_payment_net,
		sum( case when cp.transaction_type = 'wallet' and cp.transaction_subtype = 'pay in' then cp.Amount_net else 0 end) as wallet_pay_in
	from
		DMA.current_payment_events cp
	where
		1 = 1
		and date_trunc('month',cp.event_time)>= date_trunc('month', getdate()- intervalym '36 month')
	group by 1, 2
)
order by user_id, event_date
segmented by hash(user_id) all nodes;
select analyze_statistics('pmt');


create local temp table item_month_asd on commit preserve rows as /*+direct*/ (
    select 
        item_id,
		date_trunc('month', event_date)::date as 'event_month',
		sum( case when is_in_item_day then 1 else 0 end) as days_in_item_day,
		sum( pv_all ) as item_views,
		sum( contacts_all ) as contacts,
		sum( pv_bivrost ) as item_views_bivrost,
		sum( contacts_bivrost ) as contacts_bivrost,
		sum( pv_protools ) as item_views_protools, 
		sum( contacts_protools ) as contacts_protools
	from dma.item_day_asd
	group by 1,2
)
order by item_id, event_month
segmented by hash(item_id) all nodes;
select analyze_statistics('item_month_asd');


create local temp table idf on commit preserve rows as /*+direct*/ (
	select
		ni.user_id,
		ima.event_month as 'event_date',
		sum( ima.item_views ) as item_views,
		sum( ima.contacts ) as contacts,
		count(case when ima.days_in_item_day>0 then ima.item_id end) as 'active_items',
		sum( ima.item_views_bivrost ) as item_views_bivrost,
		sum( ima.contacts_bivrost ) as contacts_bivrost,
		sum( ima.item_views_protools ) as item_views_protools, 
		sum( ima.contacts_protools ) as contacts_protools
	from needed_items ni 
	join item_month_asd ima on ima.item_id = needed_item_id
	where 1=1 and
		date_trunc('month', ima.event_month) >= date_trunc('month', getdate() - intervalym '36 month')
	group by 1, 2
)
order by user_id, event_date
segmented by hash(user_id) all nodes;
select analyze_statistics('idf');


create local temp table didf on commit preserve rows as /*+direct*/ (
    select
		ni.user_id,
		ida.event_date::date as 'event_date',
		sum( ida.pv_all ) as item_views,
		sum( ida.contacts_all ) as contacts,
		count(case when ida.is_in_item_day then ida.item_id end) as 'active_items',
		sum( ida.pv_bivrost ) as item_views_bivrost,
		sum( ida.contacts_bivrost ) as contacts_bivrost,
		sum( ida.pv_protools ) as item_views_protools, 
		sum( ida.contacts_protools ) as contacts_protools
	from
		needed_items ni
	join dma.item_day_asd ida on ida.item_id = needed_item_id
	where date_trunc('month', ida.event_date) >= date_trunc('month', getdate() - intervalym '2 month')
	group by 1, 2
)
order by user_id, event_date
segmented by hash(user_id) all nodes;
select analyze_statistics('didf');


create local temp table isr on commit preserve rows as /*+direct*/ (
	select
		ui.user_id,
		CASE
			WHEN date_trunc('month',ur.event_date) < date_trunc('month',getdate()- intervalym '2 month')
			then date_trunc('month',ur.event_date)::date
			else ur.event_date::date
		END as 'event_date',
		sum(ur.items_started_net) as items_started,
		sum(ur.items_reactivated_net) as items_reactivated,
		sum(ur.items_blocked) as items_blocked
	from
		ui
	join dma.user_report_metrics ur using(user_id)
	where 1=1
		and date_trunc('month', ur.event_date) >= date_trunc('month', getdate() - intervalym '36 month')
	group by 1, 2
)
order by user_id, event_date
segmented by hash(user_id) all nodes;
select analyze_statistics('isr');


create local temp table calltracking on commit preserve rows as /*+direct*/ (
	select
		ctc.user_id,
		CASE
			WHEN date_trunc('month',ctc.time) < date_trunc('month',getdate()- intervalym '2 month')
			then date_trunc('month',ctc.time)::date
			else ctc.time::date
		END as event_date,
		count(ctc.CTCall_id) calls_count
	from DMA.calltracking_calls ctc
	where date_trunc('month', ctc.time)>=date_trunc('month',CURRENT_DATE()-intervalym '36 month')
	and ctc.isfraud is not true
	group by 1, 2
)
order by user_id, event_date
segmented by hash(user_id) all nodes;
select analyze_statistics('calltracking');


create local temp table asd_user on commit preserve rows as /*+direct*/ (
    select user_id,
    (case when user_personal_manager is not null and personal_manager_team not in ('Agency sales','Direct sales') then 1 else 0 end) as 'is_asd'
    from DMA.am_client_day
    where event_date=last_day(CURRENT_DATE - intervalym '1 month')
)
order by user_id
segmented by hash(user_id) all nodes;
select analyze_statistics('asd_user');


create local temp table pro_usage on commit preserve rows as /*+direct*/ (
	select
		user_id
		,date_trunc('month',event_date)::date as event_date /*36 месяцев*/
		,count( distinct event_date::date) usage_count
	from DMA.click_stream_avito_pro
	--where eventtype_id in (95721500004,95721500001,95721500003)
	group by
		1,2
)
order by user_id, event_date
segmented by hash(user_id) all nodes;
select analyze_statistics('pro_usage');


create local temp table hist_INN on commit preserve rows as /*+direct*/ (
	select *
	from
		(select
		user_id, uinn.INN_id as 'INN', date_trunc('day',actual_date)::date as 'INN_change_date_monthly', row_number() over(partition by user_id, date_trunc('month',actual_date) Order by actual_date desc) as rnk
		from DDS.L_User_INN uinn
		) t
	where rnk=1
)
order by user_id
segmented by hash(user_id) all nodes;
select analyze_statistics('hist_INN');


create local temp table reply_percent on commit preserve rows as /*+direct*/ (
	select
		user_id
		,date_trunc('month',min_event_date) as event_date
		,count(chat_id) as chat_count
        ,count(case when with_reply then chat_id else null end) as chats_with_reply
        ,sum(case when reply_time is not null and datediff('minute', min_event_date_time, reply_time)>=60 then 1 else 0 end) as reply_more_than_1h
	from DMA.messenger_chat_report
    where not is_spam
    and not is_blocked
    and not is_bad_cookie
    and date_trunc('month', min_event_date)>=date_trunc('month',getdate()-intervalym '36 month')
	group by 1,2
)
order by user_id, event_date
segmented by hash(user_id) all nodes;
select analyze_statistics('reply_percent');

create local temp table reply_percent_d on commit preserve rows as /*+direct*/ (
	select
		user_id
		,min_event_date::date as event_date
		,count(chat_id) as chat_count
        ,count(case when with_reply then chat_id else null end) as chats_with_reply
        ,sum(case when reply_time is not null and datediff('minute', min_event_date_time, reply_time)>=60 then 1 else 0 end) as reply_more_than_1h
	from DMA.messenger_chat_report
    where not is_spam
    and not is_blocked
    and not is_bad_cookie
    and date_trunc('month',min_event_date) >= date_trunc('month',getdate()- intervalym '2 month')
	group by 1,2
)
order by user_id, event_date
segmented by hash(user_id) all nodes;
select analyze_statistics('reply_percent_d');


drop table if exists dev_tmp.asd_user_stats_by_month_12m_bivrost;

create table dev_tmp.asd_user_stats_by_month_12m_bivrost
like dev_dma.asd_user_stats_by_month_12m_bivrost including projections;


insert /*+ direct */ into dev_tmp.asd_user_stats_by_month_12m_bivrost
with calendar as
(
	select distinct
		CASE
			WHEN date_trunc('month',event_date) < date_trunc('month',getdate()- intervalym '2 month')
			then date_trunc('month',event_date)::date
			else event_date::date
		END as event_date
	from
		DICT.calendar
	where
		date_trunc('month',event_date)>= date_trunc('month', getdate()- intervalym '36 month')
		and date_trunc('day',event_date)<=date_trunc('day',getdate())
)
select
    :launch_id,
	ui.external_id as user_ext,
	ui.name as user_name,
	ui.shop_name,
	ui.user_category,
	ui.user_subcategory,
	ui.user_region,
	dc.event_date::date as 'month',
	case
		when date_trunc('month',dc.event_date) < date_trunc('month',getdate()- intervalym '2 month')
		then idf.item_views
		else didf.item_views
	end as item_views,
	case
		when date_trunc('month',dc.event_date) < date_trunc('month',getdate()- intervalym '2 month')
		then idf.contacts
		else didf.contacts
	end as contacts,
	didf.active_items as active_items_d,
	idf.active_items,
	case
		when date_trunc('month',dc.event_date) < date_trunc('month',getdate()- intervalym '2 month')
		then idf.item_views_bivrost
		else didf.item_views_bivrost
	end as item_views_bivrost,
	case
		when date_trunc('month',dc.event_date) < date_trunc('month',getdate()- intervalym '2 month')
		then idf.contacts_bivrost
		else didf.contacts_bivrost
	end as contacts_bivrost,
	isr.items_started,
	isr.items_reactivated,
	isr.items_blocked,
	pmt.lf_payment,
	pmt.lf_payment_net,
	pmt.vas_payment,
	pmt.vas_payment_net,
	pmt.subs_payment,
	pmt.subs_payment_net,
	pmt.extension_payment,
	pmt.extension_payment_net,
	pmt.Domofond_VAS_payment,
	pmt.Domofond_VAS_payment_net,
	pmt.shop_payment,
	pmt.shop_payment_net,
	pmt.context_payment,
	pmt.context_payment_net,
	pmt.paid_contact_payment,
	pmt.paid_contact_payment_net,
	pmt.autoteka_payment,
	pmt.autoteka_payment_net,
	pmt.subscription_burned,
	pmt.subscription_burned_net,
	pmt.subscription_bonuses_burned,
	pmt.subscription_bonuses_burned_net,
	pmt.extension_burned,
	pmt.extension_burned_net,
	pmt.total_payment,
	pmt.total_payment_net,
	pmt.wallet_pay_in,
	asds_cq.asd_hq_segment as current_segment,
	asds_pq.asd_hq_segment as historical_segment,
	ud.personal_manager_team as team_end_of_month,
	ud.user_personal_manager as user_personal_manager_end_of_month,
	ud.user_is_blocked,
	ud.user_is_shop,
	ud.shop_tariff,
	ud.mapping as 'team_mapping_end_of_month',
	CASE
		WHEN dc.event_date::date = date_trunc('month',dc.event_date)
		then ud.user_balance_net
		ELSE 0
	END AS user_balance_net,
	CASE
		WHEN dc.event_date::date = date_trunc('month',dc.event_date)
		then ud.user_balance
		ELSE 0
	END AS user_balance,
	ui.personal_manager_team as actual_personal_manager_team,
	atm.team_vertical_bi_mapping as actual_personal_manager_team_mapping,
	ui.user_personal_manager as actual_user_personal_manager,
	case
		when date_trunc('month',dc.event_date) < date_trunc('month',getdate()- intervalym '2 month')
		then mm.number_of_messages
		else mmd.number_of_messages
	end as number_of_messages,
	mm.unique_message_sender_users,
	sfu.SFAccount_id,
	sfu.SFAccount_SalesforceID,
	sfu.SFTopParentAccount_id,
	ct.calls_count,
	au.is_asd,
	(case when pu.usage_count>=2 then '2+ активный пользователь' else
		(case when pu.usage_count=1 then '1 одно посещение' else '0 не пользователь' end) end) as 'protools_user',
	mmd.unique_message_sender_users as unique_message_sender_users_d,
	udd.user_balance_net as user_balance_net_d,
	udd.user_balance as user_balance_d,
	hist_INN.INN,
	null as reply_percent,  --пока оставляю, чтобы источник табло не сломался
	case
		when date_trunc('month',dc.event_date) < date_trunc('month',getdate()- intervalym '2 month')
		then COALESCE(rp.chats_with_reply,0)
		else COALESCE(rpd.chats_with_reply,0)
	end as chats_with_reply,
	case
		when date_trunc('month',dc.event_date) < date_trunc('month',getdate()- intervalym '2 month')
		then COALESCE(rp.chat_count,0)
		else COALESCE(rpd.chat_count,0)
	end as chat_count,
    null as reply_percent_less_1h, --пока оставляю, чтобы источник табло не сломался
	case
		when date_trunc('month',dc.event_date) < date_trunc('month',getdate()- intervalym '2 month')
		then idf.item_views_protools
		else didf.item_views_protools
	end as item_views_protools, 
	case
		when date_trunc('month',dc.event_date) < date_trunc('month',getdate()- intervalym '2 month')
		then idf.contacts_protools
		else didf.contacts_protools
	end as contacts_protools,
	case
		when date_trunc('month',dc.event_date) < date_trunc('month',getdate()- intervalym '2 month')
		then mm.first_messages_count
		else mmd.first_messages_count
	end as first_messages_count,
	case
		when date_trunc('month',dc.event_date) < date_trunc('month',getdate()- intervalym '2 month')
		then COALESCE(rp.reply_more_than_1h,0)
		else COALESCE(rpd.reply_more_than_1h,0)
	end as replies_more_than_1h
from ui
	CROSS JOIN calendar dc
	left join reply_percent rp on ui.user_id=rp.user_id and rp.event_date=dc.event_date
	left join reply_percent_d rpd on ui.user_id=rpd.user_id and rpd.event_date=dc.event_date
	left join pmt on dc.event_date=pmt.event_date and ui.user_id=pmt.user_id
	left join hist_INN on hist_INN.user_id=ui.user_id and dc.event_date INTERPOLATE PREVIOUS VALUE INN_change_date_monthly
	left join user_details ud on date_trunc('month',dc.event_date)=date_trunc('month',ud.event_date) and ui.user_id=ud.user_id
	left join idf on dc.event_date=idf.event_date and ui.user_id = idf.user_id
	left join didf on dc.event_date=didf.event_date and ui.user_id = didf.user_id
	left join user_details_d udd on dc.event_date=udd.event_date and ui.user_id=udd.user_id
	left join calltracking ct on dc.event_date=ct.event_date and ui.user_id=ct.user_id
	left join messenger_messages mm on dc.event_date=mm.message_month and ui.user_id=mm.to_user_id
	left join messenger_messages_d mmd on dc.event_date=mmd.message_month and ui.user_id=mmd.to_user_id
	left join pro_usage pu on dc.event_date=pu.event_date and pu.user_id=ui.user_id
	left join isr on dc.event_date=isr.event_date and ui.user_id=isr.user_id
	left join asd_user au on au.user_id=ui.user_id
	left join dma.salesforce_usermapping sfu on ui.user_id=sfu.user_id
	left join dma.asd_teams_mapping atm on atm.team_variations = ui.personal_manager_team
	left join dma.asd_hq_segmentation asds_pq on asds_pq.hq=coalesce('SF'||sfu.SFTopParentAccount_id,ui.user_id::VARCHAR) and asds_pq.vertical_group=atm.team_vertical and date_trunc('quarter',dc.event_date)=asds_pq.event_quarter+intervalym '1 quarter'
	left join dma.asd_hq_segmentation asds_cq on asds_cq.hq=coalesce('SF'||sfu.SFTopParentAccount_id,ui.user_id::VARCHAR) and asds_cq.vertical_group=atm.team_vertical and date_trunc('quarter',dc.event_date)=asds_cq.event_quarter
;

select swap_partitions_between_tables(
    'dev_tmp.asd_user_stats_by_month_12m_bivrost',
    0,
    :launch_id,
    'dev_dma.asd_user_stats_by_month_12m_bivrost');

drop table if exists dev_tmp.asd_user_stats_by_month_12m_bivrost;