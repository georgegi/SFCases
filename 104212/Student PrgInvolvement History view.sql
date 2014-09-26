alter FUNCTION x_PORT.Enrich2FOCUSExport ()
RETURNS @t TABLE 
(
	StudentID uniqueidentifier primary key,
	InvolvementID uniqueidentifier null,
	ItemID uniqueidentifier null, -- the IEP, not PrgItemForm
	StartDate datetime null,
	studentNumber	varchar(20) NULL, -- Student number
	StudentFirstName varchar(50) NULL,
	StudentLastName varchar(50) NULL,

	FEFPProgram varchar(10) NULL,
	N999 bit null,
	IEPYN	varchar(1),
	disabilityType	varchar(2),
	exitReason	varchar(2),
	exitDate varchar(10),
	specializedTransportation varchar(1)
)
-- update columns in the return table one-by-one
AS

select 
	StudentNumber = s.Number,
	School  = isnull(sch.name, ''), --(service)
	FEFPProgram  = id.Name, -- (? grade level grouping)
	N999 = case sch.ID when 'C3666321-0EA5-4627-9DB5-4ABFB00A9F22' then 1 else 0 end,
	ESY = esyyn.DisplayValue,
	InitialMedicaidPermissionDate  = isnull(convert(varchar, mh.StartDate, 101), ''),
--IEPDates:
	IEPPlanDate = convert(varchar, i.StartDate, 101),
	IEPExpirationDate = convert(varchar, I.PlannedEndDate, 101),
	ReEvaluationDueDate = convert(varchar, dat.NextEvaluationDate, 101),
-- ???
	TTSW = '',
	TNDP = '',
--LRE 
LREPlacement = po.Text,
	--60DayException = NULL,
	bogus = NULL
from Student s
join PrgInvolvement inv on s.ID = inv.StudentID and inv.ProgramID = 'F98A8EF2-98E2-4CAC-95AF-D7D89EF7F80C' and inv.EndDate is null
join PrgItem i on s.ID = i.StudentID and i.InvolvementID = inv.ID and i.EndDate is null
join PrgItemDef id on i.DefID = id.ID and id.TypeID = 'A5990B5E-AFAD-4EF0-9CCA-DC3685296870' -- IEP
left join School sch on s.CurrentSchoolID = sch.ID




-- select * from EnumValue where ID = 'B76DDCD6-B261-4D46-A98E-857B0A814A0C' -- yes


select inv.StudentID, ed.DateDetermined, d.ID, d.StateCode, d.Name, d.DeletedDate, /* ide.IsEligibileID, */ count(*) tot
from PrgInvolvement inv 
join PrgItem i on inv.ID = i.InvolvementID and i.DefID in (select ID from PrgItemDef where TypeID = (select ID from PrgItemType where name = 'IEP')) -- Yes
join PrgSection sec on i.ID = sec.ItemID
join IepEligibilityDetermination ed on sec.ID = ed.ID
join IepDisabilityEligibility ide on sec.ID = ide.InstanceID
join IepDisability d on ide.DisabilityID = d.ID
group by inv.StudentID, ed.DateDetermined, d.StateCode, d.DeletedDate, /* ide.IsEligibileID, */ d.Name, d.ID
order by tot desc


select * from API.

select * from IepEligibilityDetermination 

x_datateam.findguid 'C8F0F71F-8814-4838-B5E5-0009D12CDD58' -- elig deter


select * from dbo.IepDisabilityEligibility where InstanceID = 'C8F0F71F-8814-4838-B5E5-0009D12CDD58'
select * from dbo.IepEligibilityDetermination where ID = 'C8F0F71F-8814-4838-B5E5-0009D12CDD58'
--select * from LEGACYSPED.MAP_PrgSectionID where DestID = 'C8F0F71F-8814-4838-B5E5-0009D12CDD58'
select * from dbo.PrgMilestone where StartingSectionID = 'C8F0F71F-8814-4838-B5E5-0009D12CDD58'
select * from dbo.PrgSection where ID = 'C8F0F71F-8814-4838-B5E5-0009D12CDD58'

select * from sys.objects where name like '%elig%' and type = 'U'

select d.name, count(*) tot 
from iepdisability d
join iepdisabilityeligibility de on d.ID = de.DisabilityID
group by d.name
order by tot desc



select * from IepDisability where name = 'Language Impairment (LI)'

x_datateam.findguid '8F8579F1-B58C-4FBB-A8CC-A153B460D98C'


