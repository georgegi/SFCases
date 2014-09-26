
-- select top 100 * from x_DATATEAM.StudentPrgInvolvementHistory where StudentNumber = '306208616'

select top 100 h.Program, h.StudentNumber, Firstname, Lastname, 
	InvolvementStartDate = convert(varchar, Involvementstartdate, 101), InvolvementEndDate = convert(varchar, involvementenddate, 101), InvolvementEndStatus
from x_DATATEAM.StudentPrgInvolvementHistory h
--where h.ItemDefID = 'AD7607B4-7673-4716-BEEA-3F070095CD18' -- Eligibility Determination -- 3118
--and h.ItemOutcomeID = '9E4EA4D4-C78B-4F04-9215-3D1C33B1EE23' -- Eligibile
--and h.involvementEndStatus = '73DC240D-EF00-42C9-910D-3953ED3540D4' -- Not Eligible
--and h.Number = '306208616'
where h.StudentNumber = '306208616'
order by h.involvementstartdate, h.itemstartdate, h.itemenddate

-- get the most recent involvement per student per program

-- proves one involvement per student
--select studentid, involvementID, count(*) tot from (
--select distinct h.StudentID, h.InvolvementID
select h.*
from x_DATATEAM.StudentPrgInvolvementHistory h
where h.Program = 'Special Education'
and h.InvolvementID = (
	select top 1 hi.InvolvementID
	from x_DATATEAM.StudentPrgInvolvementHistory hi
	where h.StudentID = hi.StudentID
	order by hi.InvolvementStartDate desc
	)
--) t group by studentid, involvementid having count(*) = 1