select * from dbo.IepDisability where ID = '8F8579F1-B58C-4FBB-A8CC-A153B460D98C'
select * from dbo.IepDisabilityEligibility where DisabilityID = '8F8579F1-B58C-4FBB-A8CC-A153B460D98C'
select * from LEGACYSPED.MAP_IepDisabilityEligibilityID where DisabilityID = '8F8579F1-B58C-4FBB-A8CC-A153B460D98C'
select * from LEGACYSPED.SelectLists_LOCAL where EnrichID = '8F8579F1-B58C-4FBB-A8CC-A153B460D98C'


select count(*) 
from IepDisabilityEligibility

select count(*)
from IepEligibilityDetermination


select * 
from IepEligibilityDetermination
where NoneSuspected = 1 -- 27 of 8786

select * from PrgSection where ID = '278C57FE-A8BA-4B18-9B8A-0851E961A5B9'

select * from PrgItem where Id = '54F7D4A8-8663-4D32-BCE0-CB9C55058E3C'

select * from PrgItemDef where ID = 'AD7607B4-7673-4716-BEEA-3F070095CD18' -- Eligibility Determination


select o.Text, i.*
from PrgItem i
join PrgItemOutcome o on i.ItemOutcomeID = o.ID
where i.DefID = 'AD7607B4-7673-4716-BEEA-3F070095CD18' -- Eligibility Determination -- 3118
-- and i.InvolvementId is null


select * from PrgItemOutcome where ID = '9E4EA4D4-C78B-4F04-9215-3D1C33B1EE23' -- Eligible


select Program = p.Name, i.ItemOutcomeID, Outcome = o.Text, inv.EndStatus, stat.Name, /* inv.EndDate, */ count(*) tot
from PrgItem i
join PrgItemOutcome o on i.ItemOutcomeID = o.ID
join PrgInvolvement inv on i.InvolvementID = inv.ID
join Program p on inv.ProgramID = p.ID
left join PrgStatus stat on inv.EndStatus = stat.ID
where i.DefID = 'AD7607B4-7673-4716-BEEA-3F070095CD18' -- Eligibility Determination -- 3118
-- and p.name <> 'Special Education' -- only sped represented
group by p.Name, i.ItemOutcomeID, o.Text, inv.EndStatus /* inv.EndDate, */ , stat.Name

select InvolvementID = inv.ID, s.number, s.firstname, s.lastname, 
	involvementStart = convert(varchar, inv.StartDate, 101), involvementEnd = convert(varchar, inv.EndDate, 101), InvolvementDays = datediff(dd, inv.StartDate, inv.EndDate), InvolvementStatus = stat.Name, 
	DeterminationDaysBeforeInvolvement = datediff(dd, inv.Startdate, i.EndDate),
	ItemDef = id.Name, ItemOutcome = o.Text, convert(varchar, i.StartDate, 101), convert(varchar, i.EndDate, 101)
from Student s
join PrgItem i on s.ID = i.StudentID
join PrgItemDef id on i.DefID = id.ID
join PrgItemOutcome o on i.ItemOutcomeID = o.ID
join PrgInvolvement inv on i.InvolvementID = inv.ID
join Program p on inv.ProgramID = p.ID
left join PrgStatus stat on inv.EndStatus = stat.ID
where i.DefID = 'AD7607B4-7673-4716-BEEA-3F070095CD18' -- Eligibility Determination -- 3118
and i.ItemOutcomeID = '9E4EA4D4-C78B-4F04-9215-3D1C33B1EE23' -- Eligibile
and inv.EndStatus = '73DC240D-EF00-42C9-910D-3953ED3540D4' -- Not Eligible
	and inv.ID = 'EEDF2456-2572-46F7-B5DF-52BE8721F765'
order by 1

select ItemID = i.ID, ItemDef = id.name, Outcome = o.Text, ItemStatus = ist.Name, ItemStart = convert(varchar, i.StartDate, 101)
from PrgItem i
join PrgItemDef id on i.DefID = id.ID
left join PrgItemOutcome o on i.ItemOutcomeID = o.ID
left join PrgStatus ist on i.EndStatusID = ist.ID
where i.InvolvementID = 'EEDF2456-2572-46F7-B5DF-52BE8721F765'
order by i.StartDate


x_datateam.Findguid '9A78D184-3045-41C1-AD47-311279DFF154' -- Meeting
select * from dbo.PrgDocument where ItemId = '9A78D184-3045-41C1-AD47-311279DFF154'
select * from dbo.PrgItem where ID = '9A78D184-3045-41C1-AD47-311279DFF154'
select * from dbo.PrgItemForm where ItemID = '9A78D184-3045-41C1-AD47-311279DFF154'
select * from dbo.PrgItemTeamMember where ItemID = '9A78D184-3045-41C1-AD47-311279DFF154'
select * from dbo.PrgMeeting where ID = '9A78D184-3045-41C1-AD47-311279DFF154'
select * from dbo.PrgSection where ItemID = '9A78D184-3045-41C1-AD47-311279DFF154'


select InitItem = iid.Name, ResultItem = rid.Name, ii.StartDate, ri.StartDate
from dbo.PrgItemRel r
left join PrgItem ii on r.InitiatingItemID = ii.ID
	left join PrgItemDef iid on ii.DefID = iid.ID
left join PrgItem ri on r.ResultingItemID = ri.ID
	left join PrgItemDef rid on ri.DefID = rid.ID
where InitiatingItemID = '9A78D184-3045-41C1-AD47-311279DFF154'



-- student program involvement history 
select top 100 Program = p.name,
	s.Number, s.Firstname, s.Lastname, 
	InvolvementID = pinv.ID, InvolvementStartDate = pinv.StartDate, InvolvementEndDate = pinv.EndDate, InvolvementEndStatus = pinv.EndStatus, InvolvementDays = datediff(dd, pinv.StartDate, pinv.EndDate), 
	ItemID = itm.ID, Item = itmd.Name, ItemStartDate = itm.StartDate, ItemEndDate = itm.EndDate, ItemEndedDate = itm.EndedDate, ItemStartStatus = ib.Name, ItemEndStatusSequence = ie.Sequence, itm.PlannedEndDate, ItemIsEnded = itm.IsEnded, ItemEndStatus = ie.Name,  
	--ResultingItem = ritmd.Name, -- possible to have multiple resulting items per item
	--ResultingItemOutcome = ro.Text, ResultingItemSequence = ro.Sequence,
	ItemOutcome = o.Text, o.Sequence, 
	pinv.StudentID
from Program p
join PrgInvolvement pinv on p.ID = pinv.ProgramID
join Student s on pinv.StudentID = s.ID
join PrgItem itm on pinv.ID = itm.InvolvementID
join PrgItemDef itmd on itm.DefID = itmd.ID
left join PrgStatus ib on itm.StartStatusID = ib.ID
left join PrgStatus ie on itm.EndStatusID = ie.ID
left join PrgItemOutcome o on itm.ItemOutcomeId = o.ID
--left join PrgItemRel itmr on itm.ID = itmr.InitiatingItemID -- starting with all itmes, joining to each as init item
--left join PrgItemRelDef itmrd on itmr.PrgItemRelDefID = itmrd.ID
--left join PrgItem ritm on itmr.ResultingItemID = ritm.ID
--left join PrgItemDef ritmd on ritm.DefID = ritmd.ID
--left join PrgItemOutcome ro on ritm.ItemOutcomeID = ro.ID
/*   test 
where pinv.ID = (
	select top 1 ID from (
	select inv2.ID, count(*) titm
	from PrgInvolvement inv2 
	join PrgItem itm2 on inv2.ID = itm2.InvolvementID 
	group by inv2.ID)  t
	order by titm desc
	)
*/
order by pinv.ID, InvolvementStartDate, ItemStartDate

select * from PrgItemRel


x_datateam.findguid '043CB6F2-BF09-4996-8547-F958C940EE05' -- Can I identify the objective of this meeting?
select * from dbo.PrgDocument where ItemId = '043CB6F2-BF09-4996-8547-F958C940EE05'
select * from dbo.PrgItemForm where ItemID = '043CB6F2-BF09-4996-8547-F958C940EE05'
select * from dbo.PrgItemTeamMember where ItemID = '043CB6F2-BF09-4996-8547-F958C940EE05'

select * from dbo.PrgItem where ID = '043CB6F2-BF09-4996-8547-F958C940EE05'
select * from dbo.PrgMeeting where ID = '043CB6F2-BF09-4996-8547-F958C940EE05'

select * from dbo.PrgSection where ItemID = '043CB6F2-BF09-4996-8547-F958C940EE05'

select st.name, sd.Title, FormTemplate = ff.Name, s.* 
from dbo.PrgSection s
join PrgSectionDef sd on s.DefID = sd.ID
join PrgSectionType st on sd.TypeID = st.ID
left join FormTemplate ff on sd.FormTemplateID = ff.ID
where s.ItemID = '043CB6F2-BF09-4996-8547-F958C940EE05'

--- select * from PrgItemOutcome














